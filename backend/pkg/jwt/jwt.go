package jwt

import (
	"errors"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/config"
)

var (
	ErrTokenExpired     = errors.New("token expired")
	ErrTokenInvalid     = errors.New("token invalid")
	ErrTokenRevoked     = errors.New("token revoked")
	ErrTokenMalformed   = errors.New("token malformed")
)

type Claims struct {
	UserID uuid.UUID `json:"userId"`
	Role   string    `json:"role"`
	jwt.RegisteredClaims
}

type TokenPair struct {
	AccessToken  string `json:"accessToken"`
	RefreshToken string `json:"refreshToken"`
	ExpiresIn    int64  `json:"expiresIn"`
}

type JWTManager struct {
	accessSecret  []byte
	refreshSecret []byte
	accessExpiry  time.Duration
	refreshExpiry time.Duration
	issuer        string
}

func New(cfg config.JWTConfig) *JWTManager {
	return &JWTManager{
		accessSecret:  []byte(cfg.AccessSecret),
		refreshSecret: []byte(cfg.RefreshSecret),
		accessExpiry:  cfg.AccessExpiry,
		refreshExpiry: cfg.RefreshExpiry,
		issuer:        cfg.Issuer,
	}
}

func (m *JWTManager) GenerateTokenPair(userID uuid.UUID, role string) (*TokenPair, error) {
	now := time.Now().UTC()

	accessClaims := Claims{
		UserID: userID,
		Role:   role,
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   userID.String(),
			Issuer:    m.issuer,
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(m.accessExpiry)),
			NotBefore: jwt.NewNumericDate(now),
			ID:        uuid.New().String(),
		},
	}

	accessToken := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims)
	accessString, err := accessToken.SignedString(m.accessSecret)
	if err != nil {
		return nil, fmt.Errorf("failed to sign access token: %w", err)
	}

	refreshClaims := Claims{
		UserID: userID,
		Role:   role,
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   userID.String(),
			Issuer:    m.issuer,
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(m.refreshExpiry)),
			NotBefore: jwt.NewNumericDate(now),
			ID:        uuid.New().String(),
		},
	}

	refreshToken := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims)
	refreshString, err := refreshToken.SignedString(m.refreshSecret)
	if err != nil {
		return nil, fmt.Errorf("failed to sign refresh token: %w", err)
	}

	return &TokenPair{
		AccessToken:  accessString,
		RefreshToken: refreshString,
		ExpiresIn:    int64(m.accessExpiry.Seconds()),
	}, nil
}

func (m *JWTManager) ValidateAccessToken(tokenString string) (*Claims, error) {
	return m.validateToken(tokenString, m.accessSecret)
}

func (m *JWTManager) ValidateRefreshToken(tokenString string) (*Claims, error) {
	return m.validateToken(tokenString, m.refreshSecret)
}

func (m *JWTManager) validateToken(tokenString string, secret []byte) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return secret, nil
	})

	if err != nil {
		if errors.Is(err, jwt.ErrTokenExpired) {
			return nil, ErrTokenExpired
		}
		if errors.Is(err, jwt.ErrTokenMalformed) {
			return nil, ErrTokenMalformed
		}
		return nil, ErrTokenInvalid
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, ErrTokenInvalid
	}

	return claims, nil
}

func (m *JWTManager) RefreshTokenExpiry() time.Duration {
	return m.refreshExpiry
}

func (m *JWTManager) AccessExpiryDuration() time.Duration {
	return m.accessExpiry
}
