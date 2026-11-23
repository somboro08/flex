package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/middleware"
	"github.com/somboro08/flex-api/internal/models"
	"github.com/somboro08/flex-api/internal/repository"
	"github.com/somboro08/flex-api/internal/services"
	"github.com/somboro08/flex-api/pkg/response"
)

type VisitHandler struct {
	visitRepo   *repository.VisitRepository
	listingRepo *repository.ListingRepository
	notifier    *services.Notifier
}

func NewVisitHandler(visitRepo *repository.VisitRepository, listingRepo *repository.ListingRepository, notifier *services.Notifier) *VisitHandler {
	return &VisitHandler{visitRepo: visitRepo, listingRepo: listingRepo, notifier: notifier}
}

type createVisitInput struct {
	ListingID  string `json:"listingId" binding:"required"`
	DateVisite string `json:"dateVisite" binding:"required"`
	TimeSlot   string `json:"timeSlot" binding:"required"`
	Message    string `json:"message"`
}

func (h *VisitHandler) Create(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	var input createVisitInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides: "+err.Error())
		return
	}

	listingID, err := uuid.Parse(input.ListingID)
	if err != nil {
		response.BadRequest(c, "ID du logement invalide")
		return
	}

	listing, err := h.listingRepo.FindByID(c.Request.Context(), listingID)
	if err != nil {
		response.NotFound(c, "Logement non trouvé")
		return
	}

	if listing.HoteID == userID {
		response.Error(c, http.StatusConflict, "SAME_USER", "Vous ne pouvez pas demander une visite pour votre propre logement")
		return
	}

	dateVisite, err := time.Parse("2006-01-02", input.DateVisite)
	if err != nil {
		response.BadRequest(c, "Date de visite invalide (format: YYYY-MM-DD)")
		return
	}

	visit := &models.Visit{
		ListingID:  listingID,
		VoyageurID: userID,
		HoteID:     listing.HoteID,
		DateVisite: dateVisite,
		TimeSlot:   input.TimeSlot,
		Message:    input.Message,
		Status:     models.VisitPending,
	}

	if err := h.visitRepo.Create(c.Request.Context(), visit); err != nil {
		response.InternalError(c, "Erreur lors de la création de la demande de visite")
		return
	}

	ref := visit.ID.String()
	h.notifier.Notify(c.Request.Context(), visit.HoteID, models.NotifVisitReceived,
		"Nouvelle demande de visite",
		"Un voyageur souhaite visiter "+listing.Titre, &ref)

	response.Created(c, "Demande de visite créée avec succès", visit)
}

func (h *VisitHandler) ListMyVisits(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)
	role, _ := middleware.GetRole(c)

	var visits []models.Visit
	var err error

	if role == "hote" {
		visits, err = h.visitRepo.FindByHoteID(c.Request.Context(), userID)
	} else {
		visits, err = h.visitRepo.FindByVoyageurID(c.Request.Context(), userID)
	}

	if err != nil {
		response.InternalError(c, "Erreur lors de la récupération des visites")
		return
	}

	response.OK(c, "Mes visites", visits)
}

func (h *VisitHandler) Confirm(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID invalide")
		return
	}

	visit, err := h.visitRepo.FindByID(c.Request.Context(), id)
	if err != nil {
		response.NotFound(c, "Demande de visite non trouvée")
		return
	}

	userID, _ := middleware.GetUserID(c)
	if visit.HoteID != userID {
		response.Error(c, http.StatusForbidden, "FORBIDDEN", "Vous n'êtes pas l'hôte de cette visite")
		return
	}

	if err := h.visitRepo.UpdateStatus(c.Request.Context(), id, models.VisitConfirmed); err != nil {
		response.InternalError(c, "Erreur de mise à jour de la visite")
		return
	}

	ref := id.String()
	h.notifier.Notify(c.Request.Context(), visit.VoyageurID, models.NotifVisitConfirmed,
		"Visite confirmée",
		"Votre demande de visite a été confirmée par l'hôte", &ref)

	response.OK(c, "Visite confirmée", nil)
}

func (h *VisitHandler) Cancel(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID invalide")
		return
	}

	visit, err := h.visitRepo.FindByID(c.Request.Context(), id)
	if err != nil {
		response.NotFound(c, "Demande de visite non trouvée")
		return
	}

	userID, _ := middleware.GetUserID(c)
	if visit.VoyageurID != userID && visit.HoteID != userID {
		response.Error(c, http.StatusForbidden, "FORBIDDEN", "Vous n'êtes pas autorisé à annuler cette visite")
		return
	}

	if err := h.visitRepo.UpdateStatus(c.Request.Context(), id, models.VisitCancelled); err != nil {
		response.InternalError(c, "Erreur lors de l'annulation")
		return
	}

	ref := id.String()
	if visit.VoyageurID == userID {
		h.notifier.Notify(c.Request.Context(), visit.HoteID, models.NotifVisitCancelled,
			"Visite annulée",
			"Le voyageur a annulé sa demande de visite", &ref)
	} else {
		h.notifier.Notify(c.Request.Context(), visit.VoyageurID, models.NotifVisitCancelled,
			"Visite annulée",
			"Votre demande de visite a été annulée par l'hôte", &ref)
	}

	response.OK(c, "Visite annulée", nil)
}
