package handlers

import (
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/middleware"
	"github.com/somboro08/flex-api/internal/models"
	"github.com/somboro08/flex-api/internal/repository"
	"github.com/somboro08/flex-api/internal/services"
	"github.com/somboro08/flex-api/pkg/response"
)

type MessageHandler struct {
	messageRepo *repository.MessageRepository
	userRepo    *repository.UserRepository
	notifier    *services.Notifier
}

func NewMessageHandler(messageRepo *repository.MessageRepository, userRepo *repository.UserRepository, notifier *services.Notifier) *MessageHandler {
	return &MessageHandler{messageRepo: messageRepo, userRepo: userRepo, notifier: notifier}
}

type sendMessageInput struct {
	RecipientID string  `json:"recipientId" binding:"required"`
	ListingID   *string `json:"listingId"`
	Content     string  `json:"content" binding:"required"`
}

func (h *MessageHandler) Send(c *gin.Context) {
	senderID, _ := middleware.GetUserID(c)

	var input sendMessageInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "Données invalides: "+err.Error())
		return
	}

	recipientID, err := uuid.Parse(input.RecipientID)
	if err != nil {
		response.BadRequest(c, "ID destinataire invalide")
		return
	}

	if recipientID == senderID {
		response.BadRequest(c, "Vous ne pouvez pas vous envoyer un message à vous-même")
		return
	}

	if _, err := h.userRepo.FindByID(c.Request.Context(), recipientID); err != nil {
		response.NotFound(c, "Destinataire non trouvé")
		return
	}

	var listingUUID *uuid.UUID
	if input.ListingID != nil && *input.ListingID != "" {
		id, err := uuid.Parse(*input.ListingID)
		if err == nil {
			listingUUID = &id
		}
	}

	msg := &models.Message{
		SenderID:    senderID,
		RecipientID: recipientID,
		ListingID:   listingUUID,
		Content:     input.Content,
		IsRead:      false,
	}

	if err := h.messageRepo.Create(c.Request.Context(), msg); err != nil {
		response.InternalError(c, "Erreur lors de l'envoi du message")
		return
	}

	ref := msg.ID.String()
	h.notifier.Notify(c.Request.Context(), recipientID, models.NotifNewMessage,
		"Nouveau message",
		"Vous avez reçu un nouveau message", &ref)

	response.Created(c, "Message envoyé avec succès", msg)
}

func (h *MessageHandler) GetConversation(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)
	otherUserID, err := uuid.Parse(c.Param("other_user_id"))
	if err != nil {
		response.BadRequest(c, "ID d'utilisateur invalide")
		return
	}

	msgs, err := h.messageRepo.GetConversation(c.Request.Context(), userID, otherUserID)
	if err != nil {
		response.InternalError(c, "Erreur lors de la récupération de la conversation")
		return
	}

	_ = h.messageRepo.MarkAsRead(c.Request.Context(), userID, otherUserID)

	response.OK(c, "Messages de la conversation", msgs)
}
