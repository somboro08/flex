package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"github.com/rs/zerolog/log"
	"github.com/somboro08/flex-api/pkg/response"
	"gorm.io/gorm"
)

type HealthHandler struct {
	db    *gorm.DB
	redis *redis.Client
}

func NewHealthHandler(db *gorm.DB, redis *redis.Client) *HealthHandler {
	return &HealthHandler{db: db, redis: redis}
}

func (h *HealthHandler) Health(c *gin.Context) {
	status := "healthy"
	dbStatus := "healthy"
	redisStatus := "healthy"

	dbSQL, err := h.db.DB()
	if err != nil {
		dbStatus = "unhealthy"
		status = "degraded"
	} else if err := dbSQL.Ping(); err != nil {
		dbStatus = "unhealthy"
		status = "degraded"
	}

	if h.redis != nil {
		if err := h.redis.Ping(c.Request.Context()).Err(); err != nil {
			redisStatus = "unhealthy"
			log.Warn().Err(err).Msg("redis health check failed")
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  status,
		"version": "1.0.0",
		"checks": gin.H{
			"database": dbStatus,
			"redis":    redisStatus,
		},
	})
}

func (h *HealthHandler) Readiness(c *gin.Context) {
	dbSQL, err := h.db.DB()
	if err != nil || dbSQL.Ping() != nil {
		response.Error(c, http.StatusServiceUnavailable, "NOT_READY", "Database not ready")
		return
	}

	response.OK(c, "ready", nil)
}
