import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fast_truck/models/delivery_request_model.dart';
import 'package:fast_truck/services/delivery_request_service.dart';
import 'package:fast_truck/services/auth_service.dart';
import 'package:fast_truck/services/user_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestDetailsPage extends StatefulWidget {
  final DeliveryRequestModel request;

  const RequestDetailsPage({
    super.key,
    required this.request,
  });

  @override
  State<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {
  final _deliveryRequestService = DeliveryRequestService();
  bool _isProcessing = false;

  Future<void> _acceptRequest() async {
    setState(() => _isProcessing = true);

    try {
      final authService = AuthService();
      final userService = UserService();
      final user = authService.currentUser;

      if (user == null) {
        throw 'User not authenticated';
      }

      // Check if driver is verified
      final isDriverVerified = await userService.isDriverVerified(user.uid);
      if (!isDriverVerified) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Driver verification required. Please complete verification first.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        setState(() => _isProcessing = false);
        return;
      }

      // Get driver name
      final userData = await userService.getUserData(user.uid);
      final driverName = userData?.driverFullName ?? userData?.displayName ?? user.email ?? 'Unknown';

      await _deliveryRequestService.assignDriver(
        widget.request.id,
        user.uid,
        driverName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return to previous page
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    
    try {
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to open dialer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchMapsNavigation() async {
    try {
      // Check if coordinates are available
      if (widget.request.pickupLatitude == null || widget.request.pickupLongitude == null ||
          widget.request.dropLatitude == null || widget.request.dropLongitude == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location coordinates not available'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      bool launched = false;

      // Try 1: Google Maps app URL scheme (most reliable for Android)
      try {
        final String googleMapsAppUrl = 
            'google.navigation:q=${widget.request.dropLatitude},${widget.request.dropLongitude}'
            '&waypoints=${widget.request.pickupLatitude},${widget.request.pickupLongitude}';
        final Uri appUri = Uri.parse(googleMapsAppUrl);
        launched = await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        launched = false;
      }

      // Try 2: Universal Google Maps URL (works on all platforms)
      if (!launched) {
        try {
          final String googleMapsWebUrl = 
              'https://www.google.com/maps/dir/?api=1'
              '&origin=${widget.request.pickupLatitude},${widget.request.pickupLongitude}'
              '&destination=${widget.request.dropLatitude},${widget.request.dropLongitude}'
              '&travelmode=driving';
          final Uri webUri = Uri.parse(googleMapsWebUrl);
          launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
        } catch (e) {
          launched = false;
        }
      }

      // Try 3: Generic geo URI (fallback for any map app)
      if (!launched) {
        try {
          final String geoUrl = 'geo:${widget.request.pickupLatitude},${widget.request.pickupLongitude}'
              '?q=${widget.request.dropLatitude},${widget.request.dropLongitude}';
          final Uri geoUri = Uri.parse(geoUrl);
          launched = await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        } catch (e) {
          launched = false;
        }
      }

      // If all attempts failed, show error
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No map application found. Please install Google Maps.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to open maps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
              'Request Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C2C2C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(widget.request.status),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.request.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Load Information Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Load Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.inventory_2_outlined, 'Load Type', widget.request.loadType),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.scale_outlined, 'Weight', '${widget.request.weight} kg'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.straighten_outlined, 'Distance', '${widget.request.distance} km'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Locations Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Locations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLocationRow(
                      Icons.location_on,
                      'Pickup',
                      widget.request.pickupLocation,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildLocationRow(
                      Icons.location_searching,
                      'Drop-off',
                      widget.request.dropLocation,
                      Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Agent Information Card
            if (widget.request.agentName != null || widget.request.agencyName != null)
              Card(
                color: Colors.blue[50],
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.business, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Agent Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (widget.request.agentName != null) ...[
                        Row(
                          children: [
                            Text(
                              'Agent: ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.request.agentName!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (widget.request.agentPhone != null) ...[
                        Row(
                          children: [
                            Text(
                              'Phone: ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.request.agentPhone!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (widget.request.agencyName != null) ...[
                        Row(
                          children: [
                            Text(
                              'Agency: ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.request.agencyName!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (widget.request.agencyContact != null) ...[
                        Row(
                          children: [
                            Text(
                              'Agency Contact: ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.request.agencyContact!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Action Buttons
            if (widget.request.agentPhone != null || 
                (widget.request.pickupLatitude != null && widget.request.pickupLongitude != null))
              Column(
                children: [
                  Row(
                    children: [
                      // Call Button
                      if (widget.request.agentPhone != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _makePhoneCall(widget.request.agentPhone!),
                            icon: const Icon(Icons.phone, size: 20),
                            label: const Text('Call Agent'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      if (widget.request.agentPhone != null && 
                          widget.request.pickupLatitude != null && 
                          widget.request.pickupLongitude != null)
                        const SizedBox(width: 12),
                      // Navigate Button
                      if (widget.request.pickupLatitude != null && 
                          widget.request.pickupLongitude != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _launchMapsNavigation,
                            icon: const Icon(Icons.navigation, size: 20),
                            label: const Text('Navigate'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),

            // Accept Request Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _acceptRequest,
                icon: _isProcessing 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check_circle_outline, size: 20),
                label: Text(_isProcessing ? 'Processing...' : 'Accept Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[900],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow(IconData icon, String label, String location, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                location,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
