# Security & Configuration

This document explains how API keys and sensitive data are managed in this project.

## Overview

All sensitive API keys and configuration values are stored in environment variables using the `flutter_dotenv` package, similar to how web applications use `.env` files.

## Files to Keep Secret

The following files contain sensitive information and are **excluded from Git**:

### ✅ Already Gitignored
- `.env` - Contains all API keys and sensitive configuration
- `android/app/google-services.json` - Firebase Android configuration
- `ios/Runner/GoogleService-Info.plist` - Firebase iOS configuration

### ✅ Safe to Commit
- `.env.example` - Template showing required variables (no real values)
- `lib/config/app_config.dart` - Code that reads environment variables
- `lib/firebase_options.dart` - Code that uses environment variables

## How It Works

### 1. Environment Variables (.env)
All API keys are stored in `.env` file at project root:
```env
GOOGLE_MAPS_API_KEY=your_actual_key_here
FIREBASE_API_KEY_ANDROID=your_firebase_key
# ... etc
```

### 2. AppConfig Helper (lib/config/app_config.dart)
Provides easy access to environment variables:
```dart
import 'package:fast_truck/config/app_config.dart';

// Usage in code
final apiKey = AppConfig.googleMapsApiKey;
```

### 3. Main App Initialization (lib/main.dart)
Loads environment variables before app starts:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");  // Load .env file
  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

### 4. Firebase Options (lib/firebase_options.dart)
Uses environment variables instead of hardcoded values:
```dart
static FirebaseOptions get android => FirebaseOptions(
  apiKey: AppConfig.firebaseApiKeyAndroid,  // From .env
  appId: AppConfig.firebaseAppIdAndroid,     // From .env
  // ...
);
```

## For New Developers

### First Time Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd fast_truck
   ```

2. **Create your `.env` file**
   ```bash
   cp .env.example .env
   ```

3. **Get API keys** from project admin or Firebase Console

4. **Fill in `.env` with your keys**
   - Edit `.env` file
   - Replace all placeholder values with actual API keys
   - See `ENV_SETUP.md` for detailed instructions

5. **Add Firebase configuration files**
   - Get `google-services.json` from Firebase Console
   - Place in `android/app/google-services.json`
   - Get `GoogleService-Info.plist` from Firebase Console  
   - Place in `ios/Runner/GoogleService-Info.plist`

6. **Install dependencies and run**
   ```bash
   flutter pub get
   flutter run
   ```

## For Repository Owner (Before Pushing to GitHub)

### ✅ Checklist Before First Push

- [x] `.env` is in `.gitignore`
- [x] `google-services.json` is in `.gitignore`
- [x] `GoogleService-Info.plist` is in `.gitignore`
- [x] `.env.example` has placeholder values (no real keys)
- [x] Code uses `AppConfig` instead of hardcoded keys
- [x] Documentation is complete (`ENV_SETUP.md`)

### Verify No Secrets in Git History

Before pushing, verify no secrets were accidentally committed:

```bash
# Check current status
git status

# Review what will be committed
git diff --cached

# Make sure .env is not tracked
git ls-files | grep "\.env$"  # Should return nothing

# Make sure google-services.json is not tracked
git ls-files | grep "google-services.json"  # Should return nothing
```

### Safe to Push

These files are safe to push and don't contain secrets:
- `.env.example` - Template only
- `lib/config/app_config.dart` - Reads from env
- `lib/firebase_options.dart` - Uses AppConfig
- `ENV_SETUP.md` - Documentation
- `.gitignore` - Excludes secret files

## API Key Security Best Practices

### Google Maps API
- ✅ Restrict API key to your app's package name
- ✅ Enable only required APIs (Places, Distance Matrix)
- ✅ Set quota limits to prevent abuse
- ✅ Monitor usage in Google Cloud Console

### Firebase
- ✅ Configure Firebase Security Rules
- ✅ Enable Firebase App Check
- ✅ Restrict database/storage access rules
- ✅ Monitor usage in Firebase Console

### General
- ❌ Never commit `.env` file
- ❌ Never hardcode API keys in source code
- ❌ Never share keys in public channels
- ✅ Use different keys for dev/staging/production
- ✅ Rotate keys if compromised
- ✅ Share keys securely (password manager, encrypted chat)

## What If Keys Are Leaked?

If API keys are accidentally exposed:

1. **Immediately revoke** the exposed keys in respective consoles
2. **Generate new keys** 
3. **Update** `.env` file with new keys
4. **Rotate** for all team members
5. **Review** git history for any commits with keys
6. **Consider** BFG Repo-Cleaner to purge sensitive data from git history

## Team Collaboration

### Sharing Keys with Team
Use one of these secure methods:
- Password manager (1Password, LastPass, Bitwarden)
- Encrypted messaging (Signal, private Slack/Discord with encryption)
- Secure file sharing (encrypted email, secure cloud with access control)

### DO NOT
- Email keys in plain text
- Post keys in public Slack/Discord channels
- Commit keys to repository
- Share keys in screenshots

## Environment Variables Used

See `.env.example` for complete list. Key variables:

| Variable | Purpose | Where to Get |
|----------|---------|--------------|
| `GOOGLE_MAPS_API_KEY` | Maps, Places, Distance | Google Cloud Console |
| `FIREBASE_API_KEY_*` | Firebase authentication | Firebase Console > Project Settings |
| `FIREBASE_PROJECT_ID` | Firebase project identifier | Firebase Console > Project Settings |
| `FIREBASE_APP_ID_*` | Firebase app identifier | Firebase Console > Project Settings |

## Questions?

Refer to `ENV_SETUP.md` for detailed setup instructions or contact the project maintainer.
