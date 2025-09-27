package models

import (
	"time"

	"github.com/google/uuid"
)

type Pet struct {
	ID        uuid.UUID `json:"id" db:"id"`
	OwnerID   uuid.UUID `json:"owner_id" db:"owner_id"`
	Name      string    `json:"name" db:"name"`
	Species   string    `json:"species" db:"species"`
	Breed     string    `json:"breed" db:"breed"`
	Age       int       `json:"age" db:"age"`
	Weight    float64   `json:"weight" db:"weight"`
	Color     string    `json:"color" db:"color"`
	Notes     string    `json:"notes" db:"notes"`
	PhotoURL  string    `json:"photo_url" db:"photo_url"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

type CreatePetRequest struct {
	Name     string  `json:"name" binding:"required"`
	Species  string  `json:"species" binding:"required"`
	Breed    string  `json:"breed"`
	Age      int     `json:"age" binding:"min=0"`
	Weight   float64 `json:"weight" binding:"min=0"`
	Color    string  `json:"color"`
	Notes    string  `json:"notes"`
	PhotoURL string  `json:"photo_url"`
}

type UpdatePetRequest struct {
	Name     *string  `json:"name"`
	Species  *string  `json:"species"`
	Breed    *string  `json:"breed"`
	Age      *int     `json:"age"`
	Weight   *float64 `json:"weight"`
	Color    *string  `json:"color"`
	Notes    *string  `json:"notes"`
	PhotoURL *string  `json:"photo_url"`
}