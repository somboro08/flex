package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/somboro08/flex-api/internal/middleware"
	"github.com/somboro08/flex-api/internal/services"
	"github.com/somboro08/flex-api/pkg/response"
)

type AuthHandler struct {
	authService *services.AuthService
}

func NewAuthHandler(authService *services.AuthService) *AuthHandler {
	return &AuthHandler{authService: authService}
}

type registerInput struct {
	Nom       string `json:"nom" binding:"required"`
	Prenom    string `json:"prenom" binding:"required"`
	Telephone string `json:"telephone" binding:"required"`
	Email     string `json:"email,omitempty"`
	Password  string `json:"password" binding:"required"`
	Role      string `json:"role,omitempty"`
}

type loginInput struct {
	Telephone string `json:"telephone" binding:"required"`
	Password  string `json:"password" binding:"required"`
}

type refreshInput struct {
	RefreshToken string `json:"refreshToken" binding:"required"`
}

type sendOTPInput struct {
	Identifier string `json:"identifier" binding:"required"`
	Purpose    string `json:"purpose" binding:"required"`
}

type verifyOTPInput struct {
	Identifier string `json:"identifier" binding:"required"`
	Code       string `json:"code" binding:"required"`
	Purpose    string `json:"purpose" binding:"required"`
}

type changePasswordInput struct {
	OldPassword string `json:"oldPassword" binding:"required"`
	NewPassword string `json:"newPassword" binding:"required"`
}

type resetPasswordInput struct {
	Telephone   string `json:"telephone" binding:"required"`
	OTPCode     string `json:"otpCode" binding:"required"`
	NewPassword string `json:"newPassword" binding:"required"`
}

func (h *AuthHandler) Register(c *gin.Context) {
	var input registerInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides: "+err.Error())
		return
	}

	deviceInfo := c.GetHeader("User-Agent")
	ipAddress := c.ClientIP()
	userAgent := c.GetHeader("User-Agent")

	req := services.RegisterRequest{
		Nom:       input.Nom,
		Prenom:    input.Prenom,
		Telephone: input.Telephone,
		Password:  input.Password,
		Role:      services.RoleFromString(input.Role),
	}
	if input.Email != "" {
		req.Email = &input.Email
	}

	result, err := h.authService.Register(c.Request.Context(), req, deviceInfo, ipAddress, userAgent)
	if err != nil {
		response.Error(c, http.StatusConflict, "REGISTRATION_FAILED", err.Error())
		return
	}

	response.Created(c, "Inscription réussie", result)
}

func (h *AuthHandler) Login(c *gin.Context) {
	var input loginInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides")
		return
	}

	deviceInfo := c.GetHeader("User-Agent")
	ipAddress := c.ClientIP()
	userAgent := c.GetHeader("User-Agent")

	result, err := h.authService.Login(c.Request.Context(), services.LoginRequest{
		Telephone: input.Telephone,
		Password:  input.Password,
	}, deviceInfo, ipAddress, userAgent)
	if err != nil {
		response.Error(c, http.StatusUnauthorized, "LOGIN_FAILED", err.Error())
		return
	}

	response.OK(c, "Connexion réussie", result)
}

func (h *AuthHandler) RefreshToken(c *gin.Context) {
	var input refreshInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Refresh token requis")
		return
	}

	deviceInfo := c.GetHeader("User-Agent")
	ipAddress := c.ClientIP()
	userAgent := c.GetHeader("User-Agent")

	result, err := h.authService.RefreshToken(c.Request.Context(), input.RefreshToken, deviceInfo, ipAddress, userAgent)
	if err != nil {
		response.Error(c, http.StatusUnauthorized, "REFRESH_FAILED", err.Error())
		return
	}

	response.OK(c, "Token rafraîchi", result)
}

func (h *AuthHandler) Logout(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	var input struct {
		RefreshToken string `json:"refreshToken"`
	}
	c.ShouldBindJSON(&input)

	if err := h.authService.Logout(c.Request.Context(), userID, input.RefreshToken); err != nil {
		response.InternalError(c, "Erreur lors de la déconnexion")
		return
	}

	response.OK(c, "Déconnexion réussie", nil)
}

func (h *AuthHandler) LogoutAll(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	if err := h.authService.LogoutAll(c.Request.Context(), userID); err != nil {
		response.InternalError(c, "Erreur lors de la déconnexion")
		return
	}

	response.OK(c, "Déconnexion de tous les appareils réussie", nil)
}

func (h *AuthHandler) SendOTP(c *gin.Context) {
	var input sendOTPInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides")
		return
	}

	code, err := h.authService.SendOTP(c.Request.Context(), input.Identifier, input.Purpose)
	if err != nil {
		response.InternalError(c, "Erreur lors de l'envoi du code")
		return
	}

	response.OK(c, "Code envoyé", gin.H{
		"code": code,
	})
}

func (h *AuthHandler) VerifyOTP(c *gin.Context) {
	var input verifyOTPInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides")
		return
	}

	if err := h.authService.VerifyOTP(c.Request.Context(), input.Identifier, input.Code, input.Purpose); err != nil {
		response.Error(c, http.StatusBadRequest, "OTP_INVALID", err.Error())
		return
	}

	response.OK(c, "Code vérifié avec succès", nil)
}

func (h *AuthHandler) ChangePassword(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	var input changePasswordInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides")
		return
	}

	if err := h.authService.ChangePassword(c.Request.Context(), userID, input.OldPassword, input.NewPassword); err != nil {
		response.Error(c, http.StatusBadRequest, "PASSWORD_FAILED", err.Error())
		return
	}

	response.OK(c, "Mot de passe changé avec succès", nil)
}

func (h *AuthHandler) ResetPassword(c *gin.Context) {
	var input resetPasswordInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides")
		return
	}

	if err := h.authService.ResetPassword(c.Request.Context(), input.Telephone, input.OTPCode, input.NewPassword); err != nil {
		response.Error(c, http.StatusBadRequest, "RESET_FAILED", err.Error())
		return
	}

	response.OK(c, "Mot de passe réinitialisé avec succès", nil)
}

func (h *AuthHandler) GetProfile(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	user, err := h.authService.GetProfile(c.Request.Context(), userID)
	if err != nil {
		response.NotFound(c, "Utilisateur non trouvé")
		return
	}

	response.OK(c, "Profil récupéré", user)
}

func (h *AuthHandler) Me(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	user, err := h.authService.GetProfile(c.Request.Context(), userID)
	if err != nil {
		response.NotFound(c, "Utilisateur non trouvé")
		return
	}

	response.OK(c, "Profil récupéré", user)
}
