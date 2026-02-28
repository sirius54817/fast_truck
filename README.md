# Fast Truck - Delivery Management App

A Flutter application for managing delivery requests between agents and drivers, with real-time tracking, verification systems, and Google Maps integration.

## Features

- **User Authentication** - Google Sign-In integration
- **Agent Verification** - Verification system for agents before creating requests
- **Driver Verification** - Verification system for drivers before accepting requests
- **Delivery Requests** - Create and manage delivery requests with load details
- **Google Maps Integration** - Address autocomplete and automatic distance calculation
- **Real-time Updates** - Firebase Firestore for real-time data synchronization
- **Contact Management** - Direct calling functionality between agents and drivers

## Prerequisites

- Flutter SDK (^3.11.0)
- Android Studio / Xcode (for mobile development)
- Firebase account with project setup
- Google Maps API key (with Places API and Distance Matrix API enabled)

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone <your-repository-url>
cd fast_truck
```

### 2. Setup Environment Variables
```bash
# Copy the example environment file
cp .env.example .env

# Edit .env and add your API keys
# See ENV_SETUP.md for detailed instructions
```

### 3. Add Firebase Configuration Files

**For Android:**
- Download `google-services.json` from Firebase Console
- Place it in `android/app/google-services.json`

**For iOS:**
- Download `GoogleService-Info.plist` from Firebase Console
- Place it in `ios/Runner/GoogleService-Info.plist`

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Run the App
```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── config/
│   └── app_config.dart          # Environment variables configuration
├── models/
│   ├── user_model.dart          # User data model
│   └── delivery_request_model.dart  # Delivery request model
├── pages/
│   ├── login_page.dart          # Authentication page
│   ├── home_page.dart           # Main dashboard
│   ├── new_request_page.dart    # Create delivery request
│   ├── agent_verification_page.dart  # Agent verification form
│   └── driver_verification_page.dart # Driver verification form
├── services/
│   ├── auth_service.dart        # Authentication logic
│   ├── user_service.dart        # User data management
│   └── delivery_request_service.dart  # Delivery request operations
├── ui/
│   ├── button.dart              # Custom button component
│   └── input.dart               # Custom input component
├── firebase_options.dart        # Firebase configuration
└── main.dart                    # App entry point
```

## 🔐 Security & API Keys

**Important:** This project uses environment variables to manage API keys securely.

- All sensitive keys are stored in `.env` (NOT committed to Git)
- See [SECURITY.md](SECURITY.md) for security best practices
- See [ENV_SETUP.md](ENV_SETUP.md) for detailed setup instructions

### Required API Keys
- Google Maps API Key (Places API, Distance Matrix API)
- Firebase configuration (multiple platform-specific keys)

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS

## 🔧 Development

### Code Structure
- **Models** - Data structures for users and requests
- **Services** - Business logic and Firebase operations
- **Pages** - UI screens and user interactions
- **UI Components** - Reusable widgets

### Key Technologies
- Flutter SDK
- Firebase (Auth, Firestore, Storage)
- Google Sign-In
- Google Maps API (Places, Distance Matrix)
- flutter_dotenv for environment management

## 📚 Documentation

- [ENV_SETUP.md](ENV_SETUP.md) - Environment setup guide
- [SECURITY.md](SECURITY.md) - Security practices and API key management
- [UI_COMPONENTS.md](UI_COMPONENTS.md) - UI component documentation

## 🤝 Contributing

1. Create a feature branch (`git checkout -b feature/amazing-feature`)
2. Commit your changes (`git commit -m 'Add amazing feature'`)
3. Push to the branch (`git push origin feature/amazing-feature`)
4. Open a Pull Request

## 🔒 Important Notes

### Before Pushing to GitHub
- ✅ Ensure `.env` is in `.gitignore`
- ✅ Never commit `google-services.json` or `GoogleService-Info.plist`
- ✅ Use `.env.example` as a template (with no real keys)
- ✅ Review `SECURITY.md` for best practices

### For Team Members
- Get API keys securely from project admin
- Follow setup instructions in `ENV_SETUP.md`
- Never share keys in public channels

## 🐛 Troubleshooting

**App won't start:**
- Verify `.env` file exists with all required variables
- Run `flutter clean && flutter pub get`
- Check Firebase configuration files are in correct locations

**Google Maps not working:**
- Verify API key in `.env`
- Ensure Places API and Distance Matrix API are enabled
- Check API key restrictions in Google Cloud Console

**Firebase errors:**
- Verify all Firebase variables in `.env` are correct
- Ensure `google-services.json` (Android) is properly placed
- Check Firebase project configuration

## 📄 License

[Add your license here]

## 👥 Team

[Add team members/contributors here]

## 📞 Support

For issues or questions, please [open an issue](../../issues) on GitHub.

---

Built with Flutter 💙
