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

type RentalHandler struct {
	rentalRepo  *repository.RentalRepository
	listingRepo *repository.ListingRepository
	userRepo    *repository.UserRepository
	notifier    *services.Notifier
}

func NewRentalHandler(rentalRepo *repository.RentalRepository, listingRepo *repository.ListingRepository, userRepo *repository.UserRepository, notifier *services.Notifier) *RentalHandler {
	return &RentalHandler{rentalRepo: rentalRepo, listingRepo: listingRepo, userRepo: userRepo, notifier: notifier}
}

// ─────────────────────────────────────────────
// DTO vers le contrat Flutter
// ─────────────────────────────────────────────

func rentalToMap(r *models.Rental) gin.H {
	listingTitle, listingVille, listingPhoto := "", "", ""
	if r.Listing != nil {
		listingTitle = r.Listing.Titre
		listingVille = r.Listing.Ville
		if len(r.Listing.Photos) > 0 {
			listingPhoto = r.Listing.Photos[0]
		}
	}

	hoteNom, voyageurNom, voyageurTelephone, voyageurPhoto := "", "", "", ""
	if r.Hote != nil {
		hoteNom = r.Hote.FullName()
	}
	if r.Voyageur != nil {
		voyageurNom = r.Voyageur.FullName()
		voyageurTelephone = r.Voyageur.Telephone
		if r.Voyageur.PhotoURL != nil {
			voyageurPhoto = *r.Voyageur.PhotoURL
		}
	}

	payments := make([]gin.H, 0, len(r.Payments))
	for _, p := range r.Payments {
		payments = append(payments, gin.H{
			"id":             p.ID,
			"rentalId":       p.RentalID,
			"periodLabel":    p.PeriodLabel,
			"amount":         p.Amount,
			"dueDate":        p.DueDate.Format("2006-01-02T00:00:00Z"),
			"paidAt":         p.PaidAt,
			"status":         p.Status,
			"transactionRef": p.TransactionRef,
		})
	}

	requests := make([]gin.H, 0, len(r.Requests))
	for _, req := range r.Requests {
		requests = append(requests, gin.H{
			"id":          req.ID,
			"rentalId":    req.RentalID,
			"voyageurId":  req.VoyageurID,
			"type":        req.Type,
			"message":     req.Message,
			"amount":      req.Amount,
			"status":      req.Status,
			"createdAt":   req.CreatedAt,
			"respondedAt": req.RespondedAt,
		})
	}

	return gin.H{
		"id":                 r.ID,
		"listingId":          r.ListingID,
		"listingTitle":       listingTitle,
		"listingVille":       listingVille,
		"listingPhoto":       listingPhoto,
		"hoteId":             r.HoteID,
		"hoteNom":            hoteNom,
		"voyageurId":         r.VoyageurID,
		"voyageurNom":        voyageurNom,
		"voyageurTelephone":  voyageurTelephone,
		"voyageurPhoto":      voyageurPhoto,
		"startDate":          r.StartDate.Format("2006-01-02T00:00:00Z"),
		"endDate":            r.EndDate,
		"monthlyRent":        r.MonthlyRent,
		"caution":            r.Caution,
		"billingDay":         r.BillingDay,
		"periodStatus":       r.PeriodStatus,
		"payments":           payments,
		"requests":           requests,
		"createdAt":          r.CreatedAt,
	}
}

// ─────────────────────────────────────────────
// Handlers
// ─────────────────────────────────────────────

func (h *RentalHandler) List(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)
	role, _ := middleware.GetRole(c)

	var rentals []models.Rental
	var err error

	if role == "hote" || role == "agent" {
		rentals, err = h.rentalRepo.FindByHoteID(c.Request.Context(), userID)
		if err == nil && role == "agent" {
			tenantRentals, terr := h.rentalRepo.FindByVoyageurID(c.Request.Context(), userID)
			if terr == nil {
				rentals = append(rentals, tenantRentals...)
			}
		}
	} else {
		rentals, err = h.rentalRepo.FindByVoyageurID(c.Request.Context(), userID)
	}

	if err != nil {
		response.InternalError(c, "Erreur lors de la récupération des locations")
		return
	}

	result := make([]gin.H, 0, len(rentals))
	for _, r := range rentals {
		result = append(result, rentalToMap(&r))
	}

	response.OK(c, "Mes locations", result)
}

func (h *RentalHandler) GetByID(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID invalide")
		return
	}

	userID, _ := middleware.GetUserID(c)
	role, _ := middleware.GetRole(c)

	rental, err := h.rentalRepo.FindByID(c.Request.Context(), id)
	if err != nil {
		response.NotFound(c, "Location non trouvée")
		return
	}

	if rental.HoteID != userID && rental.VoyageurID != userID && role != "agent" {
		response.Forbidden(c, "Accès refusé")
		return
	}

	response.OK(c, "Détails de la location", rentalToMap(rental))
}

type createRentalInput struct {
	ListingID          string  `json:"listingId" binding:"required"`
	VoyageurTelephone  string  `json:"voyageurTelephone" binding:"required"`
	StartDate          string  `json:"startDate" binding:"required"`
	MonthlyRent        float64 `json:"monthlyRent" binding:"required"`
	Caution            float64 `json:"caution"`
	BillingDay         int     `json:"billingDay"`
}

