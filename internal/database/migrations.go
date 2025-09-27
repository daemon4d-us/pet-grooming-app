package database

import (
	"database/sql"
	"fmt"
)

func Migrate(db *sql.DB) error {
	migrations := []string{
		`CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`,

		`CREATE TABLE IF NOT EXISTS users (
			id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
			email VARCHAR(255) UNIQUE NOT NULL,
			password_hash VARCHAR(255) NOT NULL,
			first_name VARCHAR(100) NOT NULL,
			last_name VARCHAR(100) NOT NULL,
			phone VARCHAR(20),
			address TEXT,
			role VARCHAR(20) NOT NULL DEFAULT 'owner',
			created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
			updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
		);`,

		`CREATE TABLE IF NOT EXISTS pets (
			id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
			owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
			name VARCHAR(100) NOT NULL,
			species VARCHAR(50) NOT NULL,
			breed VARCHAR(100),
			age INTEGER,
			weight DECIMAL(5,2),
			color VARCHAR(50),
			notes TEXT,
			photo_url TEXT,
			created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
			updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
		);`,

		`CREATE TABLE IF NOT EXISTS services (
			id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
			provider_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
			name VARCHAR(200) NOT NULL,
			description TEXT,
			category VARCHAR(50) NOT NULL,
			price DECIMAL(10,2) NOT NULL,
			duration_minutes INTEGER NOT NULL,
			available BOOLEAN DEFAULT true,
			created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
			updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
		);`,

		`CREATE TABLE IF NOT EXISTS bookings (
			id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
			user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
			pet_id UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
			service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
			provider_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
			scheduled_time TIMESTAMP WITH TIME ZONE NOT NULL,
			status VARCHAR(20) NOT NULL DEFAULT 'pending',
			notes TEXT,
			total_price DECIMAL(10,2) NOT NULL,
			created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
			updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
		);`,

		`CREATE INDEX IF NOT EXISTS idx_pets_owner_id ON pets(owner_id);`,
		`CREATE INDEX IF NOT EXISTS idx_services_provider_id ON services(provider_id);`,
		`CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);`,
		`CREATE INDEX IF NOT EXISTS idx_bookings_provider_id ON bookings(provider_id);`,
		`CREATE INDEX IF NOT EXISTS idx_bookings_scheduled_time ON bookings(scheduled_time);`,
	}

	for _, migration := range migrations {
		if _, err := db.Exec(migration); err != nil {
			return fmt.Errorf("failed to execute migration: %w", err)
		}
	}

	return nil
}