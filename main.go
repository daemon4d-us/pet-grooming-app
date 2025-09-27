package main

import (
	"database/sql"
	"log"
	"os"

	"pet-grooming-app/internal/api"
	"pet-grooming-app/internal/config"
	"pet-grooming-app/internal/database"

	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found")
	}

	// Load configuration
	cfg := config.Load()

	// Initialize database
	var db *sql.DB
	if cfg.DatabaseURL != "" && cfg.DatabaseURL != "postgres://user:password@localhost/petgrooming?sslmode=disable" {
		var err error
		db, err = database.Connect(cfg.DatabaseURL)
		if err != nil {
			log.Printf("Warning: Failed to connect to database: %v", err)
			log.Println("Starting server without database (will return errors for API calls)...")
		} else {
			defer db.Close()
			// Run migrations
			if err := database.Migrate(db); err != nil {
				log.Printf("Warning: Failed to run migrations: %v", err)
			} else {
				log.Println("Database connected and migrated successfully")
			}
		}
	} else {
		log.Println("No database configured, starting server in demo mode...")
	}

	// Initialize API server
	server := api.NewServer(db, cfg)

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	if err := server.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}