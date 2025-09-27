package api

import (
	"database/sql"

	"pet-grooming-app/internal/config"
	"pet-grooming-app/internal/middleware"
	"pet-grooming-app/internal/services"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

type Server struct {
	router      *gin.Engine
	db          *sql.DB
	config      *config.Config
	authService *services.AuthService
}

func NewServer(db *sql.DB, cfg *config.Config) *Server {
	router := gin.Default()
	authService := services.NewAuthService(db, cfg.JWTSecret)

	server := &Server{
		router:      router,
		db:          db,
		config:      cfg,
		authService: authService,
	}

	server.setupRoutes()
	return server
}

func (s *Server) setupRoutes() {
	// CORS middleware - Allow all origins for development
	config := cors.DefaultConfig()
	config.AllowAllOrigins = true
	config.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
	config.AllowHeaders = []string{"Origin", "Content-Type", "Accept", "Authorization", "Content-Length"}
	config.AllowCredentials = true
	s.router.Use(cors.New(config))

	api := s.router.Group("/api/v1")

	// Public routes
	auth := api.Group("/auth")
	{
		auth.POST("/register", s.handleRegister)
		auth.POST("/login", s.handleLogin)
	}

	// Protected routes
	protected := api.Group("/")
	protected.Use(middleware.AuthMiddleware(s.authService))
	{
		// User routes
		users := protected.Group("/users")
		{
			users.GET("/profile", s.handleGetProfile)
			users.PUT("/profile", s.handleUpdateProfile)
		}

		// Pet routes
		pets := protected.Group("/pets")
		{
			pets.GET("", s.handleGetPets)      // Accept /pets without trailing slash
			pets.GET("/", s.handleGetPets)     // Accept /pets/ with trailing slash
			pets.POST("", s.handleCreatePet)   // Accept /pets without trailing slash
			pets.POST("/", s.handleCreatePet)  // Accept /pets/ with trailing slash
			pets.GET("/:id", s.handleGetPet)
			pets.PUT("/:id", s.handleUpdatePet)
			pets.DELETE("/:id", s.handleDeletePet)
		}

		// Service routes
		services := protected.Group("/services")
		{
			services.GET("", s.handleGetServices)   // Accept /services without trailing slash
			services.GET("/", s.handleGetServices)  // Accept /services/ with trailing slash
			services.GET("/:id", s.handleGetService)
		}

		// Provider routes (for service providers)
		provider := protected.Group("/provider/services")
		// provider.Use(middleware.RequireRole(models.RoleProvider))
		{
			provider.POST("/", s.handleCreateService)
			provider.PUT("/:id", s.handleUpdateService)
			provider.DELETE("/:id", s.handleDeleteService)
		}

		// Booking routes
		bookings := protected.Group("/bookings")
		{
			bookings.GET("", s.handleGetBookings)     // Accept /bookings without trailing slash
			bookings.GET("/", s.handleGetBookings)    // Accept /bookings/ with trailing slash
			bookings.POST("", s.handleCreateBooking)  // Accept /bookings without trailing slash
			bookings.POST("/", s.handleCreateBooking) // Accept /bookings/ with trailing slash
			bookings.GET("/:id", s.handleGetBooking)
			bookings.PUT("/:id", s.handleUpdateBooking)
			bookings.DELETE("/:id", s.handleCancelBooking)
		}
	}

	// Health check
	s.router.GET("/health", s.handleHealthCheck)
}

func (s *Server) Run(addr string) error {
	return s.router.Run(addr)
}