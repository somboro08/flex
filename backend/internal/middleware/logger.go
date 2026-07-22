package middleware

import (
	"time"

	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

type GinLoggerMiddleware struct {
	level zerolog.Level
}

func NewGinLoggerMiddleware(level zerolog.Level) *GinLoggerMiddleware {
	return &GinLoggerMiddleware{level: level}
}

func (m *GinLoggerMiddleware) Logger() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()

		path := c.Request.URL.Path
		query := c.Request.URL.RawQuery

		c.Next()

		latency := time.Since(start)
		status := c.Writer.Status()
		clientIP := c.ClientIP()
		method := c.Request.Method
		userID, _ := c.Get(ContextKeyUserID)

		logEvent := log.WithLevel(m.level).
			Str("method", method).
			Str("path", path).
			Int("status", status).
			Str("ip", clientIP).
			Dur("latency", latency)

		if query != "" {
			logEvent = logEvent.Str("query", query)
		}
		if userID != nil {
			logEvent = logEvent.Interface("user_id", userID)
		}

		if status >= 500 {
			logEvent = log.WithLevel(zerolog.ErrorLevel)
		} else if status >= 400 {
			logEvent = log.WithLevel(zerolog.WarnLevel)
		}

		logEvent.Msg("request")
	}
}
