package middleware

import (
	"strings"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

// NewCORSConfig only allows explicitly configured origins.
// An empty allow-list is never interpreted as "allow every origin".
func NewCORSConfig(allowedOrigins []string) gin.HandlerFunc {
	origins := make([]string, 0, len(allowedOrigins))
	for _, origin := range allowedOrigins {
		if normalized := strings.TrimSpace(origin); normalized != "" {
			origins = append(origins, normalized)
		}
	}

	cfg := cors.Config{
		AllowAllOrigins:  false,
		AllowOrigins:     origins,
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization", "X-API-Key", "X-Requested-With"},
		ExposeHeaders:    []string{"Content-Length", "X-RateLimit-Limit", "X-RateLimit-Remaining", "Retry-After"},
		AllowCredentials: true,
		MaxAge:           86400,
	}

	return cors.New(cfg)
}
