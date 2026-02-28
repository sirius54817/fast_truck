import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fast_truck/services/user_service.dart';
import 'package:fast_truck/models/user_model.dart';
import 'package:fast_truck/ui/card.dart';

class AvailableDriversPage extends StatefulWidget {
  const AvailableDriversPage({super.key});

  @override
  State<AvailableDriversPage> createState() => _AvailableDriversPageState();
}

class _AvailableDriversPageState extends State<AvailableDriversPage> {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/logo.svg',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 8),
            const Text(
              'Available Drivers',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _userService.getOnlineDriversStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading drivers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final drivers = snapshot.data ?? [];

          if (drivers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Drivers Available',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No drivers are currently online',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final driver = drivers[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _DriverCard(driver: driver),
              );
            },
          );
        },
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final UserModel driver;

  const _DriverCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver Header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  Icons.person,
                  size: 28,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            driver.driverFullName ?? 'Driver',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (driver.driverPhone != null)
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            driver.driverPhone!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Vehicle Information
          Text(
            'Vehicle Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.local_shipping_outlined,
                  label: 'Vehicle Type',
                  value: driver.vehicleType ?? 'N/A',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoItem(
                  icon: Icons.confirmation_number_outlined,
                  label: 'License Plate',
                  value: driver.vehiclePlate ?? 'N/A',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoItem(
            icon: Icons.badge_outlined,
            label: 'License Number',
            value: driver.driverLicenseNumber ?? 'N/A',
          ),
          const SizedBox(height: 16),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showContactDialog(context, driver);
              },
              icon: const Icon(Icons.send_outlined, size: 18),
              label: const Text('Send Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context, UserModel driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 12),
            const Text('Send Request'),
          ],
        ),
        content: Text(
          'Request feature coming soon! You\'ll be able to send delivery requests directly to ${driver.driverFullName ?? 'this driver'}.',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
