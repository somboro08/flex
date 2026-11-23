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
	Auth         *AuthHandler
	Health       *HealthHandler
	Listing      *ListingHandler
	Booking      *BookingHandler
	Visit        *VisitHandler
	Audit        *AuditHandler
	Message      *MessageHandler
	Review       *ReviewHandler
	Notification *NotificationHandler
	Payment      *PaymentHandler
	Rental       *RentalHandler
	Upload       *UploadHandler
	WS           *WSHandler
	Admin        *AdminHandler
}

func NewHandlers(db *gorm.DB, redis *redis.Client, cfg *config.Config) *Handlers {
	// Repositories
	userRepo    := repository.NewUserRepository(db)
	sessionRepo := repository.NewSessionRepository(db)
	otpRepo     := repository.NewOTPRepository(db)
	listingRepo := repository.NewListingRepository(db)
	bookingRepo := repository.NewBookingRepository(db)
	visitRepo   := repository.NewVisitRepository(db)
	auditRepo   := repository.NewAuditRepository(db)
	messageRepo := repository.NewMessageRepository(db)
	reviewRepo  := repository.NewReviewRepository(db)
	notifRepo   := repository.NewNotificationRepository(db)
	paymentRepo := repository.NewPaymentRepository(db)
	rentalRepo  := repository.NewRentalRepository(db)

	// JWT
	jwtManager := jwt.New(cfg.JWT)

	// Validator
	v := validator.New()

	// Services
	emailSvc    := services.NewEmailService(cfg.Email)
	smsSvc      := services.NewSMSService(cfg.SMS)
	authService := services.NewAuthService(userRepo, sessionRepo, otpRepo, jwtManager, cfg, v, emailSvc, smsSvc)
	notifier    := services.NewNotifier(notifRepo)

	// Handlers
	authHandler         := NewAuthHandler(authService, userRepo, listingRepo)
	healthHandler       := NewHealthHandler(db, redis)
	listingHandler      := NewListingHandler(listingRepo)
	bookingHandler      := NewBookingHandler(bookingRepo, listingRepo, notifier)
	visitHandler        := NewVisitHandler(visitRepo, listingRepo, notifier)
	auditHandler        := NewAuditHandler(auditRepo, listingRepo)
	messageHandler      := NewMessageHandler(messageRepo, userRepo, notifier)
	reviewHandler       := NewReviewHandler(reviewRepo, bookingRepo, notifier)
	notificationHandler := NewNotificationHandler(notifRepo)
	paymentHandler      := NewPaymentHandler(paymentRepo, bookingRepo, notifier)
	rentalHandler       := NewRentalHandler(rentalRepo, listingRepo, userRepo, notifier)
	uploadHandler       := NewUploadHandler("./uploads", cfg.Cloudinary)
	wsHandler           := NewWSHandler()
	adminHandler        := NewAdminHandler(userRepo, listingRepo, bookingRepo, auditRepo)

	return &Handlers{
		Auth:         authHandler,
		Health:       healthHandler,
		Listing:      listingHandler,
		Booking:      bookingHandler,
		Visit:        visitHandler,
		Audit:        auditHandler,
		Message:      messageHandler,
		Review:       reviewHandler,
		Notification: notificationHandler,
		Payment:      paymentHandler,
		Rental:       rentalHandler,
		Upload:       uploadHandler,
		WS:           wsHandler,
		Admin:        adminHandler,
	}
}

