package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type RentalPeriodStatus string
type RentalPaymentStatus string
type RentalRequestType string
type RentalRequestStatus string

const (
	RentalActive     RentalPeriodStatus = "active"
	RentalNotice     RentalPeriodStatus = "notice_given"
	RentalTerminated RentalPeriodStatus = "terminated"
	RentalExpired    RentalPeriodStatus = "expired"
)

const (
	RentPayOnTime   RentalPaymentStatus = "on_time"
	RentPayLate     RentalPaymentStatus = "late"
	RentPayAdvance  RentalPaymentStatus = "advance"
	RentPayUnpaid   RentalPaymentStatus = "unpaid"
	RentPayRefunded RentalPaymentStatus = "refunded"
)

const (
	RentReqAdvancePayment RentalRequestType = "advance_payment"
	RentReqRefund         RentalRequestType = "refund"
	RentReqRenewal        RentalRequestType = "renewal"
)

const (
	RentReqPending  RentalRequestStatus = "pending"
	RentReqApproved RentalRequestStatus = "approved"
	RentReqRejected RentalRequestStatus = "rejected"
)

type Rental struct {
	ID           uuid.UUID           `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	ListingID    uuid.UUID           `gorm:"type:uuid;not null;index" json:"listingId"`
	HoteID       uuid.UUID           `gorm:"type:uuid;not null;index" json:"hoteId"`
	VoyageurID   uuid.UUID           `gorm:"type:uuid;not null;index" json:"voyageurId"`
	StartDate    time.Time           `gorm:"type:date;not null" json:"startDate"`
	EndDate      *time.Time          `gorm:"type:date" json:"endDate,omitempty"`
	MonthlyRent  float64             `gorm:"type:decimal(12,2);not null;check:monthly_rent > 0" json:"monthlyRent"`
	Caution      float64             `gorm:"type:decimal(12,2);default:0" json:"caution"`
	BillingDay   int                 `gorm:"default:5" json:"billingDay"`
	PeriodStatus RentalPeriodStatus  `gorm:"type:rental_period_status;default:active" json:"periodStatus"`
	CreatedAt    time.Time           `json:"createdAt"`
	UpdatedAt    time.Time           `json:"updatedAt"`
	DeletedAt    gorm.DeletedAt      `gorm:"index" json:"-"`

	Listing   *Listing        `gorm:"foreignKey:ListingID" json:"listing,omitempty"`
	Hote      *User           `gorm:"foreignKey:HoteID" json:"hote,omitempty"`
	Voyageur  *User           `gorm:"foreignKey:VoyageurID" json:"voyageur,omitempty"`
	Payments  []RentalPayment `gorm:"foreignKey:RentalID" json:"payments"`
	Requests  []RentalRequest `gorm:"foreignKey:RentalID" json:"requests,omitempty"`
}

func (Rental) TableName() string { return "rentals" }

func (r *Rental) BeforeCreate(tx *gorm.DB) error {
	if r.ID == uuid.Nil {
		r.ID = uuid.New()
	}
	return nil
}

type RentalPayment struct {
	ID             uuid.UUID           `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	RentalID       uuid.UUID           `gorm:"type:uuid;not null;index" json:"rentalId"`
	PeriodLabel    string              `gorm:"size:7;not null" json:"periodLabel"`
	Amount         float64             `gorm:"type:decimal(12,2);not null" json:"amount"`
	DueDate        time.Time           `gorm:"type:date;not null" json:"dueDate"`
	PaidAt         *time.Time          `json:"paidAt,omitempty"`
	Status         RentalPaymentStatus `gorm:"type:rental_payment_status;default:unpaid" json:"status"`
	TransactionRef *string             `gorm:"size:255" json:"transactionRef,omitempty"`
	CreatedAt      time.Time           `json:"createdAt"`
	UpdatedAt      time.Time           `json:"updatedAt"`
}

func (RentalPayment) TableName() string { return "rental_payments" }

func (p *RentalPayment) BeforeCreate(tx *gorm.DB) error {
	if p.ID == uuid.Nil {
		p.ID = uuid.New()
	}
	return nil
}

type RentalRequest struct {
	ID          uuid.UUID           `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	RentalID    uuid.UUID           `gorm:"type:uuid;not null;index" json:"rentalId"`
	VoyageurID  uuid.UUID           `gorm:"type:uuid;not null;index" json:"voyageurId"`
	Type        RentalRequestType   `gorm:"type:rental_request_type;not null" json:"type"`
	Message     string              `gorm:"type:text" json:"message"`
	Amount      *float64            `gorm:"type:decimal(12,2)" json:"amount,omitempty"`
	Status      RentalRequestStatus `gorm:"type:rental_request_status;default:pending" json:"status"`
	RespondedAt *time.Time          `json:"respondedAt,omitempty"`
	CreatedAt   time.Time           `json:"createdAt"`
}

func (RentalRequest) TableName() string { return "rental_requests" }

func (r *RentalRequest) BeforeCreate(tx *gorm.DB) error {
	if r.ID == uuid.Nil {
		r.ID = uuid.New()
	}
	return nil
}
