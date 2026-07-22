package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type UserRole string
type IdentityStatus string

const (
	RoleVoyageur UserRole = "voyageur"
	RoleHote     UserRole = "hote"
	RoleAgent    UserRole = "agent"
)

const (
	IdentityNone     IdentityStatus = "none"
	IdentityPending  IdentityStatus = "pending"
	IdentityVerified IdentityStatus = "verified"
	IdentityRejected IdentityStatus = "rejected"
)

type User struct {
	ID                   uuid.UUID       `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	Nom                  string          `gorm:"size:100;not null" json:"nom" binding:"required"`
	Prenom               string          `gorm:"size:100;not null" json:"prenom" binding:"required"`
	Telephone            string          `gorm:"size:20;uniqueIndex;not null" json:"telephone" binding:"required"`
	Email                *string         `gorm:"size:255;uniqueIndex" json:"email,omitempty"`
	PasswordHash         string          `gorm:"size:255" json:"-"`
	PhotoURL             *string         `gorm:"type:text" json:"photoUrl,omitempty"`
	Role                 UserRole        `gorm:"type:user_role;default:voyageur" json:"role"`
	IsVerified           bool            `gorm:"default:false" json:"isVerified"`
	IsOnboarded          bool            `gorm:"default:false" json:"isOnboarded"`
	IsActive             bool            `gorm:"default:true" json:"-"`
	VerificationStatus   IdentityStatus  `gorm:"type:identity_status;default:none" json:"verificationStatus"`
	IDCardURL            *string         `gorm:"type:text" json:"idCardUrl,omitempty"`
	BirthCertificateURL  *string         `gorm:"type:text" json:"birthCertificateUrl,omitempty"`
	EmailVerifiedAt      *time.Time      `json:"emailVerifiedAt,omitempty"`
	PhoneVerifiedAt      *time.Time      `json:"phoneVerifiedAt,omitempty"`
	LastLoginAt          *time.Time      `json:"lastLoginAt,omitempty"`
	FailedLoginAttempts  int             `gorm:"default:0" json:"-"`
	LockedUntil          *time.Time      `json:"-"`
	Favorites            []uuid.UUID     `gorm:"type:uuid[];default:'{}'" json:"favorites,omitempty"`
	CreatedAt            time.Time       `json:"createdAt"`
	UpdatedAt            time.Time       `json:"updatedAt"`
	DeletedAt            gorm.DeletedAt  `gorm:"index" json:"-"`

	Listings  []Listing  `gorm:"foreignKey:HoteID" json:"listings,omitempty"`
	Bookings  []Booking  `gorm:"foreignKey:VoyageurID" json:"bookings,omitempty"`
}

func (User) TableName() string { return "users" }

func (u *User) BeforeCreate(tx *gorm.DB) error {
	if u.ID == uuid.Nil {
		u.ID = uuid.New()
	}
	return nil
}

func (u *User) IsLocked() bool {
	if u.LockedUntil == nil {
		return false
	}
	return time.Now().UTC().Before(*u.LockedUntil)
}

func (u *User) FullName() string {
	return u.Prenom + " " + u.Nom
}
