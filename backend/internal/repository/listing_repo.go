package repository

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/models"
	"gorm.io/gorm"
)

type ListingRepository struct {
	db *gorm.DB
}

func NewListingRepository(db *gorm.DB) *ListingRepository {
	return &ListingRepository{db: db}
}

func (r *ListingRepository) Create(ctx context.Context, listing *models.Listing) error {
	return r.db.WithContext(ctx).Create(listing).Error
}

func (r *ListingRepository) FindByID(ctx context.Context, id uuid.UUID) (*models.Listing, error) {
	var listing models.Listing
	err := r.db.WithContext(ctx).
		Preload("Hote").
		Where("id = ? AND deleted_at IS NULL", id).
		First(&listing).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("listing not found")
		}
		return nil, err
	}
	return &listing, nil
}

func (r *ListingRepository) FindAll(ctx context.Context, filters map[string]interface{}, page, perPage int) ([]models.Listing, int64, error) {
	var listings []models.Listing
	var total int64

	// Build a fresh query for each statement: reusing the same *gorm.DB after
	// Count() can leak the count SELECT/ORDER state into the Find() query.
	baseQuery := func() *gorm.DB {
		return applyListingFilters(
			r.db.WithContext(ctx).Model(&models.Listing{}).Where("deleted_at IS NULL"),
			filters,
		)
	}

	if err := baseQuery().Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * perPage
	err := baseQuery().
		Preload("Hote").
		Order("created_at DESC").
		Offset(offset).
		Limit(perPage).
		Find(&listings).Error

	return listings, total, err
}

func applyListingFilters(query *gorm.DB, filters map[string]interface{}) *gorm.DB {
	if ville, ok := filters["ville"]; ok {
		query = query.Where("ville = ?", ville)
	}
	if minPrice, ok := filters["min_prix"]; ok {
		query = query.Where("prix_par_nuit >= ?", minPrice)
	}
	if maxPrice, ok := filters["max_prix"]; ok {
		query = query.Where("prix_par_nuit <= ?", maxPrice)
	}
	if certification, ok := filters["certification"]; ok {
		query = query.Where("certification = ?", certification)
	}
	if listingType, ok := filters["type"]; ok {
		query = query.Where("type_logement = ?", listingType)
	}
	if isDisponible, ok := filters["is_disponible"]; ok {
		query = query.Where("is_disponible = ?", isDisponible)
	}
	if search, ok := filters["search"].(string); ok && search != "" {
		pattern := "%" + search + "%"
		query = query.Where("titre ILIKE ? OR description ILIKE ? OR ville ILIKE ?",
			pattern, pattern, pattern)
	}
	return query
}

func (r *ListingRepository) FindByHoteID(ctx context.Context, hoteID uuid.UUID) ([]models.Listing, error) {
	var listings []models.Listing
	err := r.db.WithContext(ctx).
		Where("hote_id = ? AND deleted_at IS NULL", hoteID).
		Order("created_at DESC").
		Find(&listings).Error
	return listings, err
}

func (r *ListingRepository) FindByIDs(ctx context.Context, ids []uuid.UUID) ([]models.Listing, error) {
	if len(ids) == 0 {
		return []models.Listing{}, nil
	}
	var listings []models.Listing
	err := r.db.WithContext(ctx).
		Preload("Hote").
		Where("id IN ? AND deleted_at IS NULL", ids).
		Find(&listings).Error
	return listings, err
}

func (r *ListingRepository) Update(ctx context.Context, listing *models.Listing) error {
	return r.db.WithContext(ctx).Save(listing).Error
}

// UpdateFields applies only the allowed fields (maps JSON camelCase keys to DB columns).
func (r *ListingRepository) UpdateFields(ctx context.Context, id uuid.UUID, fields map[string]interface{}) error {
	columnMapping := map[string]string{
		"titre":          "titre",
		"description":    "description",
		"typeLogement":   "type_logement",
		"ville":          "ville",
		"quartier":       "quartier",
		"adresse":        "adresse",
		"latitude":       "latitude",
		"longitude":      "longitude",
		"prixParNuit":    "prix_par_nuit",
		"nombreChambres": "nombre_chambres",
		"photos":         "photos",
		"equipements":    "equipements",
		"isDisponible":   "is_disponible",
	}

	updates := map[string]interface{}{}
	for key, value := range fields {
		if column, ok := columnMapping[key]; ok {
			updates[column] = value
		}
	}

	if len(updates) == 0 {
		return nil
	}

	return r.db.WithContext(ctx).Model(&models.Listing{}).Where("id = ? AND deleted_at IS NULL", id).Updates(updates).Error
}

// StatsByType returns the number of available listings grouped by type.
func (r *ListingRepository) StatsByType(ctx context.Context) (map[string]int64, int64, error) {
	type row struct {
		Type  string
		Count int64
	}
	var rows []row
	err := r.db.WithContext(ctx).Model(&models.Listing{}).
		Select("type_logement AS type, COUNT(*) AS count").
		Where("deleted_at IS NULL AND is_disponible = ?", true).
		Group("type_logement").Scan(&rows).Error
	if err != nil {
		return nil, 0, err
	}

	stats := make(map[string]int64)
	var total int64
	for _, r := range rows {
		stats[r.Type] = r.Count
		total += r.Count
	}
	return stats, total, nil
}

func (r *ListingRepository) UpdateCertification(ctx context.Context, id uuid.UUID, status models.CertificationStatus) error {
	return r.db.WithContext(ctx).Model(&models.Listing{}).Where("id = ?", id).
		UpdateColumn("certification", status).Error
}

func (r *ListingRepository) IncrementViews(ctx context.Context, id uuid.UUID) error {
	return r.db.WithContext(ctx).Model(&models.Listing{}).Where("id = ?", id).
		UpdateColumn("views_count", gorm.Expr("views_count + 1")).Error
}

func (r *ListingRepository) SoftDelete(ctx context.Context, id uuid.UUID) error {
	return r.db.WithContext(ctx).Where("id = ?", id).Delete(&models.Listing{}).Error
}
