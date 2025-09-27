package models

import (
	"time"

	"github.com/google/uuid"
)

type Service struct {
	ID          uuid.UUID   `json:"id" db:"id"`
	ProviderID  uuid.UUID   `json:"provider_id" db:"provider_id"`
	Name        string      `json:"name" db:"name"`
	Description string      `json:"description" db:"description"`
	Category    ServiceType `json:"category" db:"category"`
	Price       float64     `json:"price" db:"price"`
	Duration    int         `json:"duration" db:"duration_minutes"`
	Available   bool        `json:"available" db:"available"`
	CreatedAt   time.Time   `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time   `json:"updated_at" db:"updated_at"`
}

type ServiceType string

const (
	ServiceGrooming ServiceType = "grooming"
	ServiceSitting  ServiceType = "sitting"
	ServiceWalking  ServiceType = "walking"
	ServiceTraining ServiceType = "training"
	ServiceBoarding ServiceType = "boarding"
)

type CreateServiceRequest struct {
	Name        string      `json:"name" binding:"required"`
	Description string      `json:"description"`
	Category    ServiceType `json:"category" binding:"required"`
	Price       float64     `json:"price" binding:"required,min=0"`
	Duration    int         `json:"duration" binding:"required,min=1"`
	Available   bool        `json:"available"`
}

type UpdateServiceRequest struct {
	Name        *string      `json:"name"`
	Description *string      `json:"description"`
	Category    *ServiceType `json:"category"`
	Price       *float64     `json:"price"`
	Duration    *int         `json:"duration"`
	Available   *bool        `json:"available"`
}