// Create crée un bail mensuel (réservé au propriétaire du logement).
func (h *RentalHandler) Create(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)
	role, _ := middleware.GetRole(c)

	if role != "hote" && role != "agent" {
		response.Forbidden(c, "Seul un propriétaire peut créer une location")
		return
	}

	var input createRentalInput
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

	if listing.HoteID != userID && role != "agent" {
		response.Forbidden(c, "Vous n'êtes pas le propriétaire de ce logement")
		return
	}

	startDate, err := time.Parse("2006-01-02", input.StartDate)
	if err != nil {
		response.BadRequest(c, "Date de début invalide (format: YYYY-MM-DD)")
		return
	}

	if input.MonthlyRent <= 0 {
		response.BadRequest(c, "Le loyer mensuel doit être supérieur à 0")
		return
	}

	billingDay := input.BillingDay
	if billingDay < 1 || billingDay > 28 {
		billingDay = 5
	}

	var voyageurID uuid.UUID
	tenant, err := h.userRepo.FindByTelephone(c.Request.Context(), input.VoyageurTelephone)
	if err == nil {
		voyageurID = tenant.ID
	} else {
		// Si le locataire n'existe pas, on refuse — un bail est lié à un compte Flex.
		response.BadRequest(c, "Locataire introuvable: ce numéro doit correspondre à un compte Flex")
		return
	}

	if voyageurID == userID {
		response.BadRequest(c, "Vous ne pouvez pas être locataire de votre propre logement")
		return
	}

	rental := &models.Rental{
		ListingID:   listingID,
		HoteID:      userID,
		VoyageurID:  voyageurID,
		StartDate:   startDate,
		MonthlyRent: input.MonthlyRent,
		Caution:     input.Caution,
		BillingDay:  billingDay,
		PeriodStatus: models.RentalActive,
	}

	if err := h.rentalRepo.Create(c.Request.Context(), rental); err != nil {
		response.InternalError(c, "Erreur lors de la création de la location")
		return
	}

	if err := h.rentalRepo.GenerateSchedule(c.Request.Context(), rental); err != nil {
		response.InternalError(c, "Erreur lors de la génération des échéances")
		return
	}

	ref := rental.ID.String()
	h.notifier.Notify(c.Request.Context(), voyageurID, models.NotifSystem,
		"Nouvelle location",
		"Un bail mensuel a été créé pour "+listing.Titre, &ref)

	created, _ := h.rentalRepo.FindByID(c.Request.Context(), rental.ID)
	response.Created(c, "Location créée avec succès", rentalToMap(created))
}

type payRentalInput struct {
	PeriodLabel    string  `json:"periodLabel" binding:"required"`
	Amount         float64 `json:"amount"`
	TransactionRef string  `json:"transactionRef"`
}

// Pay enregistre le paiement d'une échéance (locataire ou propriétaire).
func (h *RentalHandler) Pay(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID invalide")
		return
	}

	userID, _ := middleware.GetUserID(c)
	role, _ := middleware.GetRole(c)

	rental, err := h.rentalRepo.FindByID(c.Request.Context(), id)
	if err != nil {
		response.NotFound(c, "Location non trouvée")
		return
	}

	if rental.HoteID != userID && rental.VoyageurID != userID && role != "agent" {
		response.Forbidden(c, "Accès refusé")
		return
	}

	var input payRentalInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides")
		return
	}

	payment, err := h.rentalRepo.FindPaymentByPeriod(c.Request.Context(), id, input.PeriodLabel)
	if err != nil {
		response.NotFound(c, "Échéance introuvable pour cette période")
		return
	}

	if payment.PaidAt != nil {
		response.Error(c, http.StatusConflict, "ALREADY_PAID", "Cette échéance est déjà payée")
		return
	}

	ref := input.TransactionRef
	if ref == "" {
		ref = "FLEX-RENT-" + payment.ID.String()[:8]
	}

	status := models.RentPayOnTime
	if time.Now().UTC().After(payment.DueDate.AddDate(0, 0, 7)) {
		status = models.RentPayLate
	}
	if payment.DueDate.After(time.Now().UTC().AddDate(0, 0, 7)) {
		status = models.RentPayAdvance
	}

	if err := h.rentalRepo.MarkPaymentPaid(c.Request.Context(), payment.ID, status, ref); err != nil {
		response.InternalError(c, "Erreur lors de l'enregistrement du paiement")
		return
	}

	paymentRef := payment.ID.String()
	if rental.VoyageurID == userID {
		h.notifier.Notify(c.Request.Context(), rental.HoteID, models.NotifPaymentReceived,
			"Loyer payé",
			"Le loyer de "+rental.Listing.Titre+" a été payé ("+input.PeriodLabel+")", &paymentRef)
	}

	updated, _ := h.rentalRepo.FindByID(c.Request.Context(), id)
	response.OK(c, "Paiement enregistré", rentalToMap(updated))
}

