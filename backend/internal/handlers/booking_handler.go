package handlers

import (
	"fmt"
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

type BookingHandler struct {
	bookingRepo *repository.BookingRepository
	listingRepo *repository.ListingRepository
	notifier    *services.Notifier
}

func NewBookingHandler(bookingRepo *repository.BookingRepository, listingRepo *repository.ListingRepository, notifier *services.Notifier) *BookingHandler {
	return &BookingHandler{bookingRepo: bookingRepo, listingRepo: listingRepo, notifier: notifier}
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

	dateArrivee, err := parseFlexibleDate(input.DateArrivee)
	if err != nil {
		response.BadRequest(c, "Date d'arrivée invalide (formats acceptés: YYYY-MM-DD ou ISO8601)")
		return
	}
	dateDepart, err := parseFlexibleDate(input.DateDepart)
	if err != nil {
		response.BadRequest(c, "Date de départ invalide (formats acceptés: YYYY-MM-DD ou ISO8601)")
		return
	}

	nuits := int(dateDepart.Sub(dateArrivee).Hours() / 24)
	if nuits <= 0 {
		response.BadRequest(c, "La date de départ doit être après la date d'arrivée")
		return
	}

	if dateArrivee.Before(time.Now().UTC().Truncate(24 * time.Hour)) {
		response.BadRequest(c, "La date d'arrivée doit être dans le futur")
		return
	}

	existing, err := h.bookingRepo.FindByListingID(c.Request.Context(), listingID)
	if err == nil {
		for _, b := range existing {
			if b.Status == models.BookingCancelled {
				continue
			}
			if dateArrivee.Before(b.DateDepart) && dateDepart.After(b.DateArrivee) {
				response.Error(c, http.StatusConflict, "DATES_UNAVAILABLE", "Le logement est déjà réservé sur cette période")
				return
			}
		}
	}

	booking := &models.Booking{
		VoyageurID:   userID,
		ListingID:    listingID,
		HoteID:       listing.HoteID,
		DateArrivee:  dateArrivee,
		DateDepart:   dateDepart,
		NombreNuits:  nuits,
		MontantTotal: listing.PrixParNuit * float64(nuits),
		Status:       models.BookingPending,
	}

	if err := h.bookingRepo.Create(c.Request.Context(), booking); err != nil {
		response.InternalError(c, "Erreur lors de la création de la réservation")
		return
	}

	ref := booking.ID.String()
	h.notifier.Notify(c.Request.Context(), booking.HoteID, models.NotifBookingReceived,
		"Nouvelle demande de réservation",
		"Vous avez reçu une demande pour "+listing.Titre, &ref)

	response.Created(c, "Réservation créée avec succès", booking)
}

func (h *BookingHandler) GetByID(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID invalide")
		return
	}

	userID, _ := middleware.GetUserID(c)
	role, _ := middleware.GetRole(c)

	booking, err := h.bookingRepo.FindByID(c.Request.Context(), id)
	if err != nil {
		response.NotFound(c, "Réservation non trouvée")
		return
	}

	if booking.VoyageurID != userID && booking.HoteID != userID && role != "agent" {
		response.Forbidden(c, "Accès refusé")
		return
	}

	response.OK(c, "Détails de la réservation", booking)
}

func (h *BookingHandler) ListMyBookings(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)
	role, _ := middleware.GetRole(c)

	var bookings []models.Booking
	var err error

	if role == "hote" || role == "agent" {
		bookings, err = h.bookingRepo.FindByHoteID(c.Request.Context(), userID)
		if err == nil && role == "agent" {
			voyageurBookings, verr := h.bookingRepo.FindByVoyageurID(c.Request.Context(), userID)
			if verr == nil {
				bookings = append(bookings, voyageurBookings...)
			}
		}
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

	booking, err := h.bookingRepo.FindByID(c.Request.Context(), id)
	if err != nil {
		response.NotFound(c, "Réservation non trouvée")
		return
	}

	if err := h.bookingRepo.Cancel(c.Request.Context(), id, userID); err != nil {
		response.Error(c, http.StatusConflict, "CANCEL_FAILED", err.Error())
		return
	}

	ref := id.String()
	if booking.VoyageurID == userID {
		h.notifier.Notify(c.Request.Context(), booking.HoteID, models.NotifBookingCancelled,
			"Réservation annulée",
			"Un voyageur a annulé sa réservation pour "+booking.Listing.Titre, &ref)
	} else {
		h.notifier.Notify(c.Request.Context(), booking.VoyageurID, models.NotifBookingCancelled,
			"Réservation annulée",
			"Votre réservation pour "+booking.Listing.Titre+" a été annulée", &ref)
	}

	response.OK(c, "Réservation annulée", nil)
}

func (h *BookingHandler) Confirm(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID invalide")
		return
	}

	userID, _ := middleware.GetUserID(c)
	role, _ := middleware.GetRole(c)

	if role != "hote" && role != "agent" {
		response.Forbidden(c, "Seul le propriétaire peut confirmer une réservation")
		return
	}

	booking, err := h.bookingRepo.FindByID(c.Request.Context(), id)
	if err != nil {
		response.NotFound(c, "Réservation non trouvée")
		return
	}

	if booking.HoteID != userID && role != "agent" {
		response.Forbidden(c, "Vous n'êtes pas le propriétaire de ce logement")
		return
	}

	if err := h.bookingRepo.Confirm(c.Request.Context(), id); err != nil {
		response.Error(c, http.StatusConflict, "CONFIRM_FAILED", err.Error())
		return
	}

	ref := id.String()
	h.notifier.Notify(c.Request.Context(), booking.VoyageurID, models.NotifBookingConfirmed,
		"Réservation confirmée",
		"Votre réservation pour "+booking.Listing.Titre+" est confirmée", &ref)

	response.OK(c, "Réservation confirmée", nil)
}

func parseFlexibleDate(dateStr string) (time.Time, error) {
	formats := []string{
		"2006-01-02",
		time.RFC3339,
		"2006-01-02T15:04:05.000Z",
		"2006-01-02T15:04:05.000",
		"2006-01-02T15:04:05",
		"2006-01-02 15:04:05",
	}
	for _, fmtStr := range formats {
		if t, err := time.Parse(fmtStr, dateStr); err == nil {
			return t, nil
		}
	}
	return time.Time{}, fmt.Errorf("invalid date format: %s", dateStr)
}
