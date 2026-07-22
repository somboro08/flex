package middleware

import (
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/rs/zerolog/log"
	"github.com/somboro08/flex-api/internal/repository"
	"github.com/somboro08/flex-api/pkg/jwt"
	"github.com/somboro08/flex-api/pkg/response"
)

type AuthMiddleware struct {
	jwtManager *jwt.JWTManager
	userRepo   *repository.UserRepository
}

func NewAuthMiddleware(jwtManager *jwt.JWTManager, userRepo *repository.UserRepository) *AuthMiddleware {
	return &AuthMiddleware{
		jwtManager: jwtManager,
		userRepo:   userRepo,
	}
}

const (
	ContextKeyUserID = "userID"
	ContextKeyRole   = "role"
	ContextKeyToken  = "token"
)

func (m *AuthMiddleware) RequireAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		tokenString := extractToken(c)
		if tokenString == "" {
			response.Unauthorized(c, "Token d'accès requis")
			c.Abort()
			return
		}

		claims, err := m.jwtManager.ValidateAccessToken(tokenString)
		if err != nil {
			log.Warn().Err(err).Msg("invalid access token")
			response.Unauthorized(c, "Token invalide ou expiré")
			c.Abort()
			return
		}

		user, err := m.userRepo.FindByID(c.Request.Context(), claims.UserID)
		if err != nil {
			response.Unauthorized(c, "Utilisateur non trouvé")
			c.Abort()
			return
		}

		if !user.IsActive {
			response.Forbidden(c, "Compte désactivé")
			c.Abort()
			return
		}

		c.Set(ContextKeyUserID, claims.UserID)
		c.Set(ContextKeyRole, claims.Role)
		c.Set(ContextKeyToken, tokenString)

		c.Next()
	}
}

func (m *AuthMiddleware) OptionalAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		tokenString := extractToken(c)
		if tokenString == "" {
			c.Next()
			return
		}

		claims, err := m.jwtManager.ValidateAccessToken(tokenString)
		if err != nil {
			c.Next()
			return
		}

		c.Set(ContextKeyUserID, claims.UserID)
		c.Set(ContextKeyRole, claims.Role)
		c.Next()
	}
}

func (m *AuthMiddleware) RequireRole(roles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		userRole, exists := c.Get(ContextKeyRole)
		if !exists {
			response.Forbidden(c, "Accès refusé")
			c.Abort()
			return
		}

		roleStr, ok := userRole.(string)
		if !ok {
			response.Forbidden(c, "Accès refusé")
			c.Abort()
			return
		}

		for _, role := range roles {
			if roleStr == role {
				c.Next()
				return
			}
		}

		response.Forbidden(c, "Vous n'avez pas les droits nécessaires")
		c.Abort()
	}
}

func extractToken(c *gin.Context) string {
	bearerToken := c.GetHeader("Authorization")
	if strings.HasPrefix(bearerToken, "Bearer ") {
		return strings.TrimPrefix(bearerToken, "Bearer ")
	}

	token := c.Query("token")
	if token != "" {
		return token
	}

	return ""
}

func GetUserID(c *gin.Context) (uuid.UUID, bool) {
	id, exists := c.Get(ContextKeyUserID)
	if !exists {
		return uuid.Nil, false
	}
	userID, ok := id.(uuid.UUID)
	return userID, ok
}

func GetRole(c *gin.Context) (string, bool) {
	role, exists := c.Get(ContextKeyRole)
	if !exists {
		return "", false
	}
	roleStr, ok := role.(string)
	return roleStr, ok
}
