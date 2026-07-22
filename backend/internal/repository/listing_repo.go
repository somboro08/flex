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

	query := r.db.WithContext(ctx).Model(&models.Listing{}).Where("deleted_at IS NULL")

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
	if isDisponible, ok := filters["is_disponible"]; ok {
		query = query.Where("is_disponible = ?", isDisponible)
	}
	if search, ok := filters["search"]; ok {
		query = query.Where("titre ILIKE ? OR description ILIKE ? OR ville ILIKE ?",
			"%"+search.(string)+"%", "%"+search.(string)+"%", "%"+search.(string)+"%")
	}

	query.Count(&total)

	offset := (page - 1) * perPage
	err := query.
		Preload("Hote").
		Order("created_at DESC").
		Offset(offset).
		Limit(perPage).
		Find(&listings).Error

	return listings, total, err
}

func (r *ListingRepository) FindByHoteID(ctx context.Context, hoteID uuid.UUID) ([]models.Listing, error) {
	var listings []models.Listing
	err := r.db.WithContext(ctx).
		Where("hote_id = ? AND deleted_at IS NULL", hoteID).
		Order("created_at DESC").
		Find(&listings).Error
	return listings, err
}

func (r *ListingRepository) Update(ctx context.Context, listing *models.Listing) error {
	return r.db.WithContext(ctx).Save(listing).Error
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
