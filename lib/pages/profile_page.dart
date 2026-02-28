import 'package:flutter/material.dart';
import 'package:fast_truck/services/auth_service.dart';
import 'package:fast_truck/services/user_service.dart';
import 'package:fast_truck/pages/login_page.dart';
import 'package:fast_truck/pages/driver_verification_page.dart';
import 'package:fast_truck/pages/agent_verification_page.dart';
import 'package:fast_truck/ui/card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  bool _isDriverVerified = false;
  bool _isAgentVerified = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  Future<void> _loadVerificationStatus() async {
    final authService = AuthService();
    final userId = authService.currentUser?.uid;
    
    if (userId != null) {
      final isDriverVerified = await _userService.isDriverVerified(userId);
      final isAgentVerified = await _userService.isAgentVerified(userId);
      if (mounted) {
        setState(() {
          _isDriverVerified = isDriverVerified;
          _isAgentVerified = isAgentVerified;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToDriverVerification() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DriverVerificationPage(),
      ),
    );

    // Reload verification status if returned from verification page
    if (result == true && mounted) {
      _loadVerificationStatus();
    }
  }

  Future<void> _navigateToAgentVerification() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AgentVerificationPage(),
      ),
    );

    // Reload verification status if returned from verification page
    if (result == true && mounted) {
      _loadVerificationStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C2C2C), // Dark gray
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // User Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.person,
                size: 50,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // User Email
            Text(
              user?.displayName ?? 'User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? 'No email',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Profile Options
            CardWidget(
              child: Column(
                children: [
                  _ProfileOption(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () {
                      // TODO: Implement edit profile
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon!')),
                      );
                    },
                  ),
                  Divider(color: Colors.grey[200], height: 1),
                  _ProfileOption(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      // TODO: Implement notifications
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon!')),
                      );
                    },
                  ),
                  Divider(color: Colors.grey[200], height: 1),
                  _ProfileOption(
                    icon: _isAgentVerified 
                        ? Icons.business_center 
                        : Icons.business_center_outlined,
                    title: _isAgentVerified 
                        ? 'Agent Verified' 
                        : 'Verify Agent Profile',
                    iconColor: _isAgentVerified 
                        ? Colors.blue[600] 
                        : null,
                    textColor: _isAgentVerified 
                        ? Colors.blue[600] 
                        : null,
                    trailing: _isAgentVerified 
                        ? Icon(Icons.check_circle, color: Colors.blue[600], size: 20)
                        : null,
                    onTap: _isAgentVerified 
                        ? null 
                        : _navigateToAgentVerification,
                  ),
                  Divider(color: Colors.grey[200], height: 1),
                  _ProfileOption(
                    icon: _isDriverVerified 
                        ? Icons.local_shipping 
                        : Icons.local_shipping_outlined,
                    title: _isDriverVerified 
                        ? 'Driver Verified' 
                        : 'Verify Driver Profile',
                    iconColor: _isDriverVerified 
                        ? Colors.green[600] 
                        : null,
                    textColor: _isDriverVerified 
                        ? Colors.green[600] 
                        : null,
                    trailing: _isDriverVerified 
                        ? Icon(Icons.check_circle, color: Colors.green[600], size: 20)
                        : null,
                    onTap: _isDriverVerified 
                        ? null 
                        : _navigateToDriverVerification,
                  ),
                  Divider(color: Colors.grey[200], height: 1),
                  _ProfileOption(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      // TODO: Implement settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon!')),
                      );
                    },
                  ),
                  Divider(color: Colors.grey[200], height: 1),
                  _ProfileOption(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      // TODO: Implement help
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sign Out Button
            CardWidget(
              child: _ProfileOption(
                icon: Icons.logout,
                title: 'Sign Out',
                iconColor: Colors.red[400],
                textColor: Colors.red[400],
                onTap: () async {
                  try {
                    await authService.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;
  final Widget? trailing;

  const _ProfileOption({
    required this.icon,
    required this.title,
    this.onTap,
    this.iconColor,
    this.textColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.6 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? Colors.grey[700],
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor ?? Colors.grey[900],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              trailing ?? Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
