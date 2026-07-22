package middleware

import (
	"github.com/gin-contrib/secure"
	"github.com/gin-gonic/gin"
)

func NewSecurityHeaders(isProd bool) gin.HandlerFunc {
	return secure.New(secure.Config{
		AllowedHosts:              []string{},
		HostsProxyHeaders:         []string{"X-Forwarded-Host"},
		SSLRedirect:               isProd,
		SSLHost:                   "",
		SSLProxyHeaders:           map[string]string{"X-Forwarded-Proto": "https"},
		STSSeconds:                31536000,
		STSIncludeSubdomains:      true,
		STSPreload:                true,
		ForceSTSHeader:            isProd,
		FrameDeny:                 true,
		ContentTypeNosniff:        true,
		BrowserXssFilter:          true,
		ContentSecurityPolicy:     "default-src 'self'",
		IENoOpen:                  true,
		ReferrerPolicy:            "strict-origin-when-cross-origin",
		IsDevelopment:             !isProd,
	})
}
