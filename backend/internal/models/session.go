package models

import (
	"time"

	"github.com/google/uuid"
)

type Session struct {
	ID           uuid.UUID  `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	UserID       uuid.UUID  `gorm:"type:uuid;not null;index" json:"userId"`
	RefreshToken string     `gorm:"size:512;not null" json:"-"`
	DeviceInfo   *string    `gorm:"type:text" json:"deviceInfo,omitempty"`
	IPAddress    *string    `gorm:"size:45" json:"ipAddress,omitempty"`
	UserAgent    *string    `gorm:"type:text" json:"userAgent,omitempty"`
	IsRevoked    bool       `gorm:"default:false" json:"isRevoked"`
	ExpiresAt    time.Time  `gorm:"not null" json:"expiresAt"`
	RevokedAt    *time.Time `json:"revokedAt,omitempty"`
	CreatedAt    time.Time  `json:"createdAt"`

	User User `gorm:"foreignKey:UserID" json:"user,omitempty"`
}

func (Session) TableName() string { return "sessions" }
