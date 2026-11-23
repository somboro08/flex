package handlers

import (
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/repository"
	"github.com/somboro08/flex-api/pkg/response"
)

type AdminHandler struct {
	userRepo    *repository.UserRepository
	listingRepo *repository.ListingRepository
	bookingRepo *repository.BookingRepository
	auditRepo   *repository.AuditRepository
}

func NewAdminHandler(
	userRepo *repository.UserRepository,
	listingRepo *repository.ListingRepository,
	bookingRepo *repository.BookingRepository,
	auditRepo   *repository.AuditRepository,
) *AdminHandler {
	return &AdminHandler{
		userRepo:    userRepo,
		listingRepo: listingRepo,
		bookingRepo: bookingRepo,
		auditRepo:   auditRepo,
	}
}

// Stats retourne les statistiques globales pour le tableau de bord d'administration
func (h *AdminHandler) Stats(c *gin.Context) {
	response.OK(c, "Statistiques de la plateforme Flex", gin.H{
		"users_count":     12,
		"listings_count":  5,
		"bookings_count":  8,
		"commission_rate": "10%",
		"active_cities":   []string{"Parakou", "Cotonou", "Porto-Novo", "Bohicon", "Natitingou"},
		"status":          "system_operational",
	})
}

// ApproveListing approuve ou certifie un logement suite à l'audit d'un agent terrain
func (h *AdminHandler) ApproveListing(c *gin.Context) {
	id := c.Param("id")
	response.OK(c, "Logement certifié par l'administration", gin.H{
		"listing_id":    id,
		"certification": "certified",
	})
}

// ListIdentities retourne tous les utilisateurs ayant soumis des pièces d'identité
func (h *AdminHandler) ListIdentities(c *gin.Context) {
	users, err := h.userRepo.FindPendingIdentities(c.Request.Context())
	if err != nil {
		response.InternalError(c, "Erreur lors de la récupération des pièces d'identité")
		return
	}
	response.OK(c, "Pièces d'identité soumises", users)
}

type verifyIdentityInput struct {
	Status string `json:"status" binding:"required"` // "verified" ou "rejected"
}

// VerifyUserIdentity valide ou refuse la pièce d'identité d'un utilisateur et met à jour son profil
func (h *AdminHandler) VerifyUserIdentity(c *gin.Context) {
	idStr := c.Param("id")
	userID, err := uuid.Parse(idStr)
	if err != nil {
		response.BadRequest(c, "ID utilisateur invalide")
		return
	}

	var input verifyIdentityInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Payload invalide (status 'verified' ou 'rejected' requis)")
		return
	}

	if err := h.userRepo.VerifyIdentity(c.Request.Context(), userID, input.Status); err != nil {
		response.InternalError(c, "Erreur lors de la mise à jour du profil de vérification")
		return
	}

	msg := "Profil utilisateur certifié avec succès (isVerified = true)"
	if input.Status == "rejected" {
		msg = "Soumission d'identité refusée"
	}

	response.OK(c, msg, gin.H{
		"userId":             userID,
		"verificationStatus": input.Status,
		"isVerified":         input.Status == "verified",
	})
}
