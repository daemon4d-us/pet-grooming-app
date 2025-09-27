package models

import (
	"time"

	"github.com/google/uuid"
)

type Booking struct {
	ID            uuid.UUID     `json:"id" db:"id"`
	UserID        uuid.UUID     `json:"user_id" db:"user_id"`
	PetID         uuid.UUID     `json:"pet_id" db:"pet_id"`
	ServiceID     uuid.UUID     `json:"service_id" db:"service_id"`
	ProviderID    uuid.UUID     `json:"provider_id" db:"provider_id"`
	ScheduledTime time.Time     `json:"scheduled_time" db:"scheduled_time"`
	Status        BookingStatus `json:"status" db:"status"`
	Notes         string        `json:"notes" db:"notes"`
	TotalPrice    float64       `json:"total_price" db:"total_price"`
	CreatedAt     time.Time     `json:"created_at" db:"created_at"`
	UpdatedAt     time.Time     `json:"updated_at" db:"updated_at"`
}

type BookingStatus string

const (
	StatusPending    BookingStatus = "pending"
	StatusConfirmed  BookingStatus = "confirmed"
	StatusInProgress BookingStatus = "in_progress"
	StatusCompleted  BookingStatus = "completed"
	StatusCancelled  BookingStatus = "cancelled"
)

type CreateBookingRequest struct {
	PetID         uuid.UUID `json:"pet_id" binding:"required"`
	ServiceID     uuid.UUID `json:"service_id" binding:"required"`
	ScheduledTime time.Time `json:"scheduled_time" binding:"required"`
	Notes         string    `json:"notes"`
}

type UpdateBookingRequest struct {
	ScheduledTime *time.Time     `json:"scheduled_time"`
	Status        *BookingStatus `json:"status"`
	Notes         *string        `json:"notes"`
}

type BookingWithDetails struct {
	Booking
	Pet     Pet     `json:"pet"`
	Service Service `json:"service"`
	User    User    `json:"user"`
}