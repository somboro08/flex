package repository

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/models"
	"gorm.io/gorm"
)

type OTPRepository struct {
	db *gorm.DB
}

func NewOTPRepository(db *gorm.DB) *OTPRepository {
	return &OTPRepository{db: db}
}

func (r *OTPRepository) Create(ctx context.Context, otp *models.OTPCode) error {
	return r.db.WithContext(ctx).Create(otp).Error
}

func (r *OTPRepository) FindValid(ctx context.Context, identifier, code, purpose string) (*models.OTPCode, error) {
	var otp models.OTPCode
	err := r.db.WithContext(ctx).
		Where("identifier = ? AND code = ? AND purpose = ? AND is_used = false AND expires_at > ?",
			identifier, code, purpose, time.Now().UTC()).
		First(&otp).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("invalid or expired code")
		}
		return nil, err
	}
	return &otp, nil
}

func (r *OTPRepository) MarkUsed(ctx context.Context, id uuid.UUID) error {
	return r.db.WithContext(ctx).Model(&models.OTPCode{}).Where("id = ?", id).
		UpdateColumn("is_used", true).Error
}

func (r *OTPRepository) IncrementAttempts(ctx context.Context, id uuid.UUID) error {
	return r.db.WithContext(ctx).Model(&models.OTPCode{}).Where("id = ?", id).
		UpdateColumn("attempts", gorm.Expr("attempts + 1")).Error
}

func (r *OTPRepository) InvalidatePrevious(ctx context.Context, identifier, purpose string) error {
	return r.db.WithContext(ctx).Model(&models.OTPCode{}).
		Where("identifier = ? AND purpose = ? AND is_used = false", identifier, purpose).
		UpdateColumn("is_used", true).Error
}

func (r *OTPRepository) CleanupExpired(ctx context.Context) error {
	return r.db.WithContext(ctx).
		Where("expires_at < ?", time.Now().UTC()).
		Delete(&models.OTPCode{}).Error
}
