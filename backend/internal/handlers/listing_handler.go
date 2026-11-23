package handlers

import (
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/middleware"
	"github.com/somboro08/flex-api/internal/models"
	"github.com/somboro08/flex-api/internal/repository"
	"github.com/somboro08/flex-api/pkg/response"
)

type ListingHandler struct {
	listingRepo *repository.ListingRepository
}

func NewListingHandler(listingRepo *repository.ListingRepository) *ListingHandler {
	return &ListingHandler{listingRepo: listingRepo}
}

type createListingInput struct {
	Titre          string              `json:"titre" binding:"required"`
	Description    string              `json:"description" binding:"required"`
	TypeLogement   models.ListingType  `json:"typeLogement"`
	Ville          string              `json:"ville" binding:"required"`
	Quartier       string              `json:"quartier" binding:"required"`
	Adresse        string              `json:"adresse" binding:"required"`
	Latitude       float64             `json:"latitude" binding:"required"`
	Longitude      float64             `json:"longitude" binding:"required"`
	PrixParNuit    float64             `json:"prixParNuit" binding:"required"`
	NombreChambres int                 `json:"nombreChambres"`
	Photos         []string            `json:"photos"`
	Equipements    []string            `json:"equipements"`
}

func (h *ListingHandler) requireHote(c *gin.Context) bool {
	role, _ := middleware.GetRole(c)
	if role != "hote" && role != "agent" {
		response.Forbidden(c, "Devenez propriétaire pour publier un logement")
		return false
	}
	return true
}

func (h *ListingHandler) Create(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	if !h.requireHote(c) {
		return
	}

	var input createListingInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides: "+err.Error())
		return
	}

	if input.TypeLogement == "" {
		input.TypeLogement = models.TypeChambre
	}
	if !models.ValidListingTypes[input.TypeLogement] {
		response.BadRequest(c, "Type de logement invalide")
		return
	}

	listing := createListingFromInput(input, userID)
	if err := h.listingRepo.Create(c.Request.Context(), listing); err != nil {
		response.InternalError(c, "Erreur lors de la création")
		return
	}

	response.Created(c, "Logement créé avec succès", listing)
}

func (h *ListingHandler) GetByID(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID invalide")
		return
	}

	listing, err := h.listingRepo.FindByID(c.Request.Context(), id)
	if err != nil {
		response.NotFound(c, "Logement non trouvé")
		return
	}

	_ = h.listingRepo.IncrementViews(c.Request.Context(), id)

	response.OK(c, "Détails du logement", listing)
}

func (h *ListingHandler) List(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	perPage, _ := strconv.Atoi(c.DefaultQuery("perPage", "20"))

	if page < 1 {
		page = 1
	}
	if perPage < 1 || perPage > 100 {
		perPage = 20
	}

	filters := make(map[string]interface{})
	if ville := c.Query("ville"); ville != "" {
		filters["ville"] = ville
	}
	if minPrix := c.Query("min_prix"); minPrix != "" {
		if v, err := strconv.ParseFloat(minPrix, 64); err == nil {
			filters["min_prix"] = v
		}
	}
	if maxPrix := c.Query("max_prix"); maxPrix != "" {
		if v, err := strconv.ParseFloat(maxPrix, 64); err == nil {
			filters["max_prix"] = v
		}
	}
	if cert := c.Query("certification"); cert != "" {
		filters["certification"] = cert
	}
	if listingType := c.Query("type"); listingType != "" {
		if models.ValidListingTypes[models.ListingType(listingType)] {
			filters["type"] = listingType
		}
	}
	if search := c.Query("search"); search != "" {
		filters["search"] = search
	}
	filters["is_disponible"] = true

	listings, total, err := h.listingRepo.FindAll(c.Request.Context(), filters, page, perPage)
	if err != nil {
		response.InternalError(c, "Erreur lors de la récupération")
		return
	}

	response.Paginated(c, listings, page, perPage, total)
}

func (h *ListingHandler) Update(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID invalide")
		return
	}

	userID, _ := middleware.GetUserID(c)
	role, _ := middleware.GetRole(c)

	if role != "hote" && role != "agent" {
		response.Forbidden(c, "Devenez propriétaire pour modifier un logement")
		return
	}

	listing, err := h.listingRepo.FindByID(c.Request.Context(), id)
	if err != nil {
		response.NotFound(c, "Logement non trouvé")
		return
	}

	if listing.HoteID != userID && role != "agent" {
		response.Forbidden(c, "Vous n'êtes pas le propriétaire de ce logement")
		return
	}

	var input map[string]interface{}
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides")
		return
	}

	for _, key := range []string{"id", "hoteId", "hote_id", "certification", "note", "nombreAvis", "viewsCount", "createdAt", "updatedAt"} {
		delete(input, key)
	}

	if listingType, ok := input["typeLogement"].(string); ok && listingType != "" {
		if !models.ValidListingTypes[models.ListingType(listingType)] {
			response.BadRequest(c, "Type de logement invalide")
			return
		}
	}

	if err := h.listingRepo.UpdateFields(c.Request.Context(), id, input); err != nil {
		response.InternalError(c, "Erreur lors de la mise à jour")
		return
	}

	updated, _ := h.listingRepo.FindByID(c.Request.Context(), id)
	response.OK(c, "Logement mis à jour", updated)
}

func (h *ListingHandler) Delete(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID invalide")
		return
	}

	userID, _ := middleware.GetUserID(c)
	role, _ := middleware.GetRole(c)

	listing, err := h.listingRepo.FindByID(c.Request.Context(), id)
	if err != nil {
		response.NotFound(c, "Logement non trouvé")
		return
	}

	if listing.HoteID != userID && role != "agent" && role != "admin" {
		response.Forbidden(c, "Accès refusé")
		return
	}

	if err := h.listingRepo.SoftDelete(c.Request.Context(), id); err != nil {
		response.InternalError(c, "Erreur lors de la suppression")
		return
	}

	response.OK(c, "Logement supprimé", nil)
}

func (h *ListingHandler) GetByHote(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	listings, err := h.listingRepo.FindByHoteID(c.Request.Context(), userID)
	if err != nil {
		response.InternalError(c, "Erreur lors de la récupération")
		return
	}

	response.OK(c, "Mes logements", listings)
}

func createListingFromInput(input createListingInput, hoteID uuid.UUID) *models.Listing {
	return &models.Listing{
		HoteID:         hoteID,
		Titre:          input.Titre,
		Description:    input.Description,
		TypeLogement:   input.TypeLogement,
		Ville:          input.Ville,
		Quartier:       input.Quartier,
		Adresse:        input.Adresse,
		Latitude:       input.Latitude,
		Longitude:      input.Longitude,
		PrixParNuit:    input.PrixParNuit,
		NombreChambres: input.NombreChambres,
		Photos:         models.StringArray(input.Photos),
		Equipements:    models.StringArray(input.Equipements),
	}
}

// Stats renvoie les statistiques de la liste publique (counts par type).
func (h *ListingHandler) Stats(c *gin.Context) {
	stats, total, err := h.listingRepo.StatsByType(c.Request.Context())
	if err != nil {
		response.InternalError(c, "Erreur lors de la récupération des statistiques")
		return
	}

	response.OK(c, "Statistiques des logements", gin.H{
		"byType": stats,
		"total":  total,
	})
}
