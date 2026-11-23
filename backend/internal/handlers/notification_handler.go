package handlers

import (
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/somboro08/flex-api/internal/middleware"
	"github.com/somboro08/flex-api/internal/repository"
	"github.com/somboro08/flex-api/pkg/response"
)

type NotificationHandler struct {
	notifRepo *repository.NotificationRepository
}

func NewNotificationHandler(notifRepo *repository.NotificationRepository) *NotificationHandler {
	return &NotificationHandler{notifRepo: notifRepo}
}

func (h *NotificationHandler) GetMyNotifications(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	notifs, err := h.notifRepo.FindByUserID(c.Request.Context(), userID)
	if err != nil {
		response.InternalError(c, "Erreur lors de la récupération des notifications")
		return
	}

	response.OK(c, "Notifications", notifs)
}

func (h *NotificationHandler) MarkRead(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)
	notifID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.BadRequest(c, "ID de notification invalide")
		return
	}

	if err := h.notifRepo.MarkRead(c.Request.Context(), notifID, userID); err != nil {
		response.InternalError(c, "Erreur lors de la mise à jour")
		return
	}

	response.OK(c, "Notification marquée comme lue", nil)
}

func (h *NotificationHandler) MarkAllRead(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	if err := h.notifRepo.MarkAllRead(c.Request.Context(), userID); err != nil {
		response.InternalError(c, "Erreur lors de la mise à jour")
		return
	}

	response.OK(c, "Toutes les notifications marquées comme lues", nil)
}

func (h *NotificationHandler) UnreadCount(c *gin.Context) {
	userID, _ := middleware.GetUserID(c)

	count, err := h.notifRepo.CountUnread(c.Request.Context(), userID)
	if err != nil {
		response.InternalError(c, "Erreur lors du comptage")
		return
	}

	response.OK(c, "Notifications non lues", gin.H{"count": count})
}
