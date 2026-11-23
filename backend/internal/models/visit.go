package models

import (
	"time"

	"github.com/google/uuid"
)

type VisitStatus string

const (
	VisitPending   VisitStatus = "pending"
	VisitConfirmed VisitStatus = "confirmed"
	VisitCompleted VisitStatus = "completed"
	VisitCancelled VisitStatus = "cancelled"
)

type Visit struct {
	ID         uuid.UUID   `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	ListingID  uuid.UUID   `gorm:"type:uuid;not null;index" json:"listingId" binding:"required"`
	VoyageurID uuid.UUID   `gorm:"type:uuid;not null;index" json:"voyageurId"`
	HoteID     uuid.UUID   `gorm:"type:uuid;not null;index" json:"hoteId"`
	DateVisite time.Time   `gorm:"type:date;not null" json:"dateVisite" binding:"required"`
	TimeSlot   string      `gorm:"size:50;not null" json:"timeSlot" binding:"required"`
	Message    string      `gorm:"type:text" json:"message"`
	Status     VisitStatus `gorm:"type:visit_status;default:pending" json:"status"`
	CreatedAt  time.Time   `json:"createdAt"`
	UpdatedAt  time.Time   `json:"updatedAt"`

	Listing  *Listing `gorm:"foreignKey:ListingID" json:"listing,omitempty"`
	Voyageur *User    `gorm:"foreignKey:VoyageurID" json:"voyageur,omitempty"`
	Hote     *User    `gorm:"foreignKey:HoteID" json:"hote,omitempty"`
}

func (Visit) TableName() string { return "visits" }
