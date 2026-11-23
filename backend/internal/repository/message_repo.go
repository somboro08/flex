package repository

import (
	"context"

	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/models"
	"gorm.io/gorm"
)

type MessageRepository struct {
	db *gorm.DB
}

func NewMessageRepository(db *gorm.DB) *MessageRepository {
	return &MessageRepository{db: db}
}

func (r *MessageRepository) Create(ctx context.Context, msg *models.Message) error {
	return r.db.WithContext(ctx).Create(msg).Error
}

func (r *MessageRepository) GetConversation(ctx context.Context, userID1, userID2 uuid.UUID) ([]models.Message, error) {
	var msgs []models.Message
	err := r.db.WithContext(ctx).
		Preload("Sender").
		Preload("Recipient").
		Where("(sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?)", userID1, userID2, userID2, userID1).
		Order("created_at ASC").
		Find(&msgs).Error
	return msgs, err
}

func (r *MessageRepository) MarkAsRead(ctx context.Context, recipientID, senderID uuid.UUID) error {
	return r.db.WithContext(ctx).Model(&models.Message{}).
		Where("recipient_id = ? AND sender_id = ? AND is_read = ?", recipientID, senderID, false).
		Update("is_read", true).Error
}
