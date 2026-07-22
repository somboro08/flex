package services

import (
	"context"
	"crypto/rand"
	"errors"
	"fmt"
	"math/big"
	"time"

	"github.com/google/uuid"
	"github.com/rs/zerolog/log"
	"github.com/somboro08/flex-api/internal/config"
	"github.com/somboro08/flex-api/internal/models"
	"github.com/somboro08/flex-api/internal/repository"
	"github.com/somboro08/flex-api/pkg/jwt"
	"github.com/somboro08/flex-api/pkg/validator"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

var (
	ErrInvalidCredentials = errors.New("identifiants invalides")
	ErrAccountLocked      = errors.New("compte temporairement verrouillé")
	ErrOTPExpired         = errors.New("code OTP expiré ou invalide")
	ErrOTPTooManyAttempts = errors.New("trop de tentatives OTP")
	ErrEmailAlreadyUsed   = errors.New("cet email est déjà utilisé")
	ErrPhoneAlreadyUsed   = errors.New("ce numéro est déjà utilisé")
	ErrWeakPassword       = errors.New("mot de passe trop faible")
	ErrTokenRefresh       = errors.New("impossible de rafraîchir le token")
)

const (
	maxLoginAttempts    = 5
	lockDurationMinutes = 15
	otpLength           = 6
	otpExpiryMinutes    = 10
	maxOTPAttempts      = 5
)

type AuthService struct {
	userRepo    *repository.UserRepository
	sessionRepo *repository.SessionRepository
	otpRepo     *repository.OTPRepository
	jwt         *jwt.JWTManager
	cfg         *config.Config
	validator   *validator.Validator
}

func NewAuthService(
	userRepo *repository.UserRepository,
	sessionRepo *repository.SessionRepository,
	otpRepo *repository.OTPRepository,
	jwt *jwt.JWTManager,
	cfg *config.Config,
	v *validator.Validator,
) *AuthService {
	return &AuthService{
		userRepo:    userRepo,
		sessionRepo: sessionRepo,
		otpRepo:     otpRepo,
		jwt:         jwt,
		cfg:         cfg,
		validator:   v,
	}
}

type RegisterRequest struct {
	Nom       string        `json:"nom" binding:"required"`
	Prenom    string        `json:"prenom" binding:"required"`
	Telephone string        `json:"telephone" binding:"required"`
	Email     *string       `json:"email,omitempty"`
	Password  string        `json:"password" binding:"required"`
	Role      models.UserRole `json:"role"`
}

type LoginRequest struct {
	Telephone string `json:"telephone" binding:"required"`
	Password  string `json:"password" binding:"required"`
}

type AuthResponse struct {
	User         *models.User `json:"user"`
	TokenPair    *jwt.TokenPair `json:"tokens"`
}

func (s *AuthService) Register(ctx context.Context, req RegisterRequest, deviceInfo, ipAddress, userAgent string) (*AuthResponse, error) {
	if err := s.validator.Var(req.Nom, "name"); err != nil {
		return nil, fmt.Errorf("nom invalide: %w", err)
	}
	if err := s.validator.Var(req.Prenom, "name"); err != nil {
		return nil, fmt.Errorf("prenom invalide: %w", err)
	}
	if !validator.IsValidPhone(req.Telephone) {
		return nil, fmt.Errorf("numéro de téléphone invalide")
	}
	if req.Email != nil && *req.Email != "" && !validator.IsValidEmail(*req.Email) {
		return nil, fmt.Errorf("email invalide")
	}
	if errs := validator.IsStrongPassword(req.Password); len(errs) > 0 {
		return nil, fmt.Errorf("%v: %v", ErrWeakPassword, errs)
	}

	existingUser, err := s.userRepo.FindByTelephone(ctx, req.Telephone)
	if err == nil && existingUser != nil {
		return nil, ErrPhoneAlreadyUsed
	}
	if !errors.Is(err, repository.ErrUserNotFound) {
		return nil, err
	}

	if req.Email != nil && *req.Email != "" {
		existingEmail, err2 := s.userRepo.FindByEmail(ctx, *req.Email)
		if err2 == nil && existingEmail != nil {
			return nil, ErrEmailAlreadyUsed
		}
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, fmt.Errorf("failed to hash password: %w", err)
	}

	if req.Role == "" {
		req.Role = models.RoleVoyageur
	}

	user := &models.User{
		Nom:          req.Nom,
		Prenom:       req.Prenom,
		Telephone:    req.Telephone,
		Email:        req.Email,
		PasswordHash: string(hashedPassword),
		Role:         req.Role,
		IsVerified:   false,
		IsOnboarded:  false,
		IsActive:     true,
	}

	if err := s.userRepo.Create(ctx, user); err != nil {
		return nil, fmt.Errorf("failed to create user: %w", err)
	}

	tokens, err := s.jwt.GenerateTokenPair(user.ID, string(user.Role))
	if err != nil {
		return nil, fmt.Errorf("failed to generate tokens: %w", err)
	}

	if err := s.saveSession(ctx, user.ID, tokens.RefreshToken, deviceInfo, ipAddress, userAgent); err != nil {
		log.Warn().Err(err).Msg("failed to save session after registration")
	}

	if err := s.userRepo.UpdateRefreshToken(ctx, user.ID, tokens.RefreshToken); err != nil {
		log.Warn().Err(err).Msg("failed to update refresh token in user")
	}

	return &AuthResponse{User: user, TokenPair: tokens}, nil
}

func (s *AuthService) Login(ctx context.Context, req LoginRequest, deviceInfo, ipAddress, userAgent string) (*AuthResponse, error) {
	user, err := s.userRepo.FindByTelephone(ctx, req.Telephone)
	if err != nil {
		if errors.Is(err, repository.ErrUserNotFound) {
			return nil, ErrInvalidCredentials
		}
		return nil, err
	}

	if !user.IsActive {
		return nil, ErrAccountLocked
	}

	if user.IsLocked() {
		return nil, ErrAccountLocked
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		_ = s.userRepo.IncrementLoginAttempts(ctx, user.ID)

		if user.FailedLoginAttempts+1 >= maxLoginAttempts {
			_ = s.userRepo.LockAccount(ctx, user.ID, lockDurationMinutes)
			return nil, ErrAccountLocked
		}

		return nil, ErrInvalidCredentials
	}

	_ = s.userRepo.ResetLoginAttempts(ctx, user.ID)

	tokens, err := s.jwt.GenerateTokenPair(user.ID, string(user.Role))
	if err != nil {
		return nil, fmt.Errorf("failed to generate tokens: %w", err)
	}

	if err := s.saveSession(ctx, user.ID, tokens.RefreshToken, deviceInfo, ipAddress, userAgent); err != nil {
		log.Warn().Err(err).Msg("failed to save session after login")
	}

	if err := s.userRepo.UpdateRefreshToken(ctx, user.ID, tokens.RefreshToken); err != nil {
		log.Warn().Err(err).Msg("failed to update refresh token in user")
	}

	now := time.Now().UTC()
	_ = s.userRepo.UpdateFields(ctx, user.ID, map[string]interface{}{
		"last_login_at": &now,
	})

	user.LastLoginAt = &now

	return &AuthResponse{User: user, TokenPair: tokens}, nil
}

func (s *AuthService) RefreshToken(ctx context.Context, refreshToken string, deviceInfo, ipAddress, userAgent string) (*AuthResponse, error) {
	claims, err := s.jwt.ValidateRefreshToken(refreshToken)
	if err != nil {
		return nil, ErrTokenRefresh
	}

	session, err := s.sessionRepo.FindByRefreshToken(ctx, refreshToken)
	if err != nil {
		return nil, ErrTokenRefresh
	}

	_ = s.sessionRepo.Revoke(ctx, session.ID)

	user, err := s.userRepo.FindByID(ctx, claims.UserID)
	if err != nil {
		return nil, err
	}

	if !user.IsActive {
		return nil, ErrAccountLocked
	}

	tokens, err := s.jwt.GenerateTokenPair(user.ID, string(user.Role))
	if err != nil {
		return nil, fmt.Errorf("failed to generate tokens: %w", err)
	}

	if err := s.saveSession(ctx, user.ID, tokens.RefreshToken, deviceInfo, ipAddress, userAgent); err != nil {
		log.Warn().Err(err).Msg("failed to save session after token refresh")
	}

	if err := s.userRepo.UpdateRefreshToken(ctx, user.ID, tokens.RefreshToken); err != nil {
		log.Warn().Err(err).Msg("failed to update refresh token in user")
	}

	return &AuthResponse{User: user, TokenPair: tokens}, nil
}

func (s *AuthService) Logout(ctx context.Context, userID uuid.UUID, refreshToken string) error {
	session, err := s.sessionRepo.FindByRefreshToken(ctx, refreshToken)
	if err != nil {
		return nil
	}
	return s.sessionRepo.Revoke(ctx, session.ID)
}

func (s *AuthService) LogoutAll(ctx context.Context, userID uuid.UUID) error {
	if err := s.sessionRepo.RevokeAllByUserID(ctx, userID); err != nil {
		return err
	}
	return s.userRepo.UpdateRefreshToken(ctx, userID, "")
}

func (s *AuthService) SendOTP(ctx context.Context, identifier, purpose string) (string, error) {
	code, err := generateOTP(otpLength)
	if err != nil {
		return "", fmt.Errorf("failed to generate OTP: %w", err)
	}

	_ = s.otpRepo.InvalidatePrevious(ctx, identifier, purpose)

	otp := &models.OTPCode{
		Identifier:  identifier,
		Code:        code,
		Purpose:     purpose,
		MaxAttempts: maxOTPAttempts,
		ExpiresAt:   time.Now().UTC().Add(otpExpiryMinutes * time.Minute),
	}

	if err := s.otpRepo.Create(ctx, otp); err != nil {
		return "", fmt.Errorf("failed to save OTP: %w", err)
	}

	return code, nil
}

func (s *AuthService) VerifyOTP(ctx context.Context, identifier, code, purpose string) error {
	otp, err := s.otpRepo.FindValid(ctx, identifier, code, purpose)
	if err != nil {
		return ErrOTPExpired
	}

	if otp.HasExceededAttempts() {
		return ErrOTPTooManyAttempts
	}

	if otp.IsExpired() {
		_ = s.otpRepo.IncrementAttempts(ctx, otp.ID)
		return ErrOTPExpired
	}

	_ = s.otpRepo.MarkUsed(ctx, otp.ID)
	return nil
}

func (s *AuthService) ChangePassword(ctx context.Context, userID uuid.UUID, oldPassword, newPassword string) error {
	user, err := s.userRepo.FindByID(ctx, userID)
	if err != nil {
		return err
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(oldPassword)); err != nil {
		return ErrInvalidCredentials
	}

	if errs := validator.IsStrongPassword(newPassword); len(errs) > 0 {
		return fmt.Errorf("%v: %v", ErrWeakPassword, errs)
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("failed to hash password: %w", err)
	}

	return s.userRepo.UpdateFields(ctx, userID, map[string]interface{}{
		"password_hash": string(hashedPassword),
	})
}

func (s *AuthService) ResetPassword(ctx context.Context, telephone, otpCode, newPassword string) error {
	if err := s.VerifyOTP(ctx, telephone, otpCode, "password_reset"); err != nil {
		return err
	}

	user, err := s.userRepo.FindByTelephone(ctx, telephone)
	if err != nil {
		return err
	}

	if errs := validator.IsStrongPassword(newPassword); len(errs) > 0 {
		return fmt.Errorf("%v: %v", ErrWeakPassword, errs)
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("failed to hash password: %w", err)
	}

	return s.userRepo.UpdateFields(ctx, user.ID, map[string]interface{}{
		"password_hash": string(hashedPassword),
	})
}

func (s *AuthService) GetProfile(ctx context.Context, userID uuid.UUID) (*models.User, error) {
	return s.userRepo.FindByID(ctx, userID)
}

func (s *AuthService) saveSession(ctx context.Context, userID uuid.UUID, refreshToken, deviceInfo, ipAddress, userAgent string) error {
	session := &models.Session{
		UserID:       userID,
		RefreshToken: refreshToken,
		DeviceInfo:   &deviceInfo,
		IPAddress:    &ipAddress,
		UserAgent:    &userAgent,
		ExpiresAt:    time.Now().UTC().Add(s.jwt.RefreshTokenExpiry()),
	}
	return s.sessionRepo.Create(ctx, session)
}

func generateOTP(length int) (string, error) {
	code := ""
	for i := 0; i < length; i++ {
		n, err := rand.Int(rand.Reader, big.NewInt(10))
		if err != nil {
			return "", err
		}
		code += fmt.Sprintf("%d", n.Int64())
	}
	return code, nil
}
