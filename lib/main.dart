import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fast_truck/services/auth_service.dart';
import 'package:fast_truck/pages/login_page.dart';
import 'package:fast_truck/pages/main_navigation_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fast Truck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Minimal Black and White color scheme
        primaryColor: const Color(0xFF1a1a1a), // Dark gray/black
        primaryColorLight: const Color(0xFF424242),
        primaryColorDark: const Color(0xFF000000),
        scaffoldBackgroundColor: Colors.white,
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1a1a1a),
          primary: const Color(0xFF1a1a1a),
          secondary: const Color(0xFF424242),
          surface: Colors.white,
          error: Colors.red[400]!,
          brightness: Brightness.light,
        ),
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1a1a1a),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          color: Colors.white,
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1a1a1a),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1a1a1a),
            side: const BorderSide(color: Color(0xFF1a1a1a), width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF1a1a1a),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[400]!),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[400]!, width: 2),
          ),
        ),
        
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1a1a1a),
          foregroundColor: Colors.white,
        ),
        
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF6B35),
              ),
            ),
          );
        }

        // If user is logged in, show home screen
        if (snapshot.hasData) {
          return const MainNavigationPage();
        }

        // Otherwise show login screen
        return const LoginPage();
      },
    );
  }
}
