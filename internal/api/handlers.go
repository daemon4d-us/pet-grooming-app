package api

import (
	"database/sql"
	"fmt"
	"net/http"
	"time"

	"pet-grooming-app/internal/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func (s *Server) handleHealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":  "healthy",
		"service": "pet-grooming-api",
	})
}

func (s *Server) handleRegister(c *gin.Context) {
	var req models.CreateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user, err := s.authService.Register(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
		return
	}

	c.JSON(http.StatusCreated, user)
}

func (s *Server) handleLogin(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	response, err := s.authService.Login(req)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		return
	}

	c.JSON(http.StatusOK, response)
}

func (s *Server) handleGetProfile(c *gin.Context) {
	userIDInterface, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found"})
		return
	}

	userID, ok := userIDInterface.(uuid.UUID)
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID type"})
		return
	}

	var user models.User
	query := `
		SELECT id, email, first_name, last_name, phone, address, role, created_at, updated_at
		FROM users WHERE id = $1`

	err := s.db.QueryRow(query, userID).Scan(
		&user.ID, &user.Email, &user.FirstName, &user.LastName,
		&user.Phone, &user.Address, &user.Role, &user.CreatedAt, &user.UpdatedAt)

	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	c.JSON(http.StatusOK, user)
}

func (s *Server) handleUpdateProfile(c *gin.Context) {
	c.JSON(http.StatusNotImplemented, gin.H{"error": "Not implemented"})
}

func (s *Server) handleGetPets(c *gin.Context) {
	userIDInterface, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found"})
		return
	}

	userID, ok := userIDInterface.(uuid.UUID)
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID type"})
		return
	}

	query := `
		SELECT id, owner_id, name, species, breed, age, weight, color, notes, photo_url, created_at, updated_at
		FROM pets WHERE owner_id = $1
		ORDER BY created_at DESC`

	rows, err := s.db.Query(query, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch pets"})
		return
	}
	defer rows.Close()

	pets := []models.Pet{}
	for rows.Next() {
		var pet models.Pet
		err := rows.Scan(
			&pet.ID, &pet.OwnerID, &pet.Name, &pet.Species, &pet.Breed,
			&pet.Age, &pet.Weight, &pet.Color, &pet.Notes, &pet.PhotoURL,
			&pet.CreatedAt, &pet.UpdatedAt,
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse pet data"})
			return
		}
		pets = append(pets, pet)
	}

	c.JSON(http.StatusOK, pets)
}

func (s *Server) handleCreatePet(c *gin.Context) {
	userIDInterface, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found"})
		return
	}

	userID, ok := userIDInterface.(uuid.UUID)
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID type"})
		return
	}

	var req models.CreatePetRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	pet := models.Pet{
		ID:        uuid.New(),
		OwnerID:   userID,
		Name:      req.Name,
		Species:   req.Species,
		Breed:     req.Breed,
		Age:       req.Age,
		Weight:    req.Weight,
		Color:     req.Color,
		Notes:     req.Notes,
		PhotoURL:  req.PhotoURL,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	query := `
		INSERT INTO pets (id, owner_id, name, species, breed, age, weight, color, notes, photo_url, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
		RETURNING id, created_at, updated_at`

	err := s.db.QueryRow(
		query, pet.ID, pet.OwnerID, pet.Name, pet.Species, pet.Breed,
		pet.Age, pet.Weight, pet.Color, pet.Notes, pet.PhotoURL,
		pet.CreatedAt, pet.UpdatedAt,
	).Scan(&pet.ID, &pet.CreatedAt, &pet.UpdatedAt)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create pet"})
		return
	}

	c.JSON(http.StatusCreated, pet)
}

func (s *Server) handleGetPet(c *gin.Context) {
	userIDInterface, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found"})
		return
	}

	userID, ok := userIDInterface.(uuid.UUID)
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID type"})
		return
	}

	petIDStr := c.Param("id")
	petID, err := uuid.Parse(petIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid pet ID"})
		return
	}

	var pet models.Pet
	query := `
		SELECT id, owner_id, name, species, breed, age, weight, color, notes, photo_url, created_at, updated_at
		FROM pets WHERE id = $1 AND owner_id = $2`

	err = s.db.QueryRow(query, petID, userID).Scan(
		&pet.ID, &pet.OwnerID, &pet.Name, &pet.Species, &pet.Breed,
		&pet.Age, &pet.Weight, &pet.Color, &pet.Notes, &pet.PhotoURL,
		&pet.CreatedAt, &pet.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pet not found"})
		return
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch pet"})
		return
	}

	c.JSON(http.StatusOK, pet)
}

