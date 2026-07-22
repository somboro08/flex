package repository

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/models"
	"gorm.io/gorm"
)

type BookingRepository struct {
	db *gorm.DB
}

func NewBookingRepository(db *gorm.DB) *BookingRepository {
	return &BookingRepository{db: db}
}

func (r *BookingRepository) Create(ctx context.Context, booking *models.Booking) error {
	return r.db.WithContext(ctx).Create(booking).Error
}

func (r *BookingRepository) FindByID(ctx context.Context, id uuid.UUID) (*models.Booking, error) {
	var booking models.Booking
	err := r.db.WithContext(ctx).
		Preload("Voyageur").
		Preload("Listing").
		Preload("Hote").
		Where("id = ? AND deleted_at IS NULL", id).
		First(&booking).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("booking not found")
		}
		return nil, err
	}
	return &booking, nil
}

func (r *BookingRepository) FindByVoyageurID(ctx context.Context, voyageurID uuid.UUID) ([]models.Booking, error) {
	var bookings []models.Booking
	err := r.db.WithContext(ctx).
		Preload("Listing").
		Where("voyageur_id = ? AND deleted_at IS NULL", voyageurID).
		Order("created_at DESC").
		Find(&bookings).Error
	return bookings, err
}

func (r *BookingRepository) FindByHoteID(ctx context.Context, hoteID uuid.UUID) ([]models.Booking, error) {
	var bookings []models.Booking
	err := r.db.WithContext(ctx).
		Preload("Voyageur").
		Preload("Listing").
		Where("hote_id = ? AND deleted_at IS NULL", hoteID).
		Order("created_at DESC").
		Find(&bookings).Error
	return bookings, err
}

func (r *BookingRepository) FindByListingID(ctx context.Context, listingID uuid.UUID) ([]models.Booking, error) {
	var bookings []models.Booking
	err := r.db.WithContext(ctx).
		Where("listing_id = ? AND deleted_at IS NULL", listingID).
		Find(&bookings).Error
	return bookings, err
}

func (r *BookingRepository) Update(ctx context.Context, booking *models.Booking) error {
	return r.db.WithContext(ctx).Save(booking).Error
}

func (r *BookingRepository) Cancel(ctx context.Context, id, userID uuid.UUID) error {
	booking, err := r.FindByID(ctx, id)
	if err != nil {
		return err
	}

	if booking.VoyageurID != userID {
		return errors.New("vous n'êtes pas le propriétaire de cette réservation")
	}

	if !booking.CanCancel() {
		return errors.New("cette réservation ne peut plus être annulée")
	}

	now := time.Now().UTC()
	return r.db.WithContext(ctx).Model(&models.Booking{}).Where("id = ?", id).
		Updates(map[string]interface{}{
			"status":       models.BookingCancelled,
			"cancelled_at": now,
		}).Error
}

func (r *BookingRepository) Confirm(ctx context.Context, id uuid.UUID) error {
	booking, err := r.FindByID(ctx, id)
	if err != nil {
		return err
	}

	if booking.Status != models.BookingPending {
		return errors.New("cette réservation ne peut pas être confirmée")
	}

	return r.db.WithContext(ctx).Model(&models.Booking{}).Where("id = ?", id).
		UpdateColumn("status", models.BookingConfirmed).Error
}

func (r *BookingRepository) CheckIn(ctx context.Context, id uuid.UUID) error {
	return r.db.WithContext(ctx).Model(&models.Booking{}).Where("id = ?", id).
		Updates(map[string]interface{}{
			"status":     models.BookingCheckedIn,
			"check_in_at": time.Now().UTC(),
		}).Error
}

func (r *BookingRepository) CheckOut(ctx context.Context, id uuid.UUID) error {
	return r.db.WithContext(ctx).Model(&models.Booking{}).Where("id = ?", id).
		Updates(map[string]interface{}{
			"status":      models.BookingCompleted,
			"check_out_at": time.Now().UTC(),
		}).Error
}
