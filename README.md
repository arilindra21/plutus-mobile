# Plutus Mobile

A modern expense management and financial tracking mobile application built with Flutter.

## Features

- **Expense Management** - Create, track, and manage expenses with receipt capture
- **Budget Overview** - Monitor spending across different categories
- **Card Management** - View and manage corporate/virtual cards
- **Transaction History** - Complete history of all financial transactions
- **Approval Workflow** - Multi-level expense approval system
- **Notifications** - Real-time updates on expense status changes

## Tech Stack

- **Framework**: Flutter 3.11+
- **State Management**: Provider
- **Networking**: Dio with interceptors
- **Local Storage**: SQLite (sqflite), Shared Preferences
- **Security**: Flutter Secure Storage
- **UI Components**: Material Design, Google Fonts, Flutter SVG

## Prerequisites

- Flutter SDK 3.11.0 or higher
- Dart SDK 3.11.0 or higher
- Android Studio / VS Code with Flutter extensions
- For iOS: Xcode 14+ (macOS only)

## Getting Started

### Installation

```bash
# Clone the repository
git clone https://github.com/arilindra21/plutus-mobile.git
cd plutus-mobile

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Environment Configuration

The app uses compile-time environment variables. Configure the API endpoint:

```bash
# Development (default uses staging API)
flutter run

# Production
flutter run --dart-define=API_BASE_URL=https://your-production-api.com
```

### Building for Different Platforms

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release

# Web
flutter build web --release
```

## Cloud Run Deployment

This application is configured for deployment on Google Cloud Run as a Flutter Web application.

### Prerequisites

- Google Cloud SDK installed and configured
- Docker installed (for local testing)
- Google Cloud project with Cloud Run API enabled

### Deploy to Cloud Run

```bash
# Build and push to Google Container Registry
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/plutus-mobile

# Deploy to Cloud Run
gcloud run deploy plutus-mobile \
  --image gcr.io/YOUR_PROJECT_ID/plutus-mobile \
  --platform managed \
  --region asia-southeast2 \
  --allow-unauthenticated
```

### Local Docker Testing

```bash
# Build the Docker image
docker build -t plutus-mobile .

# Run locally
docker run -p 8080:8080 plutus-mobile

# Access at http://localhost:8080
```

### Build with Custom API URL

```bash
# Using Cloud Build with custom API URL
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/plutus-mobile \
  --build-arg API_BASE_URL=https://your-api.com
```

## Project Structure

```
lib/
├── config/          # Environment and app configuration
├── constants/       # App constants and static data
├── core/            # Core theme, widgets, and design tokens
├── models/          # Data models
├── providers/       # State management providers
├── screens/         # UI screens
│   ├── approver/    # Approval workflow screens
│   ├── auth/        # Authentication screens
│   ├── budget/      # Budget management screens
│   ├── cards/       # Card management screens
│   ├── expenses/    # Expense management screens
│   ├── history/     # Transaction history
│   ├── home/        # Home dashboard
│   └── notifications/
├── services/        # API services and data layer
│   ├── api/         # API clients and services
│   └── models/      # DTOs and response models
├── utils/           # Utility functions
└── widgets/         # Reusable widgets
```

## API Integration

The app connects to a backend API for:
- User authentication (JWT-based)
- Expense CRUD operations
- Budget management
- Transaction tracking
- Approval workflows

Default staging API: `https://expense-api-staging-740443181568.asia-southeast2.run.app`

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is proprietary software. All rights reserved.
