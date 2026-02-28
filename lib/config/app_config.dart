import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App configuration class for accessing environment variables
/// 
/// Usage:
/// ```dart
/// final apiKey = AppConfig.googleMapsApiKey;
/// ```
class AppConfig {
  // Google Maps API Key
  static String get googleMapsApiKey => 
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  // Firebase Configuration
  static String get firebaseApiKeyWeb => 
      dotenv.env['FIREBASE_API_KEY_WEB'] ?? '';
  
  static String get firebaseApiKeyAndroid => 
      dotenv.env['FIREBASE_API_KEY_ANDROID'] ?? '';
  
  static String get firebaseApiKeyIOS => 
      dotenv.env['FIREBASE_API_KEY_IOS'] ?? '';
  
  static String get firebaseApiKeyMacOS => 
      dotenv.env['FIREBASE_API_KEY_MACOS'] ?? '';
  
  static String get firebaseApiKeyWindows => 
      dotenv.env['FIREBASE_API_KEY_WINDOWS'] ?? '';

  static String get firebaseProjectId => 
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  
  static String get firebaseMessagingSenderId => 
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  
  static String get firebaseStorageBucket => 
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  
  static String get firebaseAuthDomain => 
      dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';

  // Firebase App IDs
  static String get firebaseAppIdWeb => 
      dotenv.env['FIREBASE_APP_ID_WEB'] ?? '';
  
  static String get firebaseAppIdAndroid => 
      dotenv.env['FIREBASE_APP_ID_ANDROID'] ?? '';
  
  static String get firebaseAppIdIOS => 
      dotenv.env['FIREBASE_APP_ID_IOS'] ?? '';
  
  static String get firebaseAppIdWindows => 
      dotenv.env['FIREBASE_APP_ID_WINDOWS'] ?? '';

  // Firebase Measurement IDs
  static String get firebaseMeasurementIdWeb => 
      dotenv.env['FIREBASE_MEASUREMENT_ID_WEB'] ?? '';
  
  static String get firebaseMeasurementIdWindows => 
      dotenv.env['FIREBASE_MEASUREMENT_ID_WINDOWS'] ?? '';

  // iOS Bundle ID
  static String get firebaseIosBundleId => 
      dotenv.env['FIREBASE_IOS_BUNDLE_ID'] ?? '';
}
