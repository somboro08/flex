package middleware

import (
	"strings"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

// NewCORSConfig only allows explicitly configured origins.
// An empty allow-list is never interpreted as "allow every origin".
// Localhost / 127.0.0.1 / ngrok origins remain available for local
// development and mobile testing against a tunnel.
func NewCORSConfig(allowedOrigins []string) gin.HandlerFunc {
	origins := make([]string, 0, len(allowedOrigins))
	for _, origin := range allowedOrigins {
		if normalized := strings.TrimSpace(origin); normalized != "" {
			origins = append(origins, normalized)
		}
	}

	cfg := cors.Config{
		AllowOriginFunc: func(origin string) bool {
			if strings.Contains(origin, "localhost") ||
				strings.Contains(origin, "127.0.0.1") ||
				strings.Contains(origin, "ngrok") {
				return true
			}
			for _, allowed := range origins {
				if allowed == "*" || allowed == origin {
					return true
				}
			}
			return false
		},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization", "X-API-Key", "X-Requested-With", "ngrok-skip-browser-warning"},
		ExposeHeaders:    []string{"Content-Length", "X-RateLimit-Limit", "X-RateLimit-Remaining", "Retry-After"},
		AllowCredentials: true,
		MaxAge:           86400,
	}

	return cors.New(cfg)
}
