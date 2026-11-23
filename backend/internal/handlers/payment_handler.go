package handlers

import (
	"fmt"
	"math/rand"
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

type PaymentHandler struct {
	paymentRepo *repository.PaymentRepository
	bookingRepo *repository.BookingRepository
	notifier    *services.Notifier
}

func NewPaymentHandler(paymentRepo *repository.PaymentRepository, bookingRepo *repository.BookingRepository, notifier *services.Notifier) *PaymentHandler {
	return &PaymentHandler{paymentRepo: paymentRepo, bookingRepo: bookingRepo, notifier: notifier}
}

type createPaymentInput struct {
	BookingID   string  `json:"bookingId" binding:"required"`
	Method      string  `json:"method" binding:"required"`
	PhoneNumber *string `json:"phoneNumber"`
}

var validPaymentMethods = map[models.PaymentMethod]bool{
	models.PayMethodMTN: true, models.PayMethodMoov: true, models.PayMethodWave: true,
	models.PayMethodCard: true, models.PayMethodCash: true, models.PayMethodCinet: true,
}

// Create enregistre le paiement d'une réservation et simule le fournisseur
// de paiement mobile money (MTN MoMo / Moov / Wave). Le point d'intégration
// réel du fournisseur se situe ici.
func (h *PaymentHandler) Create(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	var input createPaymentInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides")
		return
	}

	method := models.PaymentMethod(input.Method)
	if !validPaymentMethods[method] {
		response.BadRequest(c, "Méthode de paiement invalide")
		return
	}

	bookingID, err := uuid.Parse(input.BookingID)
	if err != nil {
		response.BadRequest(c, "ID de réservation invalide")
		return
	}

	booking, err := h.bookingRepo.FindByID(c.Request.Context(), bookingID)
	if err != nil {
		response.NotFound(c, "Réservation non trouvée")
		return
	}

	if booking.VoyageurID != userID {
		response.Forbidden(c, "Vous ne pouvez pas payer cette réservation")
		return
	}

	if booking.IsPaid {
		response.Error(c, http.StatusConflict, "ALREADY_PAID", "Cette réservation est déjà payée")
		return
	}

	if booking.Status == models.BookingCancelled {
		response.Error(c, http.StatusConflict, "BOOKING_CANCELLED", "Cette réservation a été annulée")
		return
	}

	if method == models.PayMethodMTN || method == models.PayMethodMoov || method == models.PayMethodWave {
		if input.PhoneNumber == nil || *input.PhoneNumber == "" {
			response.BadRequest(c, "Numéro de téléphone requis pour le paiement mobile")
			return
		}
	}

	providerRef := fmt.Sprintf("FLEX-%d-%04d", time.Now().Unix(), rand.Intn(10000))
	now := time.Now().UTC()

	payment := &models.Payment{
		BookingID:   booking.ID,
		UserID:      userID,
		Amount:      booking.MontantTotal,
		Currency:    "XOF",
		Method:      method,
		Status:      models.PayStatusCompleted,
		ProviderRef: &providerRef,
		PhoneNumber: input.PhoneNumber,
		PaidAt:      &now,
	}

	if err := h.paymentRepo.Create(c.Request.Context(), payment); err != nil {
		response.InternalError(c, "Erreur lors de l'enregistrement du paiement")
		return
	}

	paymentMethod := method
	updates := map[string]interface{}{
		"is_paid":         true,
		"payment_status":  models.PayStatusCompleted,
		"payment_method":  paymentMethod,
		"transaction_id":  providerRef,
	}
	if err := h.bookingRepo.UpdateFields(c.Request.Context(), booking.ID, updates); err != nil {
		response.InternalError(c, "Erreur lors de la mise à jour de la réservation")
		return
	}

	ref := booking.ID.String()
	h.notifier.Notify(c.Request.Context(), booking.HoteID, models.NotifPaymentReceived,
		"Paiement reçu",
		"Le paiement de la réservation pour "+booking.Listing.Titre+" a été reçu", &ref)

	booking.IsPaid = true
	booking.PaymentStatus = models.PayStatusCompleted
	booking.PaymentMethod = &paymentMethod
	booking.TransactionID = &providerRef

	response.Created(c, "Paiement effectué avec succès", gin.H{
		"payment": payment,
		"booking": booking,
	})
}

func (h *PaymentHandler) ListMine(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	payments, err := h.paymentRepo.FindByUserID(c.Request.Context(), userID)
	if err != nil {
		response.InternalError(c, "Erreur lors de la récupération des paiements")
		return
	}

	response.OK(c, "Mes paiements", payments)
}

func (h *PaymentHandler) GetByID(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID invalide")
		return
	}

	userID, _ := middleware.GetUserID(c)
	role, _ := middleware.GetRole(c)

	payment, err := h.paymentRepo.FindByID(c.Request.Context(), id)
	if err != nil {
		response.NotFound(c, "Paiement non trouvé")
		return
	}

	if payment.UserID != userID && role != "agent" {
		response.Forbidden(c, "Accès refusé")
		return
	}

	response.OK(c, "Détails du paiement", payment)
}

type paymentWebhookInput struct {
	TransactionID string `json:"transaction_id" binding:"required"`
	Status        string `json:"status" binding:"required"` // "APPROVED", "FAILED", "SUCCESS"
	ProviderRef   string `json:"provider_ref"`
	Method        string `json:"method"`
}

// HandleWebhook reçoit les callbacks asynchrones des agrégateurs (FedaPay, Moov, MTN MoMo, Wave)
func (h *PaymentHandler) HandleWebhook(c *gin.Context) {
	var input paymentWebhookInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Payload webhook invalide")
		return
	}

	status := models.PayStatusCompleted
	if input.Status == "FAILED" || input.Status == "CANCELLED" {
		status = models.PayStatusFailed
	}

	response.OK(c, "Webhook traité avec succès", gin.H{
		"transaction_id": input.TransactionID,
		"status":         status,
		"processed":      true,
	})
}

