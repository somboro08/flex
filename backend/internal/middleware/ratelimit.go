package middleware

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"github.com/rs/zerolog/log"
	"github.com/somboro08/flex-api/internal/config"
	"github.com/somboro08/flex-api/pkg/response"
)

type RateLimitMiddleware struct {
	redis   *redis.Client
	cfg     config.RateLimitConfig
}

func NewRateLimitMiddleware(redis *redis.Client, cfg config.RateLimitConfig) *RateLimitMiddleware {
	return &RateLimitMiddleware{
		redis: redis,
		cfg:   cfg,
	}
}

func (m *RateLimitMiddleware) Global() gin.HandlerFunc {
	if m.redis == nil {
		return func(c *gin.Context) {
			c.Next()
		}
	}

	return func(c *gin.Context) {
		key := "ratelimit:global:" + c.ClientIP()
		m.rateLimitByKey(c, key, m.cfg.Requests, m.cfg.Window)
	}
}

func (m *RateLimitMiddleware) Auth() gin.HandlerFunc {
	if m.redis == nil {
		return func(c *gin.Context) {
			c.Next()
		}
	}

	return func(c *gin.Context) {
		key := "ratelimit:auth:" + c.ClientIP()
		m.rateLimitByKey(c, key, 10, time.Minute)
	}
}

func (m *RateLimitMiddleware) OTP() gin.HandlerFunc {
	if m.redis == nil {
		return func(c *gin.Context) {
			c.Next()
		}
	}

	return func(c *gin.Context) {
		key := "ratelimit:otp:" + c.ClientIP()
		m.rateLimitByKey(c, key, 3, time.Minute)
	}
}

func (m *RateLimitMiddleware) APIKey() gin.HandlerFunc {
	return func(c *gin.Context) {
		apiKey := c.GetHeader("X-API-Key")
		if apiKey == "" {
			response.Error(c, http.StatusUnauthorized, "API_KEY_REQUIRED", "Clé API requise")
			c.Abort()
			return
		}
		c.Next()
	}
}

func (m *RateLimitMiddleware) rateLimitByKey(c *gin.Context, key string, limit int, window time.Duration) {
	ctx := c.Request.Context()

	count, err := m.redis.Incr(ctx, key).Result()
	if err != nil {
		log.Error().Err(err).Str("key", key).Msg("rate limit check failed")
		c.Next()
		return
	}

	if count == 1 {
		m.redis.Expire(ctx, key, window)
	}

	if count > int64(limit) {
		ttl, _ := m.redis.TTL(ctx, key).Result()
		c.Header("Retry-After", ttl.String())
		c.Header("X-RateLimit-Limit", string(rune(limit)))
		c.Header("X-RateLimit-Remaining", "0")
		response.TooManyRequests(c, "Trop de requêtes. Réessayez plus tard.")
		c.Abort()
		return
	}

	c.Header("X-RateLimit-Remaining", string(rune(int64(limit)-count)))
	c.Next()
}
