package handlers

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/middleware"
	"github.com/somboro08/flex-api/internal/models"
	"github.com/somboro08/flex-api/internal/repository"
	"github.com/somboro08/flex-api/internal/services"
	"github.com/somboro08/flex-api/pkg/response"
)

type AuthHandler struct {
	authService *services.AuthService
	userRepo    *repository.UserRepository
	listingRepo *repository.ListingRepository
}

func NewAuthHandler(authService *services.AuthService, userRepo *repository.UserRepository, listingRepo *repository.ListingRepository) *AuthHandler {
	return &AuthHandler{authService: authService, userRepo: userRepo, listingRepo: listingRepo}
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
	Identifier  string `json:"identifier"`
	Telephone   string `json:"telephone"`
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
		if errors.Is(err, services.ErrPhoneAlreadyUsed) || errors.Is(err, services.ErrEmailAlreadyUsed) {
			response.Error(c, http.StatusConflict, "ALREADY_EXISTS", err.Error())
			return
		}
		response.Error(c, http.StatusBadRequest, "REGISTRATION_FAILED", err.Error())
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

	// En production, le code est transmis par SMS/e-mail via les services dédiés.
	// En développement, on le retourne pour faciliter les tests.
	if h.authService.IsDevelopment() {
		response.OK(c, "Code envoyé", gin.H{
			"code": code,
		})
		return
	}
	response.OK(c, "Code envoyé", nil)
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

	if err := h.authService.ResetPassword(c.Request.Context(), input.Identifier, input.OTPCode, input.NewPassword); err != nil {
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

type updateProfileInput struct {
	Nom       string  `json:"nom"`
	Prenom    string  `json:"prenom"`
	Telephone string  `json:"telephone"`
	Email     *string `json:"email"`
	PhotoURL  *string `json:"photoUrl"`
}

func (h *AuthHandler) UpdateProfile(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	var input updateProfileInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides: "+err.Error())
		return
	}

	fields := map[string]interface{}{}
	if input.Nom != "" {
		fields["nom"] = input.Nom
	}
	if input.Prenom != "" {
		fields["prenom"] = input.Prenom
	}
	if input.Telephone != "" {
		fields["telephone"] = input.Telephone
	}
	if input.Email != nil {
		fields["email"] = input.Email
	}
	if input.PhotoURL != nil {
		fields["photo_url"] = input.PhotoURL
	}

	if err := h.authService.UpdateProfile(c.Request.Context(), userID, fields); err != nil {
		response.InternalError(c, "Erreur lors de la mise à jour du profil")
		return
	}

	user, _ := h.authService.GetProfile(c.Request.Context(), userID)
	response.OK(c, "Profil mis à jour", user)
}

type submitIdentityInput struct {
	IDCardURL           string `json:"idCardUrl"`
	BirthCertificateURL string `json:"birthCertificateUrl"`
}

func (h *AuthHandler) SubmitIdentity(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	var input submitIdentityInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides")
		return
	}

	fields := map[string]interface{}{
		"verification_status": "pending",
	}
	if input.IDCardURL != "" {
		fields["id_card_url"] = input.IDCardURL
	}
	if input.BirthCertificateURL != "" {
		fields["birth_certificate_url"] = input.BirthCertificateURL
	}

	if err := h.authService.UpdateProfile(c.Request.Context(), userID, fields); err != nil {
		response.InternalError(c, "Erreur lors de la soumission des documents")
		return
	}

	response.OK(c, "Documents soumis — vérification en cours", nil)
}

type changeRoleInput struct {
	Role string `json:"role" binding:"required"`
}

// ChangeRole permet à un utilisateur de devenir propriétaire (hote).
func (h *AuthHandler) ChangeRole(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	var input changeRoleInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides")
		return
	}

	user, err := h.authService.ChangeRole(c.Request.Context(), userID, models.UserRole(input.Role))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "ROLE_CHANGE_FAILED", err.Error())
		return
	}

	response.OK(c, "Rôle mis à jour", user)
}

// AddFavorite enregistre un logement dans les favoris de l'utilisateur.
func (h *AuthHandler) AddFavorite(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	listingID, err := uuid.Parse(c.Param("listingId"))
	if err != nil {
		response.BadRequest(c, "ID du logement invalide")
		return
	}

	if _, err := h.listingRepo.FindByID(c.Request.Context(), listingID); err != nil {
		response.NotFound(c, "Logement non trouvé")
		return
	}

	if err := h.userRepo.AddFavorite(c.Request.Context(), userID, listingID); err != nil {
		response.InternalError(c, "Erreur lors de l'ajout aux favoris")
		return
	}

	response.OK(c, "Ajouté aux favoris", nil)
}

// RemoveFavorite retire un logement des favoris de l'utilisateur.
func (h *AuthHandler) RemoveFavorite(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	listingID, err := uuid.Parse(c.Param("listingId"))
	if err != nil {
		response.BadRequest(c, "ID du logement invalide")
		return
	}

	if err := h.userRepo.RemoveFavorite(c.Request.Context(), userID, listingID); err != nil {
		response.InternalError(c, "Erreur lors du retrait des favoris")
		return
	}

	response.OK(c, "Retiré des favoris", nil)
}

// ListFavorites renvoie les logements favoris de l'utilisateur.
func (h *AuthHandler) ListFavorites(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	user, err := h.userRepo.FindByID(c.Request.Context(), userID)
	if err != nil {
		response.NotFound(c, "Utilisateur non trouvé")
		return
	}

	favIDs := make([]uuid.UUID, 0, len(user.Favorites))
	for _, fav := range user.Favorites {
		id, err := uuid.Parse(fav)
		if err == nil {
			favIDs = append(favIDs, id)
		}
	}

	listings, err := h.listingRepo.FindByIDs(c.Request.Context(), favIDs)
	if err != nil {
		response.InternalError(c, "Erreur lors de la récupération des favoris")
		return
	}

	response.OK(c, "Mes favoris", listings)
}
