package repository

import (
	"context"

	"github.com/somboro08/flex-api/internal/models"
	"gorm.io/gorm"
)

type AuditRepository struct {
	db *gorm.DB
}

func NewAuditRepository(db *gorm.DB) *AuditRepository {
	return &AuditRepository{db: db}
}

func (r *AuditRepository) Create(ctx context.Context, audit *models.Audit) error {
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(audit).Error; err != nil {
			return err
		}

		// Update Listing certification status automatically
		if err := tx.Model(&models.Listing{}).Where("id = ?", audit.ListingID).
			Update("certification", audit.Result).Error; err != nil {
			return err
		}

		return nil
	})
}