func (s *Server) handleUpdatePet(c *gin.Context) {
	userIDInterface, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found"})
		return
	}

	userID, ok := userIDInterface.(uuid.UUID)
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID type"})
		return
	}

	petIDStr := c.Param("id")
	petID, err := uuid.Parse(petIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid pet ID"})
		return
	}

	var req models.UpdatePetRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// First verify the pet exists and belongs to the user
	var existingPet models.Pet
	checkQuery := `SELECT id FROM pets WHERE id = $1 AND owner_id = $2`
	err = s.db.QueryRow(checkQuery, petID, userID).Scan(&existingPet.ID)
	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pet not found"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify pet ownership"})
		return
	}

	// Build dynamic update query
	query := `UPDATE pets SET updated_at = $1`
	args := []interface{}{time.Now()}
	argCount := 2

	if req.Name != nil {
		query += fmt.Sprintf(", name = $%d", argCount)
		args = append(args, *req.Name)
		argCount++
	}
	if req.Species != nil {
		query += fmt.Sprintf(", species = $%d", argCount)
		args = append(args, *req.Species)
		argCount++
	}
	if req.Breed != nil {
		query += fmt.Sprintf(", breed = $%d", argCount)
		args = append(args, *req.Breed)
		argCount++
	}
	if req.Age != nil {
		query += fmt.Sprintf(", age = $%d", argCount)
		args = append(args, *req.Age)
		argCount++
	}
	if req.Weight != nil {
		query += fmt.Sprintf(", weight = $%d", argCount)
		args = append(args, *req.Weight)
		argCount++
	}
	if req.Color != nil {
		query += fmt.Sprintf(", color = $%d", argCount)
		args = append(args, *req.Color)
		argCount++
	}
	if req.Notes != nil {
		query += fmt.Sprintf(", notes = $%d", argCount)
		args = append(args, *req.Notes)
		argCount++
	}
	if req.PhotoURL != nil {
		query += fmt.Sprintf(", photo_url = $%d", argCount)
		args = append(args, *req.PhotoURL)
		argCount++
	}

	query += fmt.Sprintf(" WHERE id = $%d AND owner_id = $%d", argCount, argCount+1)
	args = append(args, petID, userID)

	_, err = s.db.Exec(query, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update pet"})
		return
	}

	// Fetch and return the updated pet
	var pet models.Pet
	selectQuery := `
		SELECT id, owner_id, name, species, breed, age, weight, color, notes, photo_url, created_at, updated_at
		FROM pets WHERE id = $1`

	err = s.db.QueryRow(selectQuery, petID).Scan(
		&pet.ID, &pet.OwnerID, &pet.Name, &pet.Species, &pet.Breed,
		&pet.Age, &pet.Weight, &pet.Color, &pet.Notes, &pet.PhotoURL,
		&pet.CreatedAt, &pet.UpdatedAt,
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch updated pet"})
		return
	}

	c.JSON(http.StatusOK, pet)
}

func (s *Server) handleDeletePet(c *gin.Context) {
	userIDInterface, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found"})
		return
	}

	userID, ok := userIDInterface.(uuid.UUID)
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID type"})
		return
	}

	petIDStr := c.Param("id")
	petID, err := uuid.Parse(petIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid pet ID"})
		return
	}

	query := `DELETE FROM pets WHERE id = $1 AND owner_id = $2`
	result, err := s.db.Exec(query, petID, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete pet"})
		return
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify deletion"})
		return
	}

	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pet not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Pet deleted successfully"})
}

func (s *Server) handleGetServices(c *gin.Context) {
	// For now, return an empty list of services
	// In a real implementation, this would query the database for available services
	c.JSON(http.StatusOK, []interface{}{})
}

func (s *Server) handleGetService(c *gin.Context) {
	c.JSON(http.StatusNotImplemented, gin.H{"error": "Not implemented"})
}

func (s *Server) handleCreateService(c *gin.Context) {
	c.JSON(http.StatusNotImplemented, gin.H{"error": "Not implemented"})
}

func (s *Server) handleUpdateService(c *gin.Context) {
	c.JSON(http.StatusNotImplemented, gin.H{"error": "Not implemented"})
}

func (s *Server) handleDeleteService(c *gin.Context) {
	c.JSON(http.StatusNotImplemented, gin.H{"error": "Not implemented"})
}

func (s *Server) handleGetBookings(c *gin.Context) {
	userIDInterface, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found"})
		return
	}

	userID, ok := userIDInterface.(uuid.UUID)
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID type"})
		return
	}

	// For now, return an empty list of bookings
	// In a real implementation, this would query the database for user's bookings
	_ = userID // Use the userID variable to avoid compiler warning

	c.JSON(http.StatusOK, []interface{}{})
}

func (s *Server) handleCreateBooking(c *gin.Context) {
	c.JSON(http.StatusNotImplemented, gin.H{"error": "Not implemented"})
}

func (s *Server) handleGetBooking(c *gin.Context) {
	c.JSON(http.StatusNotImplemented, gin.H{"error": "Not implemented"})
}

func (s *Server) handleUpdateBooking(c *gin.Context) {
	c.JSON(http.StatusNotImplemented, gin.H{"error": "Not implemented"})
}

func (s *Server) handleCancelBooking(c *gin.Context) {
	c.JSON(http.StatusNotImplemented, gin.H{"error": "Not implemented"})
}