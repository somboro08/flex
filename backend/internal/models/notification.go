package models

import (
	"time"

	"github.com/google/uuid"
)

type NotificationType string

const (
	NotifBookingReceived   NotificationType = "booking_received"
	NotifBookingConfirmed  NotificationType = "booking_confirmed"
	NotifBookingCancelled  NotificationType = "booking_cancelled"
	NotifPaymentReceived   NotificationType = "payment_received"
	NotifVisitReceived     NotificationType = "visit_received"
	NotifVisitConfirmed    NotificationType = "visit_confirmed"
	NotifVisitCancelled    NotificationType = "visit_cancelled"
	NotifNewMessage        NotificationType = "new_message"
	NotifCertified         NotificationType = "listing_certified"
	NotifReviewReceived    NotificationType = "review_received"
	NotifRentalRequest     NotificationType = "rental_request"
	NotifRentalResponded   NotificationType = "rental_responded"
	NotifSystem            NotificationType = "system"
)

type Notification struct {
	ID        uuid.UUID        `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	UserID    uuid.UUID        `gorm:"type:uuid;not null;index" json:"userId"`
	Type      NotificationType `gorm:"type:varchar(50);not null" json:"type"`
	Title     string           `gorm:"size:255;not null" json:"title"`
	Body      string           `gorm:"type:text;not null" json:"body"`
	IsRead    bool             `gorm:"default:false" json:"isRead"`
	RefID     *string          `gorm:"type:text" json:"refId,omitempty"`
	CreatedAt time.Time        `json:"createdAt"`
}

func (Notification) TableName() string { return "notifications" }
