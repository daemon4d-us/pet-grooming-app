# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a pet grooming application project - a mobile application for pet owners to book care services like grooming and sitting for their pets. The backend is implemented in Go and designed for deployment to Google Cloud Platform.

## Development Commands

### Local Development
```bash
# Install dependencies
go mod tidy

# Run with Docker Compose (includes PostgreSQL)
docker-compose up

# Run locally (requires PostgreSQL running)
go run main.go

# Build the application
go build -o bin/app main.go

# Run tests
go test ./...
```

### Database
```bash
# Start only PostgreSQL
docker-compose up postgres

# Database will auto-migrate on startup
```

### GCP Deployment
```bash
# Build and deploy to Cloud Run
gcloud builds submit --config cloudbuild.yaml

# Manual Docker build
docker build -t gcr.io/PROJECT_ID/pet-grooming-api .
docker push gcr.io/PROJECT_ID/pet-grooming-api
```

## Architecture

### Backend Structure
- **main.go**: Application entry point
- **internal/models/**: Domain models (User, Pet, Service, Booking)
- **internal/api/**: REST API handlers and server setup
- **internal/database/**: Database connection and migrations
- **internal/middleware/**: Authentication and authorization
- **internal/services/**: Business logic (AuthService)
- **internal/config/**: Configuration management

### Key Features
- JWT-based authentication
- Role-based access control (Owner, Provider, Admin)
- PostgreSQL database with auto-migrations
- RESTful API for pet management, service booking
- Docker containerization
- GCP Cloud Run deployment ready

### API Endpoints
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login
- `GET /api/v1/users/profile` - Get user profile
- `GET|POST /api/v1/pets/` - Pet management
- `GET /api/v1/services/` - Service listing
- `GET|POST /api/v1/bookings/` - Booking management

### Environment Variables
Copy `.env.example` to `.env` and configure:
- `DATABASE_URL`: PostgreSQL connection string
- `JWT_SECRET`: Secret for JWT token signing
- `PORT`: Server port (default: 8080)

## Mobile App (Flutter)

### Flutter Development Commands
```bash
# Navigate to mobile directory
cd mobile

# Install dependencies
flutter pub get

# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android

# Build for release
flutter build apk --release
flutter build ios --release

# Run tests
flutter test
```

### Mobile App Structure
- **lib/main.dart**: App entry point with providers
- **lib/models/**: Domain models matching backend
- **lib/providers/**: State management (AuthProvider, PetProvider, BookingProvider)
- **lib/services/**: API service layer with Dio HTTP client
- **lib/screens/**: UI screens organized by feature
- **lib/utils/**: Theme, routing, and utilities
- **lib/config/**: App configuration and constants

### Key Mobile Features
- JWT-based authentication with secure storage
- State management using Provider pattern
- HTTP API integration with Dio
- Navigation using GoRouter
- Responsive Material Design UI
- Image picker for pet photos
- Date/time pickers for booking
- Pull-to-refresh functionality
- Loading states and error handling

### Mobile Screens
- **Authentication**: Login, register, splash
- **Home**: Dashboard with quick actions and recent bookings
- **Pets**: Pet list, add/edit pet forms
- **Services**: Service catalog with filtering
- **Bookings**: Booking history and creation flow
- **Profile**: User profile and settings

### Configuration
Update `lib/config/app_config.dart` for:
- API base URL (development vs production)
- Timeout settings
- Storage keys