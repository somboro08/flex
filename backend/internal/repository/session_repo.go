package repository

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/models"
	"gorm.io/gorm"
)

type SessionRepository struct {
	db *gorm.DB
}

func NewSessionRepository(db *gorm.DB) *SessionRepository {
	return &SessionRepository{db: db}
}

func (r *SessionRepository) Create(ctx context.Context, session *models.Session) error {
	return r.db.WithContext(ctx).Create(session).Error
}

func (r *SessionRepository) FindByRefreshToken(ctx context.Context, token string) (*models.Session, error) {
	var session models.Session
	err := r.db.WithContext(ctx).
		Where("refresh_token = ? AND is_revoked = false AND expires_at > ?", token, time.Now().UTC()).
		First(&session).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("session not found or expired")
		}
		return nil, err
	}
	return &session, nil
}

func (r *SessionRepository) Revoke(ctx context.Context, id uuid.UUID) error {
	now := time.Now().UTC()
	return r.db.WithContext(ctx).Model(&models.Session{}).Where("id = ?", id).
		Updates(map[string]interface{}{
			"is_revoked": true,
			"revoked_at": now,
		}).Error
}

func (r *SessionRepository) RevokeAllByUserID(ctx context.Context, userID uuid.UUID) error {
	now := time.Now().UTC()
	return r.db.WithContext(ctx).Model(&models.Session{}).Where("user_id = ? AND is_revoked = false", userID).
		Updates(map[string]interface{}{
			"is_revoked": true,
			"revoked_at": now,
		}).Error
}

func (r *SessionRepository) CleanupExpired(ctx context.Context) error {
	return r.db.WithContext(ctx).
		Where("expires_at < ? OR is_revoked = true", time.Now().UTC()).
		Delete(&models.Session{}).Error
}
