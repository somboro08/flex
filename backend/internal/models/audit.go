package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Audit struct {
	ID            uuid.UUID           `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
	ListingID     uuid.UUID           `gorm:"type:uuid;not null;index" json:"listingId"`
	AgentID       uuid.UUID           `gorm:"type:uuid;not null;index" json:"agentId"`
	Serrure       bool                `gorm:"default:false" json:"serrure"`
	Literie       bool                `gorm:"default:false" json:"literie"`
	Sanitaires    bool                `gorm:"default:false" json:"sanitaires"`
	Eclairage     bool                `gorm:"default:false" json:"eclairage"`
	Identite      bool                `gorm:"default:false" json:"identite"`
	PhotosFideles bool                `gorm:"default:false" json:"photosFideles"`
	Adresse       bool                `gorm:"default:false" json:"adresse"`
	Score         int                 `gorm:"default:0" json:"score"`
	Commentaires  *string             `gorm:"type:text" json:"commentaires,omitempty"`
	Result        CertificationStatus `gorm:"type:certification_status;default:pending" json:"result"`
	CreatedAt     time.Time           `json:"createdAt"`

	Listing Listing `gorm:"foreignKey:ListingID" json:"listing,omitempty"`
	Agent   User    `gorm:"foreignKey:AgentID" json:"agent,omitempty"`
}

func (Audit) TableName() string { return "audits" }

func (a *Audit) BeforeCreate(tx *gorm.DB) error {
	if a.ID == uuid.Nil {
		a.ID = uuid.New()
	}
	a.calculateScore()
	return nil
}

func (a *Audit) calculateScore() {
	score := 0
	if a.Serrure { score++ }
	if a.Literie { score++ }
	if a.Sanitaires { score++ }
	if a.Eclairage { score++ }
	if a.Identite { score++ }
	if a.PhotosFideles { score++ }
	if a.Adresse { score++ }
	a.Score = score

	if score == 7 {
		a.Result = CertCertified
	} else {
		a.Result = CertRejected
	}
}
