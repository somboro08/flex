package models

import (
	"time"

	"github.com/google/uuid"
)

type OTPCode struct {
	ID          uuid.UUID  `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	Identifier  string     `gorm:"size:255;not null;index:idx_otp_identifier" json:"identifier"`
	Code        string     `gorm:"size:6;not null" json:"-"`
	Purpose     string     `gorm:"size:50;not null" json:"purpose"`
	Attempts    int        `gorm:"default:0" json:"-"`
	MaxAttempts int        `gorm:"default:5" json:"-"`
	IsUsed      bool       `gorm:"default:false" json:"-"`
	ExpiresAt   time.Time  `gorm:"not null" json:"expiresAt"`
	CreatedAt   time.Time  `json:"createdAt"`
}

func (OTPCode) TableName() string { return "otp_codes" }

func (o *OTPCode) IsExpired() bool {
	return time.Now().UTC().After(o.ExpiresAt)
}

func (o *OTPCode) HasExceededAttempts() bool {
	return o.Attempts >= o.MaxAttempts
}
