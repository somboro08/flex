package services

import (
	"context"

	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/models"
	"github.com/somboro08/flex-api/internal/repository"
)

// Notifier is a small helper used by handlers to create notifications.
type Notifier struct {
	repo *repository.NotificationRepository
}

func NewNotifier(repo *repository.NotificationRepository) *Notifier {
	return &Notifier{repo: repo}
}

func (n *Notifier) Notify(ctx context.Context, userID uuid.UUID, notifType models.NotificationType, title, body string, refID *string) {
	if n == nil || n.repo == nil || userID == uuid.Nil {
		return
	}
	notification := &models.Notification{
		UserID: userID,
		Type:   notifType,
		Title:  title,
		Body:   body,
		RefID:  refID,
	}
	if err := n.repo.Create(ctx, notification); err != nil {
		return
	}
}
