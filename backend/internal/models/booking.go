package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type BookingStatus string
type PaymentMethod string
type PaymentStatus string

const (
	BookingPending   BookingStatus = "pending"
	BookingConfirmed BookingStatus = "confirmed"
	BookingCheckedIn BookingStatus = "checked_in"
	BookingCompleted BookingStatus = "completed"
	BookingCancelled BookingStatus = "cancelled"
)

const (
	PayMethodMTN    PaymentMethod = "mtn_momo"
	PayMethodMoov   PaymentMethod = "moov_money"
	PayMethodWave   PaymentMethod = "wave"
	PayMethodCard   PaymentMethod = "credit_card"
	PayMethodCash   PaymentMethod = "cash"
	PayMethodCinet  PaymentMethod = "cinetpay"
)

const (
	PayStatusPending   PaymentStatus = "pending"
	PayStatusProcessing PaymentStatus = "processing"
	PayStatusCompleted PaymentStatus = "completed"
	PayStatusFailed    PaymentStatus = "failed"
	PayStatusRefunded  PaymentStatus = "refunded"
)

type Booking struct {
	ID            uuid.UUID      `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	VoyageurID    uuid.UUID      `gorm:"type:uuid;not null;index" json:"voyageurId"`
	ListingID     uuid.UUID      `gorm:"type:uuid;not null;index" json:"listingId"`
	HoteID        uuid.UUID      `gorm:"type:uuid;not null;index" json:"hoteId"`
	DateArrivee   time.Time      `gorm:"type:date;not null" json:"dateArrivee" binding:"required"`
	DateDepart    time.Time      `gorm:"type:date;not null" json:"dateDepart" binding:"required"`
	NombreNuits   int            `gorm:"not null;check:nombre_nuits > 0" json:"nombreNuits"`
	MontantTotal  float64        `gorm:"type:decimal(10,2);not null;check:montant_total > 0" json:"montantTotal"`
	Status        BookingStatus  `gorm:"type:booking_status;default:pending" json:"status"`
	PaymentMethod *PaymentMethod `gorm:"type:payment_method" json:"paymentMethod,omitempty"`
	PaymentStatus PaymentStatus  `gorm:"type:payment_status;default:pending" json:"paymentStatus"`
	TransactionID *string        `gorm:"size:255" json:"transactionId,omitempty"`
	IsPaid        bool           `gorm:"default:false" json:"isPaid"`
	CheckInAt     *time.Time     `json:"checkInAt,omitempty"`
	CheckOutAt    *time.Time     `json:"checkOutAt,omitempty"`
	CancelledAt   *time.Time     `json:"cancelledAt,omitempty"`
	CancelReason  *string        `gorm:"type:text" json:"cancelReason,omitempty"`
	CreatedAt     time.Time      `json:"createdAt"`
	UpdatedAt     time.Time      `json:"updatedAt"`
	DeletedAt     gorm.DeletedAt `gorm:"index" json:"-"`

	Voyageur User    `gorm:"foreignKey:VoyageurID" json:"voyageur,omitempty"`
	Listing  Listing `gorm:"foreignKey:ListingID" json:"listing,omitempty"`
	Hote     User    `gorm:"foreignKey:HoteID" json:"hote,omitempty"`
	Payment  Payment `gorm:"foreignKey:BookingID" json:"payment,omitempty"`
}

func (Booking) TableName() string { return "bookings" }

func (b *Booking) BeforeCreate(tx *gorm.DB) error {
	if b.ID == uuid.Nil {
		b.ID = uuid.New()
	}
	if b.NombreNuits == 0 {
		b.NombreNuits = int(b.DateDepart.Sub(b.DateArrivee).Hours() / 24)
	}
	return nil
}

func (b *Booking) CanCancel() bool {
	return b.Status == BookingPending || b.Status == BookingConfirmed
}

func (b *Booking) CanCheckIn() bool {
	return b.Status == BookingConfirmed && b.IsPaid
}
