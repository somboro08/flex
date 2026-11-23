package repository

import (
	"context"

	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/models"
	"gorm.io/gorm"
)

type ReviewRepository struct {
	db *gorm.DB
}

func NewReviewRepository(db *gorm.DB) *ReviewRepository {
	return &ReviewRepository{db: db}
}

func (r *ReviewRepository) Create(ctx context.Context, review *models.Review) error {
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(review).Error; err != nil {
			return err
		}

		var count int64
		var avgNote float64
		tx.Model(&models.Review{}).Where("listing_id = ?", review.ListingID).Count(&count)
		tx.Model(&models.Review{}).Where("listing_id = ?", review.ListingID).Select("COALESCE(AVG(note), 0)").Scan(&avgNote)

		return tx.Model(&models.Listing{}).Where("id = ?", review.ListingID).
			Updates(map[string]interface{}{
				"note":        avgNote,
				"nombre_avis": count,
			}).Error
	})
}

func (r *ReviewRepository) FindByListingID(ctx context.Context, listingID uuid.UUID) ([]models.Review, error) {
	var reviews []models.Review
	err := r.db.WithContext(ctx).
		Preload("Voyageur").
		Where("listing_id = ?", listingID).
		Order("created_at DESC").
		Find(&reviews).Error
	return reviews, err
}
