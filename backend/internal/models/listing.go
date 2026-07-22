package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type CertificationStatus string

const (
	CertPending   CertificationStatus = "pending"
	CertCertified CertificationStatus = "certified"
	CertRejected  CertificationStatus = "rejected"
)

type Listing struct {
	ID              uuid.UUID           `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	HoteID          uuid.UUID           `gorm:"type:uuid;not null;index" json:"hoteId"`
	Titre           string              `gorm:"size:200;not null" json:"titre" binding:"required"`
	Description     string              `gorm:"type:text;not null" json:"description" binding:"required"`
	Ville           string              `gorm:"size:100;not null;index" json:"ville" binding:"required"`
	Quartier        string              `gorm:"size:100;not null" json:"quartier" binding:"required"`
	Adresse         string              `gorm:"type:text;not null" json:"adresse" binding:"required"`
	Latitude        float64             `gorm:"type:decimal(10,7);not null" json:"latitude" binding:"required"`
	Longitude       float64             `gorm:"type:decimal(10,7);not null" json:"longitude" binding:"required"`
	PrixParNuit     float64             `gorm:"type:decimal(10,2);not null;check:prix_par_nuit > 0" json:"prixParNuit" binding:"required"`
	NombreChambres  int                 `gorm:"default:1" json:"nombreChambres"`
	Photos          []string            `gorm:"type:text[];default:'{}'" json:"photos"`
	Equipements     []string            `gorm:"type:text[];default:'{}'" json:"equipements"`
	Certification   CertificationStatus `gorm:"type:certification_status;default:pending" json:"certification"`
	Note            float64             `gorm:"type:decimal(2,1);default:0.0" json:"note"`
	NombreAvis      int                 `gorm:"default:0" json:"nombreAvis"`
	IsDisponible    bool                `gorm:"default:true" json:"isDisponible"`
	ViewsCount      int                 `gorm:"default:0" json:"viewsCount"`
	CreatedAt       time.Time           `json:"createdAt"`
	UpdatedAt       time.Time           `json:"updatedAt"`
	DeletedAt       gorm.DeletedAt      `gorm:"index" json:"-"`

	Hote    User      `gorm:"foreignKey:HoteID" json:"hote,omitempty"`
	Bookings []Booking `gorm:"foreignKey:ListingID" json:"bookings,omitempty"`
	Audits  []Audit   `gorm:"foreignKey:ListingID" json:"audits,omitempty"`
}

func (Listing) TableName() string { return "listings" }

func (l *Listing) BeforeCreate(tx *gorm.DB) error {
	if l.ID == uuid.Nil {
		l.ID = uuid.New()
	}
	return nil
}

func (l *Listing) IsCertified() bool {
	return l.Certification == CertCertified
}
