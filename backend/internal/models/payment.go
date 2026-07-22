package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Payment struct {
	ID          uuid.UUID      `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	BookingID   uuid.UUID      `gorm:"type:uuid;not null;index" json:"bookingId"`
	UserID      uuid.UUID      `gorm:"type:uuid;not null;index" json:"userId"`
	Amount      float64        `gorm:"type:decimal(10,2);not null" json:"amount"`
	Currency    string         `gorm:"size:3;default:XOF" json:"currency"`
	Method      PaymentMethod  `gorm:"type:payment_method;not null" json:"method"`
	Status      PaymentStatus  `gorm:"type:payment_status;default:pending" json:"status"`
	ProviderRef *string        `gorm:"size:255" json:"providerRef,omitempty"`
	PhoneNumber *string        `gorm:"size:20" json:"phoneNumber,omitempty"`
	Metadata    *string        `gorm:"type:jsonb" json:"metadata,omitempty"`
	PaidAt      *time.Time     `json:"paidAt,omitempty"`
	CreatedAt   time.Time      `json:"createdAt"`
	UpdatedAt   time.Time      `json:"updatedAt"`
}

func (Payment) TableName() string { return "payments" }

func (p *Payment) BeforeCreate(tx *gorm.DB) error {
	if p.ID == uuid.Nil {
		p.ID = uuid.New()
	}
	return nil
}
