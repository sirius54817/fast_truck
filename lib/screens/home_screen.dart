import 'package:flutter/material.dart';
import 'package:fast_truck/services/auth_service.dart';
import 'package:fast_truck/screens/login_screen.dart';
import 'package:fast_truck/ui/button.dart';
import 'package:fast_truck/ui/card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Fast Truck',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await authService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // User Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 24),

                // Welcome Text
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? 'User',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),

                // Coming Soon Card
                CardWidget(
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
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
                        title: const Text('Coming Soon'),
                        description: const Text(
                          'Agent and Driver features will be available here. Toggle between roles to manage requests and deliveries.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Feature List
                      Column(
                        children: [
                          _FeatureItem(
                            icon: Icons.person_outline,
                            title: 'Agent Mode',
                            description: 'Request truckers and manage deliveries',
                          ),
                          const SizedBox(height: 12),
                          _FeatureItem(
                            icon: Icons.local_shipping_outlined,
                            title: 'Driver Mode',
                            description: 'Accept requests and deliver packages',
                          ),
                          const SizedBox(height: 12),
                          _FeatureItem(
                            icon: Icons.swap_horiz,
                            title: 'Easy Toggle',
                            description: 'Switch between modes seamlessly',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
