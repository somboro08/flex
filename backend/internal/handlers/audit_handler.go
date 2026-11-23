package handlers

import (
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/middleware"
	"github.com/somboro08/flex-api/internal/models"
	"github.com/somboro08/flex-api/internal/repository"
	"github.com/somboro08/flex-api/pkg/response"
)

type AuditHandler struct {
	auditRepo   *repository.AuditRepository
	listingRepo *repository.ListingRepository
}

func NewAuditHandler(auditRepo *repository.AuditRepository, listingRepo *repository.ListingRepository) *AuditHandler {
	return &AuditHandler{auditRepo: auditRepo, listingRepo: listingRepo}
}

type createAuditInput struct {
	ListingID     string `json:"listingId" binding:"required"`
	Serrure       bool   `json:"serrure"`
	Literie       bool   `json:"literie"`
	Sanitaires    bool   `json:"sanitaires"`
	Eclairage     bool   `json:"eclairage"`
	Identite      bool   `json:"identite"`
	PhotosFideles bool   `json:"photosFideles"`
	Adresse       bool   `json:"adresse"`
	Commentaires  string `json:"commentaires"`
}

func (h *AuditHandler) Create(c *gin.Context) {
	agentID, _ := middleware.GetUserID(c)

	var input createAuditInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides: "+err.Error())
		return
	}

	listingID, err := uuid.Parse(input.ListingID)
	if err != nil {
		response.BadRequest(c, "ID du logement invalide")
		return
	}

	_, err = h.listingRepo.FindByID(c.Request.Context(), listingID)
	if err != nil {
		response.NotFound(c, "Logement non trouvé")
		return
	}

	audit := &models.Audit{
		ListingID:     listingID,
		AgentID:       agentID,
		Serrure:       input.Serrure,
		Literie:       input.Literie,
		Sanitaires:    input.Sanitaires,
		Eclairage:     input.Eclairage,
		Identite:      input.Identite,
		PhotosFideles: input.PhotosFideles,
		Adresse:       input.Adresse,
	}
	if input.Commentaires != "" {
		audit.Commentaires = &input.Commentaires
	}

	if err := h.auditRepo.Create(c.Request.Context(), audit); err != nil {
		response.InternalError(c, "Erreur lors de la création de l'audit")
		return
	}

	response.Created(c, "Audit créé avec succès", audit)
}
