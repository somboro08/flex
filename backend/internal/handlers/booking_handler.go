package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/middleware"
	"github.com/somboro08/flex-api/internal/models"
	"github.com/somboro08/flex-api/internal/repository"
	"github.com/somboro08/flex-api/pkg/response"
)

type BookingHandler struct {
	bookingRepo *repository.BookingRepository
	listingRepo *repository.ListingRepository
}

func NewBookingHandler(bookingRepo *repository.BookingRepository, listingRepo *repository.ListingRepository) *BookingHandler {
	return &BookingHandler{bookingRepo: bookingRepo, listingRepo: listingRepo}
}

type createBookingInput struct {
	ListingID   string `json:"listingId" binding:"required"`
	DateArrivee string `json:"dateArrivee" binding:"required"`
	DateDepart  string `json:"dateDepart" binding:"required"`
}

func (h *BookingHandler) Create(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	var input createBookingInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides")
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

	if !listing.IsDisponible {
		response.Error(c, http.StatusConflict, "NOT_AVAILABLE", "Ce logement n'est pas disponible")
		return
	}

	if listing.HoteID == userID {
		response.Error(c, http.StatusConflict, "SAME_USER", "Vous ne pouvez pas réserver votre propre logement")
		return
	}

	dateArrivee, err := time.Parse("2006-01-02", input.DateArrivee)
	if err != nil {
		response.BadRequest(c, "Date d'arrivée invalide (format: YYYY-MM-DD)")
		return
	}
	dateDepart, err := time.Parse("2006-01-02", input.DateDepart)
	if err != nil {
		response.BadRequest(c, "Date de départ invalide (format: YYYY-MM-DD)")
		return
	}

	nuits := int(dateDepart.Sub(dateArrivee).Hours() / 24)
	if nuits <= 0 {
		response.BadRequest(c, "La date de départ doit être après la date d'arrivée")
		return
	}

	booking := &models.Booking{
		VoyageurID:  userID,
		ListingID:   listingID,
		HoteID:      listing.HoteID,
		DateArrivee: dateArrivee,
		DateDepart:  dateDepart,
		NombreNuits: nuits,
		MontantTotal: listing.PrixParNuit * float64(nuits),
		Status:      models.BookingPending,
	}

	if err := h.bookingRepo.Create(c.Request.Context(), booking); err != nil {
		response.InternalError(c, "Erreur lors de la création de la réservation")
		return
	}

	response.Created(c, "Réservation créée avec succès", booking)
}

func (h *BookingHandler) GetByID(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID invalide")
		return
	}

	booking, err := h.bookingRepo.FindByID(c.Request.Context(), id)
	if err != nil {
		response.NotFound(c, "Réservation non trouvée")
		return
	}

	response.OK(c, "Détails de la réservation", booking)
}

func (h *BookingHandler) ListMyBookings(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)
	role, _ := middleware.GetRole(c)

	var bookings []models.Booking
	var err error

	if role == "hote" {
		bookings, err = h.bookingRepo.FindByHoteID(c.Request.Context(), userID)
	} else {
		bookings, err = h.bookingRepo.FindByVoyageurID(c.Request.Context(), userID)
	}

	if err != nil {
		response.InternalError(c, "Erreur lors de la récupération")
		return
	}

	response.OK(c, "Mes réservations", bookings)
}

func (h *BookingHandler) Cancel(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID invalide")
		return
	}

	userID, _ := middleware.GetUserID(c)

	if err := h.bookingRepo.Cancel(c.Request.Context(), id, userID); err != nil {
		response.Error(c, http.StatusConflict, "CANCEL_FAILED", err.Error())
		return
	}

	response.OK(c, "Réservation annulée", nil)
}

func (h *BookingHandler) Confirm(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID invalide")
		return
	}

	if err := h.bookingRepo.Confirm(c.Request.Context(), id); err != nil {
		response.Error(c, http.StatusConflict, "CONFIRM_FAILED", err.Error())
		return
	}

	response.OK(c, "Réservation confirmée", nil)
}