func SetupRouter(h *Handlers, cfg *config.Config, db *gorm.DB, rdb *redis.Client) *gin.Engine {
	r := gin.New()

	// Middleware
	authMiddleware := middleware.NewAuthMiddleware(jwt.New(cfg.JWT), repository.NewUserRepository(db))
	rateLimit      := middleware.NewRateLimitMiddleware(rdb, cfg.RateLimit)
	logger         := middleware.NewGinLoggerMiddleware(cfg.LogLevelZero())

	r.Use(logger.Logger())
	r.Use(middleware.NewCORSConfig(cfg.CORS.AllowedOrigins))
	r.Use(middleware.NewSecurityHeaders(cfg.IsProduction()))
	r.Use(gin.Recovery())

	// Static routes
	r.Static("/uploads", "./uploads")
	r.Static("/admin", "./web/admin")

	// API v1
	v1 := r.Group("/api/v1")
	{
		// Health
		v1.GET("/health", h.Health.Health)
		v1.GET("/readiness", h.Health.Readiness)

		// Upload & WebSockets & Webhooks
		v1.POST("/upload", h.Upload.Upload)
		v1.GET("/ws", h.WS.HandleWS)
		v1.POST("/payments/webhook", h.Payment.HandleWebhook)

		// Admin APIs
		v1.GET("/admin/stats", h.Admin.Stats)
		v1.POST("/admin/listings/:id/approve", h.Admin.ApproveListing)
		v1.GET("/admin/users/identity", h.Admin.ListIdentities)
		v1.POST("/admin/users/:id/verify", h.Admin.VerifyUserIdentity)

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

		// Public listings
		v1.GET("/listings", rateLimit.Global(), h.Listing.List)
		v1.GET("/listings/stats", h.Listing.Stats)
		v1.GET("/listings/:id", h.Listing.GetByID)
		v1.GET("/listings/:id/reviews", h.Review.GetByListingID)

		// Protected routes
		protected := v1.Group("")
		protected.Use(authMiddleware.RequireAuth())
		protected.Use(rateLimit.Global())
		{
			// Profile & role
			protected.GET("/me", h.Auth.Me)
			protected.PUT("/me", h.Auth.UpdateProfile)
			protected.PUT("/me/identity", h.Auth.SubmitIdentity)
			protected.PUT("/me/role", h.Auth.ChangeRole)

			// Favorites
			protected.GET("/me/favorites", h.Auth.ListFavorites)
			protected.POST("/me/favorites/:listingId", h.Auth.AddFavorite)
			protected.DELETE("/me/favorites/:listingId", h.Auth.RemoveFavorite)

			// Sessions & password
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

			// Payments
			protected.POST("/payments", h.Payment.Create)
			protected.GET("/payments", h.Payment.ListMine)
			protected.GET("/payments/:id", h.Payment.GetByID)

			// Rentals
			protected.GET("/rentals", h.Rental.List)
			protected.POST("/rentals", h.Rental.Create)
			protected.GET("/rentals/:id", h.Rental.GetByID)
			protected.POST("/rentals/:id/payments", h.Rental.Pay)
			protected.POST("/rentals/:id/terminate", h.Rental.Terminate)
			protected.GET("/rentals/:id/requests", h.Rental.ListRequests)
			protected.POST("/rentals/:id/requests", h.Rental.Request)
			protected.POST("/rentals/:id/requests/:requestId/respond", h.Rental.Respond)

			// Visits
			protected.POST("/visits", h.Visit.Create)
			protected.GET("/visits", h.Visit.ListMyVisits)
			protected.POST("/visits/:id/confirm", h.Visit.Confirm)
			protected.POST("/visits/:id/cancel", h.Visit.Cancel)

			// Messages
			protected.POST("/messages", h.Message.Send)
			protected.GET("/messages/:other_user_id", h.Message.GetConversation)

			// Reviews
			protected.POST("/reviews", h.Review.Create)

			// Notifications
			protected.GET("/notifications", h.Notification.GetMyNotifications)
			protected.GET("/notifications/unread-count", h.Notification.UnreadCount)
			protected.PUT("/notifications/:id/read", h.Notification.MarkRead)
			protected.PUT("/notifications/read-all", h.Notification.MarkAllRead)

			// Agent routes
			agent := protected.Group("")
			agent.Use(authMiddleware.RequireRole("agent"))
			{
				agent.POST("/audits", h.Audit.Create)
			}
		}
	}

	return r
}
