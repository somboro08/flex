package models

import (
	"time"

	"github.com/google/uuid"
)

type Message struct {
	ID          uuid.UUID  `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	SenderID    uuid.UUID  `gorm:"type:uuid;not null;index" json:"senderId"`
	RecipientID uuid.UUID  `gorm:"type:uuid;not null;index" json:"recipientId"`
	ListingID   *uuid.UUID `gorm:"type:uuid;index" json:"listingId,omitempty"`
	Content     string     `gorm:"type:text;not null" json:"content"`
	IsRead      bool       `gorm:"default:false" json:"isRead"`
	CreatedAt   time.Time  `json:"createdAt"`

	Sender    *User    `gorm:"foreignKey:SenderID" json:"sender,omitempty"`
	Recipient *User    `gorm:"foreignKey:RecipientID" json:"recipient,omitempty"`
	Listing   *Listing `gorm:"foreignKey:ListingID" json:"listing,omitempty"`
}

func (Message) TableName() string { return "messages" }
