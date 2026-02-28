import 'package:flutter/material.dart';
import 'package:fast_truck/services/auth_service.dart';
import 'package:fast_truck/screens/home_screen.dart';
import 'package:fast_truck/ui/button.dart';
import 'package:fast_truck/ui/input.dart';
import 'package:fast_truck/ui/card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _handleEmailPasswordAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _authService.signInWithEmailPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        _showSuccess('Signed in successfully!');
      } else {
        await _authService.registerWithEmailPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        _showSuccess('Account created successfully!');
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final result = await _authService.signInWithGoogle();
      if (result != null) {
        _showSuccess('Signed in with Google!');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: CardWidget(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.local_shipping_rounded,
                              size: 32,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          CardHeader(
                            title: Text(_isLogin ? 'Welcome back' : 'Create account'),
                            description: Text(
                              _isLogin
                                  ? 'Enter your credentials to sign in'
                                  : 'Enter your information to get started',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Email Input
                      Input(
                        controller: _emailController,
                        label: 'Email',
                        placeholder: 'name@example.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icon(Icons.mail_outline, size: 18, color: Colors.grey[400]),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Input
                      Input(
                        controller: _passwordController,
                        label: 'Password',
                        placeholder: '••••••••',
                        obscureText: _obscurePassword,
                        prefixIcon: Icon(Icons.lock_outline, size: 18, color: Colors.grey[400]),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18,
                            color: Colors.grey[400],
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (!_isLogin && value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      Button(
                        onPressed: _isLoading ? null : _handleEmailPasswordAuth,
                        isLoading: _isLoading,
                        size: ButtonSize.lg,
                        child: Text(_isLogin ? 'Sign in' : 'Create account'),
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR CONTINUE WITH',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Google Sign In Button
                      Button(
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        variant: ButtonVariant.outline,
                        size: ButtonSize.lg,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, size: 18, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            const Text('Google'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Toggle Sign In/Up
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isLogin ? "Don't have an account?" : 'Already have an account?',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() => _isLogin = !_isLogin);
                                _formKey.currentState?.reset();
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                _isLogin ? 'Sign up' : 'Sign in',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
