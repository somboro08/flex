package handlers

import (
	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"github.com/somboro08/flex-api/internal/config"
	"github.com/somboro08/flex-api/internal/middleware"
	"github.com/somboro08/flex-api/internal/repository"
	"github.com/somboro08/flex-api/internal/services"
	"github.com/somboro08/flex-api/pkg/jwt"
	"github.com/somboro08/flex-api/pkg/validator"
	"gorm.io/gorm"
)

type Handlers struct {
	Auth    *AuthHandler
	Health  *HealthHandler
	Listing *ListingHandler
	Booking *BookingHandler
}

func NewHandlers(db *gorm.DB, redis *redis.Client, cfg *config.Config) *Handlers {
	// Repositories
	userRepo := repository.NewUserRepository(db)
	sessionRepo := repository.NewSessionRepository(db)
	otpRepo := repository.NewOTPRepository(db)
	listingRepo := repository.NewListingRepository(db)
	bookingRepo := repository.NewBookingRepository(db)

	// JWT
	jwtManager := jwt.New(cfg.JWT)

	// Validator
	v := validator.New()

	// Services
	authService := services.NewAuthService(userRepo, sessionRepo, otpRepo, jwtManager, cfg, v)
	_ = authService

	// Handlers
	authHandler := NewAuthHandler(authService)
	healthHandler := NewHealthHandler(db, redis)
	listingHandler := NewListingHandler(listingRepo)
	bookingHandler := NewBookingHandler(bookingRepo, listingRepo)

	return &Handlers{
		Auth:    authHandler,
		Health:  healthHandler,
		Listing: listingHandler,
		Booking: bookingHandler,
	}
}

func SetupRouter(h *Handlers, cfg *config.Config, db *gorm.DB, rdb *redis.Client) *gin.Engine {
	r := gin.New()

	// Middleware
	authMiddleware := middleware.NewAuthMiddleware(jwt.New(cfg.JWT), repository.NewUserRepository(db))
	rateLimit := middleware.NewRateLimitMiddleware(rdb, cfg.RateLimit)
	logger := middleware.NewGinLoggerMiddleware(cfg.LogLevelZero())

	r.Use(logger.Logger())
	r.Use(middleware.NewCORSConfig(cfg.CORS.AllowedOrigins))
	r.Use(middleware.NewSecurityHeaders(cfg.IsProduction()))
	r.Use(gin.Recovery())

	// API v1
	v1 := r.Group("/api/v1")
	{
		// Health
		v1.GET("/health", h.Health.Health)
		v1.GET("/readiness", h.Health.Readiness)

		// Auth (no auth required)
		auth := v1.Group("/auth")
		auth.Use(rateLimit.Auth())
		{
			auth.POST("/register", h.Auth.Register)
			auth.POST("/login", h.Auth.Login)
			auth.POST("/refresh", h.Auth.RefreshToken)
			auth.POST("/otp/send", rateLimit.OTP(), h.Auth.SendOTP)
			auth.POST("/otp/verify", rateLimit.OTP(), h.Auth.VerifyOTP)
			auth.POST("/password/reset", h.Auth.ResetPassword)
		}

		// Protected routes
		protected := v1.Group("")
		protected.Use(authMiddleware.RequireAuth())
		protected.Use(rateLimit.Global())
		{
			// User
			protected.GET("/me", h.Auth.Me)
			protected.POST("/auth/logout", h.Auth.Logout)
			protected.POST("/auth/logout/all", h.Auth.LogoutAll)
			protected.PUT("/auth/password", h.Auth.ChangePassword)

			// Listings
			protected.POST("/listings", h.Listing.Create)
			protected.PUT("/listings/:id", h.Listing.Update)
			protected.DELETE("/listings/:id", h.Listing.Delete)
			protected.GET("/listings/mine", h.Listing.GetByHote)

			// Bookings
			protected.POST("/bookings", h.Booking.Create)
			protected.GET("/bookings", h.Booking.ListMyBookings)
			protected.GET("/bookings/:id", h.Booking.GetByID)
			protected.POST("/bookings/:id/cancel", h.Booking.Cancel)
			protected.POST("/bookings/:id/confirm", h.Booking.Confirm)

			// Agent routes
			agent := protected.Group("")
			agent.Use(authMiddleware.RequireRole("agent"))
			{
				// Audit routes
			}
		}

		// Public listings
		v1.GET("/listings", rateLimit.Global(), h.Listing.List)
		v1.GET("/listings/:id", h.Listing.GetByID)
	}

	return r
}
