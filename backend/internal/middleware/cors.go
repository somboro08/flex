package middleware

import (
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func NewCORSConfig(allowedOrigins []string) gin.HandlerFunc {
	cfg := cors.Config{
		AllowAllOrigins:  len(allowedOrigins) == 0,
		AllowOrigins:     allowedOrigins,
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization", "X-API-Key", "X-Requested-With"},
		ExposeHeaders:    []string{"Content-Length", "X-RateLimit-Limit", "X-RateLimit-Remaining", "Retry-After"},
		AllowCredentials: true,
		MaxAge:           86400,
	}

	return cors.New(cfg)
}