// Terminate met fin à un bail (réservé au propriétaire).
func (h *RentalHandler) Terminate(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID invalide")
		return
	}

	userID, _ := middleware.GetUserID(c)
	role, _ := middleware.GetRole(c)

	rental, err := h.rentalRepo.FindByID(c.Request.Context(), id)
	if err != nil {
		response.NotFound(c, "Location non trouvée")
		return
	}

	if rental.HoteID != userID && role != "agent" {
		response.Forbidden(c, "Seul le propriétaire peut mettre fin à la location")
		return
	}

	now := time.Now().UTC()
	if err := h.rentalRepo.UpdatePeriodStatus(c.Request.Context(), id, models.RentalTerminated, &now); err != nil {
		response.InternalError(c, "Erreur lors de la clôture")
		return
	}

	updated, _ := h.rentalRepo.FindByID(c.Request.Context(), id)
	response.OK(c, "Location terminée", rentalToMap(updated))
}

type createRentalRequestInput struct {
	Type    string   `json:"type" binding:"required"`
	Message string   `json:"message"`
	Amount  *float64 `json:"amount"`
}

// Request enregistre une demande locataire (avance, remboursement, renouvellement).
func (h *RentalHandler) Request(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID invalide")
		return
	}

	userID, _ := middleware.GetUserID(c)
	role, _ := middleware.GetRole(c)

	rental, err := h.rentalRepo.FindByID(c.Request.Context(), id)
	if err != nil {
		response.NotFound(c, "Location non trouvée")
		return
	}

	if rental.VoyageurID != userID && role != "agent" {
		response.Forbidden(c, "Seul le locataire peut faire une demande")
		return
	}

	var input createRentalRequestInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides")
		return
	}

	requestType := models.RentalRequestType(input.Type)
	if requestType != models.RentReqAdvancePayment && requestType != models.RentReqRefund && requestType != models.RentReqRenewal {
		response.BadRequest(c, "Type de demande invalide")
		return
	}

	if input.Amount != nil && *input.Amount <= 0 {
		response.BadRequest(c, "Montant invalide")
		return
	}

	req := &models.RentalRequest{
		RentalID:   id,
		VoyageurID: userID,
		Type:       requestType,
		Message:    input.Message,
		Amount:     input.Amount,
		Status:     models.RentReqPending,
	}

	if err := h.rentalRepo.CreateRequest(c.Request.Context(), req); err != nil {
		response.InternalError(c, "Erreur lors de la création de la demande")
		return
	}

	ref := req.ID.String()
	h.notifier.Notify(c.Request.Context(), rental.HoteID, models.NotifRentalRequest,
		"Nouvelle demande locataire",
		"Le locataire de "+rental.Listing.Titre+" a fait une demande", &ref)

	response.Created(c, "Demande envoyée", req)
}

func (h *RentalHandler) ListRequests(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID invalide")
		return
	}

	userID, _ := middleware.GetUserID(c)
	role, _ := middleware.GetRole(c)

	rental, err := h.rentalRepo.FindByID(c.Request.Context(), id)
	if err != nil {
		response.NotFound(c, "Location non trouvée")
		return
	}

	if rental.HoteID != userID && rental.VoyageurID != userID && role != "agent" {
		response.Forbidden(c, "Accès refusé")
		return
	}

	response.OK(c, "Demandes de la location", rental.Requests)
}

type respondRequestInput struct {
	Approved bool `json:"approved" binding:"required"`
}

// Respond permet au propriétaire d'accepter ou refuser une demande locataire.
func (h *RentalHandler) Respond(c *gin.Context) {
	rentalID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID invalide")
		return
	}

	requestID, err := uuid.Parse(c.Param("requestId"))
	if err != nil {
		response.BadRequest(c, "ID de demande invalide")
		return
	}

	userID, _ := middleware.GetUserID(c)
	role, _ := middleware.GetRole(c)

	rental, err := h.rentalRepo.FindByID(c.Request.Context(), rentalID)
	if err != nil {
		response.NotFound(c, "Location non trouvée")
		return
	}

	if rental.HoteID != userID && role != "agent" {
		response.Forbidden(c, "Seul le propriétaire peut répondre à une demande")
		return
	}

	req, err := h.rentalRepo.FindRequestByID(c.Request.Context(), requestID)
	if err != nil || req.RentalID != rentalID {
		response.NotFound(c, "Demande non trouvée")
		return
	}

	if req.Status != models.RentReqPending {
		response.Error(c, http.StatusConflict, "ALREADY_RESPONDED", "Cette demande a déjà reçu une réponse")
		return
	}

	var input respondRequestInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides")
		return
	}

	if err := h.rentalRepo.RespondToRequest(c.Request.Context(), requestID, input.Approved); err != nil {
		response.InternalError(c, "Erreur lors de la réponse")
		return
	}

	ref := requestID.String()
	status := "refusée"
	if input.Approved {
		status = "acceptée"
	}
	h.notifier.Notify(c.Request.Context(), req.VoyageurID, models.NotifRentalResponded,
		"Réponse à votre demande",
		"Votre demande a été "+status+" par le propriétaire", &ref)

	response.OK(c, "Réponse enregistrée", nil)
}
