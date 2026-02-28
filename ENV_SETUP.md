# Environment Setup Guide

This project uses environment variables to securely manage API keys and sensitive configuration. Follow these steps to set up your development environment.

## Initial Setup

1. **Copy the environment template file:**
   ```bash
   cp .env.example .env
   ```

2. **Fill in your API keys in the `.env` file:**
   - Google Maps API Key
   - Firebase configuration keys
   - Other sensitive credentials

## Required Environment Variables

### Google Maps API
- `GOOGLE_MAPS_API_KEY` - Your Google Maps API key for address autocomplete and distance calculation

### Firebase Configuration
Get these values from your Firebase Console:
- `FIREBASE_API_KEY_WEB` - Firebase Web API Key
- `FIREBASE_API_KEY_ANDROID` - Firebase Android API Key
- `FIREBASE_API_KEY_IOS` - Firebase iOS API Key
- `FIREBASE_API_KEY_MACOS` - Firebase macOS API Key
- `FIREBASE_API_KEY_WINDOWS` - Firebase Windows API Key
- `FIREBASE_PROJECT_ID` - Your Firebase Project ID
- `FIREBASE_MESSAGING_SENDER_ID` - Firebase Cloud Messaging Sender ID
- `FIREBASE_STORAGE_BUCKET` - Firebase Storage Bucket
- `FIREBASE_AUTH_DOMAIN` - Firebase Auth Domain
- `FIREBASE_APP_ID_WEB` - Firebase Web App ID
- `FIREBASE_APP_ID_ANDROID` - Firebase Android App ID
- `FIREBASE_APP_ID_IOS` - Firebase iOS App ID
- `FIREBASE_APP_ID_WINDOWS` - Firebase Windows App ID
- `FIREBASE_MEASUREMENT_ID_WEB` - Firebase Web Measurement ID
- `FIREBASE_MEASUREMENT_ID_WINDOWS` - Firebase Windows Measurement ID
- `FIREBASE_IOS_BUNDLE_ID` - iOS Bundle Identifier

## Firebase Configuration Files

In addition to the `.env` file, you'll need:

### Android
Place your `google-services.json` file in:
```
android/app/google-services.json
```

### iOS
Place your `GoogleService-Info.plist` file in:
```
ios/Runner/GoogleService-Info.plist
```

## Important Notes

- **Never commit the `.env` file to version control** - it contains sensitive API keys
- **Never commit Firebase config files** (`google-services.json`, `GoogleService-Info.plist`)
- The `.gitignore` file is already configured to exclude these files
- Share API keys securely with team members (use password manager, secure chat, etc.)

## Getting API Keys

### Google Maps API
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable these APIs:
   - Maps JavaScript API
   - Places API
   - Distance Matrix API
4. Generate an API key
5. Restrict the API key appropriately for security

### Firebase
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings
4. Copy the configuration values for each platform
5. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

## Running the App

After setting up your `.env` file:

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Troubleshooting

**Error: "Unable to load asset: .env"**
- Make sure `.env` file exists in project root
- Run `flutter pub get` again
- Try `flutter clean` then `flutter pub get`

**Firebase initialization error:**
- Verify all Firebase config values are correct in `.env`
- Ensure `google-services.json` (Android) is in the correct location
- Check that package name matches Firebase project configuration

**Google Maps not working:**
- Verify `GOOGLE_MAPS_API_KEY` is correct
- Ensure required APIs are enabled in Google Cloud Console
- Check API key restrictions aren't blocking your app
