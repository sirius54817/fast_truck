import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fast_truck/services/auth_service.dart';
import 'package:fast_truck/services/delivery_request_service.dart';
import 'package:fast_truck/models/delivery_request_model.dart';
import 'package:fast_truck/ui/card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deliveryRequestService = DeliveryRequestService();
    final authService = AuthService();
    final userId = authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/logo.svg',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'History',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: userId == null
          ? const Center(child: Text('Please login to view history'))
          : StreamBuilder<List<DeliveryRequestModel>>(
              stream: deliveryRequestService.getHistoryRequestsStream(userId),
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
                          'Error loading history',
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

                final historyRequests = snapshot.data ?? [];

                if (historyRequests.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Empty State Icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Icon(
                              Icons.receipt_long_outlined,
                              size: 40,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No Delivery History',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your completed and cancelled deliveries will appear here',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: historyRequests.length,
                  itemBuilder: (context, index) {
                    final request = historyRequests[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _HistoryRequestCard(request: request),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _HistoryRequestCard extends StatelessWidget {
  final DeliveryRequestModel request;

  const _HistoryRequestCard({required this.request});

  Color _getStatusColor() {
    switch (request.status) {
      case 'completed':
        return Colors.green[700]!;
      case 'cancelled':
        return Colors.red[700]!;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (request.status) {
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusLabel() {
    switch (request.status) {
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return request.status;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getStatusIcon(),
                  size: 20,
                  color: _getStatusColor(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.loadType,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatDate(request.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor().withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getStatusLabel(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Details
          _DetailRow(
            icon: Icons.scale_outlined,
            label: 'Weight',
            value: '${request.weight} kg',
          ),
          const SizedBox(height: 8),
          _DetailRow(
            icon: Icons.location_on_outlined,
            label: 'Pickup',
            value: request.pickupLocation,
          ),
          const SizedBox(height: 8),
          _DetailRow(
            icon: Icons.location_searching_outlined,
            label: 'Drop',
            value: request.dropLocation,
          ),
          const SizedBox(height: 8),
          _DetailRow(
            icon: Icons.straighten_outlined,
            label: 'Distance',
            value: '${request.distance} km',
          ),
          if (request.driverName != null) ...[
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.person_outline,
              label: 'Driver',
              value: request.driverName!,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
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
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}
