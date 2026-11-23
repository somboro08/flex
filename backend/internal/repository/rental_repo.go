package repository

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/models"
	"gorm.io/gorm"
)

type RentalRepository struct {
	db *gorm.DB
}

func NewRentalRepository(db *gorm.DB) *RentalRepository {
	return &RentalRepository{db: db}
}

func (r *RentalRepository) Create(ctx context.Context, rental *models.Rental) error {
	return r.db.WithContext(ctx).Create(rental).Error
}

func (r *RentalRepository) CreatePayment(ctx context.Context, payment *models.RentalPayment) error {
	return r.db.WithContext(ctx).Create(payment).Error
}

func (r *RentalRepository) CreateRequest(ctx context.Context, req *models.RentalRequest) error {
	return r.db.WithContext(ctx).Create(req).Error
}

func (r *RentalRepository) FindByID(ctx context.Context, id uuid.UUID) (*models.Rental, error) {
	var rental models.Rental
	err := r.db.WithContext(ctx).
		Preload("Listing").
		Preload("Hote").
		Preload("Voyageur").
		Preload("Payments", func(db *gorm.DB) *gorm.DB {
			return db.Order("due_date ASC")
		}).
		Preload("Requests", func(db *gorm.DB) *gorm.DB {
			return db.Order("created_at DESC")
		}).
		Where("id = ? AND deleted_at IS NULL", id).
		First(&rental).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("rental not found")
		}
		return nil, err
	}
	return &rental, nil
}

func (r *RentalRepository) FindByHoteID(ctx context.Context, hoteID uuid.UUID) ([]models.Rental, error) {
	var rentals []models.Rental
	err := r.db.WithContext(ctx).
		Preload("Listing").
		Preload("Voyageur").
		Preload("Payments", func(db *gorm.DB) *gorm.DB {
			return db.Order("due_date ASC")
		}).
		Preload("Requests", func(db *gorm.DB) *gorm.DB {
			return db.Order("created_at DESC")
		}).
		Where("hote_id = ? AND deleted_at IS NULL", hoteID).
		Order("created_at DESC").
		Find(&rentals).Error
	return rentals, err
}

func (r *RentalRepository) FindByVoyageurID(ctx context.Context, voyageurID uuid.UUID) ([]models.Rental, error) {
	var rentals []models.Rental
	err := r.db.WithContext(ctx).
		Preload("Listing").
		Preload("Hote").
		Preload("Payments", func(db *gorm.DB) *gorm.DB {
			return db.Order("due_date ASC")
		}).
		Preload("Requests", func(db *gorm.DB) *gorm.DB {
			return db.Order("created_at DESC")
		}).
		Where("voyageur_id = ? AND deleted_at IS NULL", voyageurID).
		Order("created_at DESC").
		Find(&rentals).Error
	return rentals, err
}

func (r *RentalRepository) FindPaymentByPeriod(ctx context.Context, rentalID uuid.UUID, periodLabel string) (*models.RentalPayment, error) {
	var payment models.RentalPayment
	err := r.db.WithContext(ctx).
		Where("rental_id = ? AND period_label = ?", rentalID, periodLabel).
		First(&payment).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("payment not found")
		}
		return nil, err
	}
	return &payment, nil
}

func (r *RentalRepository) MarkPaymentPaid(ctx context.Context, id uuid.UUID, status models.RentalPaymentStatus, transactionRef string) error {
	now := time.Now().UTC()
	return r.db.WithContext(ctx).Model(&models.RentalPayment{}).Where("id = ?", id).
		Updates(map[string]interface{}{
			"status":          status,
			"paid_at":         now,
			"transaction_ref": transactionRef,
		}).Error
}

func (r *RentalRepository) UpdatePeriodStatus(ctx context.Context, id uuid.UUID, status models.RentalPeriodStatus, endDate *time.Time) error {
	updates := map[string]interface{}{"period_status": status}
	if endDate != nil {
		updates["end_date"] = *endDate
	}
	return r.db.WithContext(ctx).Model(&models.Rental{}).Where("id = ?", id).Updates(updates).Error
}

func (r *RentalRepository) FindRequestByID(ctx context.Context, id uuid.UUID) (*models.RentalRequest, error) {
	var req models.RentalRequest
	err := r.db.WithContext(ctx).Where("id = ?", id).First(&req).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("request not found")
		}
		return nil, err
	}
	return &req, nil
}

func (r *RentalRepository) RespondToRequest(ctx context.Context, id uuid.UUID, approved bool) error {
	status := models.RentReqRejected
	if approved {
		status = models.RentReqApproved
	}
	now := time.Now().UTC()
	return r.db.WithContext(ctx).Model(&models.RentalRequest{}).Where("id = ?", id).
		Updates(map[string]interface{}{
			"status":       status,
			"responded_at": now,
		}).Error
}

// GenerateSchedule creates monthly due payments from startDate until the end of the current month.
func (r *RentalRepository) GenerateSchedule(ctx context.Context, rental *models.Rental) error {
	now := time.Now().UTC()
	start := time.Date(rental.StartDate.Year(), rental.StartDate.Month(), rental.BillingDay, 0, 0, 0, 0, time.UTC)
	if start.Before(rental.StartDate) {
		start = time.Date(rental.StartDate.Year(), rental.StartDate.Month()+1, rental.BillingDay, 0, 0, 0, 0, time.UTC)
	}
	end := time.Date(now.Year(), now.Month()+1, rental.BillingDay, 0, 0, 0, 0, time.UTC)

	periods := []models.RentalPayment{}
	for due := start; !due.After(end); due = due.AddDate(0, 1, 0) {
		periodLabel := due.Format("2006-01")
		periods = append(periods, models.RentalPayment{
			RentalID:    rental.ID,
			PeriodLabel: periodLabel,
			Amount:      rental.MonthlyRent,
			DueDate:     due,
			Status:      models.RentPayUnpaid,
		})
	}

	if len(periods) == 0 {
		return nil
	}
	return r.db.WithContext(ctx).Create(&periods).Error
}
