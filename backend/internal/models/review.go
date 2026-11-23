package models

import (
	"time"

	"github.com/google/uuid"
)

type Review struct {
	ID          uuid.UUID  `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	BookingID   uuid.UUID  `gorm:"type:uuid;not null;uniqueIndex" json:"bookingId"`
	VoyageurID  uuid.UUID  `gorm:"type:uuid;not null;index" json:"voyageurId"`
	ListingID   uuid.UUID  `gorm:"type:uuid;not null;index" json:"listingId"`
	Note        int        `gorm:"not null;check:note >= 1 AND note <= 5" json:"note"`
	Commentaire *string    `gorm:"type:text" json:"commentaire,omitempty"`
	CreatedAt   time.Time  `json:"createdAt"`

	Voyageur *User    `gorm:"foreignKey:VoyageurID" json:"voyageur,omitempty"`
	Listing  *Listing `gorm:"foreignKey:ListingID" json:"listing,omitempty"`
}

func (Review) TableName() string { return "reviews" }
