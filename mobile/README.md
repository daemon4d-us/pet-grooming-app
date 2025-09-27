# Pet Grooming Mobile App

Flutter mobile application for the Pet Grooming service platform.

## Features

- **Authentication**: User registration and login
- **Pet Management**: Add, view, and manage pet profiles
- **Service Booking**: Browse services and book appointments
- **Booking Management**: View and manage appointments
- **Profile**: User profile and settings

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- iOS Simulator / Android Emulator
- Running backend API (see parent directory)

### Installation

1. Navigate to the mobile directory:
   ```bash
   cd mobile
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Update API configuration in `lib/config/app_config.dart`:
   ```dart
   static const String baseUrl = 'http://your-api-url/api/v1';
   ```

4. Run the app:
   ```bash
   # iOS
   flutter run -d ios

   # Android
   flutter run -d android
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── config/                   # Configuration
├── models/                   # Data models
├── providers/                # State management
├── services/                 # API services
├── screens/                  # UI screens
│   ├── auth/                # Authentication screens
│   ├── home/                # Home dashboard
│   ├── pets/                # Pet management
│   ├── bookings/            # Booking management
│   ├── services/            # Service catalog
│   └── profile/             # User profile
├── utils/                   # Utilities
└── widgets/                 # Shared widgets
```

## State Management

Uses Provider pattern for state management:
- `AuthProvider`: Authentication state
- `PetProvider`: Pet data management
- `BookingProvider`: Booking and service data

## API Integration

- HTTP client: Dio
- Authentication: JWT tokens with secure storage
- Error handling and loading states
- Automatic token refresh

## Building for Release

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Testing

```bash
flutter test
```

## Dependencies

Key packages:
- `provider`: State management
- `dio`: HTTP client
- `go_router`: Navigation
- `flutter_secure_storage`: Secure token storage
- `image_picker`: Photo selection
- `intl`: Date formatting