package handlers

import (
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/middleware"
	"github.com/somboro08/flex-api/internal/models"
	"github.com/somboro08/flex-api/internal/repository"
	"github.com/somboro08/flex-api/internal/services"
	"github.com/somboro08/flex-api/pkg/response"
)

type ReviewHandler struct {
	reviewRepo  *repository.ReviewRepository
	bookingRepo *repository.BookingRepository
	notifier    *services.Notifier
}

func NewReviewHandler(reviewRepo *repository.ReviewRepository, bookingRepo *repository.BookingRepository, notifier *services.Notifier) *ReviewHandler {
	return &ReviewHandler{reviewRepo: reviewRepo, bookingRepo: bookingRepo, notifier: notifier}
}

type createReviewInput struct {
	BookingID   string `json:"bookingId" binding:"required"`
	ListingID   string `json:"listingId" binding:"required"`
	Note        int    `json:"note" binding:"required"`
	Commentaire string `json:"commentaire"`
}

func (h *ReviewHandler) Create(c *gin.Context) {
	voyageurID, _ := middleware.GetUserID(c)

	var input createReviewInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides: "+err.Error())
		return
	}

	if input.Note < 1 || input.Note > 5 {
		response.BadRequest(c, "La note doit être comprise entre 1 et 5")
		return
	}

	bookingID, err := uuid.Parse(input.BookingID)
	if err != nil {
		response.BadRequest(c, "ID de réservation invalide")
		return
	}

	listingID, err := uuid.Parse(input.ListingID)
	if err != nil {
		response.BadRequest(c, "ID du logement invalide")
		return
	}

	booking, err := h.bookingRepo.FindByID(c.Request.Context(), bookingID)
	if err != nil {
		response.NotFound(c, "Réservation non trouvée")
		return
	}

	if booking.VoyageurID != voyageurID {
		response.Forbidden(c, "Vous ne pouvez évaluer que vos propres réservations")
		return
	}

	if booking.ListingID != listingID {
		response.BadRequest(c, "Le logement ne correspond pas à la réservation")
		return
	}

	if booking.Status != models.BookingCompleted {
		response.Error(c, 409, "BOOKING_NOT_COMPLETED", "Vous pouvez évaluer uniquement après le séjour")
		return
	}

	review := &models.Review{
		BookingID:  bookingID,
		VoyageurID: voyageurID,
		ListingID:  listingID,
		Note:       input.Note,
	}
	if input.Commentaire != "" {
		review.Commentaire = &input.Commentaire
	}

	if err := h.reviewRepo.Create(c.Request.Context(), review); err != nil {
		response.InternalError(c, "Erreur lors de l'enregistrement de l'avis")
		return
	}

	ref := review.ID.String()
	h.notifier.Notify(c.Request.Context(), booking.HoteID, models.NotifReviewReceived,
		"Nouvel avis",
		"Vous avez reçu un avis sur "+booking.Listing.Titre, &ref)

	response.Created(c, "Avis enregistré avec succès", review)
}

func (h *ReviewHandler) GetByListingID(c *gin.Context) {
	listingID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID de logement invalide")
		return
	}

	reviews, err := h.reviewRepo.FindByListingID(c.Request.Context(), listingID)
	if err != nil {
		response.InternalError(c, "Erreur lors de la récupération des avis")
		return
	}

	response.OK(c, "Avis du logement", reviews)
}
