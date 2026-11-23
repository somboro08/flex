package repository

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/models"
	"gorm.io/gorm"
)

type VisitRepository struct {
	db *gorm.DB
}

func NewVisitRepository(db *gorm.DB) *VisitRepository {
	return &VisitRepository{db: db}
}

func (r *VisitRepository) Create(ctx context.Context, visit *models.Visit) error {
	return r.db.WithContext(ctx).Create(visit).Error
}

func (r *VisitRepository) FindByID(ctx context.Context, id uuid.UUID) (*models.Visit, error) {
	var visit models.Visit
	err := r.db.WithContext(ctx).
		Preload("Voyageur").
		Preload("Listing").
		Preload("Hote").
		Where("id = ?", id).
		First(&visit).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("visit not found")
		}
		return nil, err
	}
	return &visit, nil
}

func (r *VisitRepository) FindByVoyageurID(ctx context.Context, voyageurID uuid.UUID) ([]models.Visit, error) {
	var visits []models.Visit
	err := r.db.WithContext(ctx).
		Preload("Listing").
		Preload("Hote").
		Where("voyageur_id = ?", voyageurID).
		Order("created_at DESC").
		Find(&visits).Error
	return visits, err
}

func (r *VisitRepository) FindByHoteID(ctx context.Context, hoteID uuid.UUID) ([]models.Visit, error) {
	var visits []models.Visit
	err := r.db.WithContext(ctx).
		Preload("Voyageur").
		Preload("Listing").
		Where("hote_id = ?", hoteID).
		Order("created_at DESC").
		Find(&visits).Error
	return visits, err
}

func (r *VisitRepository) UpdateStatus(ctx context.Context, id uuid.UUID, status models.VisitStatus) error {
	return r.db.WithContext(ctx).Model(&models.Visit{}).Where("id = ?", id).
		Update("status", status).Error
}
