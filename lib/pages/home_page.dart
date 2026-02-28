import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fast_truck/services/auth_service.dart';
import 'package:fast_truck/services/user_service.dart';
import 'package:fast_truck/services/delivery_request_service.dart';
import 'package:fast_truck/models/delivery_request_model.dart';
import 'package:fast_truck/pages/driver_verification_page.dart';
import 'package:fast_truck/pages/agent_verification_page.dart';
import 'package:fast_truck/pages/available_drivers_page.dart';
import 'package:fast_truck/pages/new_request_page.dart';
import 'package:fast_truck/pages/request_details_page.dart';
import 'package:fast_truck/pages/agent_request_details_page.dart';
import 'package:fast_truck/ui/card.dart';
import 'package:fast_truck/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

enum UserMode { agent, driver }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserMode _currentMode = UserMode.agent;
  final UserService _userService = UserService();
  final DeliveryRequestService _deliveryRequestService = DeliveryRequestService();
  final TextEditingController _pincodeSearchController = TextEditingController();
  bool _isDriverVerified = false;
  bool _isAgentVerified = false;
  bool _isDriverOnline = false;
  bool _isRefreshing = false;
  String? _searchPincode;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
    _loadOnlineStatus();
    _loadDriverPincode();
  }

  @override
  void dispose() {
    _pincodeSearchController.dispose();
    super.dispose();
  }

  // Load both driver and agent verification status from database
  Future<void> _loadVerificationStatus() async {
    final authService = AuthService();
    final userId = authService.currentUser?.uid;
    
    if (userId != null) {
      final isDriverVerified = await _userService.isDriverVerified(userId);
      final isAgentVerified = await _userService.isAgentVerified(userId);
      setState(() {
        _isDriverVerified = isDriverVerified;
        _isAgentVerified = isAgentVerified;
      });
    }
  }

  // Refresh all verification statuses from database
  Future<void> _refreshVerificationStatus() async {
    setState(() => _isRefreshing = true);
    
    try {
      await _loadVerificationStatus();
      await _loadOnlineStatus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status refreshed successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  // Load driver online status
  Future<void> _loadOnlineStatus() async {
    final authService = AuthService();
    final userId = authService.currentUser?.uid;
    
    if (userId != null) {
      final isOnline = await _userService.getDriverOnlineStatus(userId);
      setState(() {
        _isDriverOnline = isOnline;
      });
    }
  }

  // Load driver's saved pincode
  Future<void> _loadDriverPincode() async {
    final authService = AuthService();
    final userId = authService.currentUser?.uid;
    
    if (userId != null) {
      final pincode = await _userService.getDriverCurrentPincode(userId);
      if (pincode != null && mounted) {
        setState(() {
          _searchPincode = pincode;
          _pincodeSearchController.text = pincode;
        });
      }
    }
  }

  // Fetch pincode from coordinates using Google Geocoding API
  Future<String?> _fetchPincodeFromCoordinates(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=$latitude,$longitude'
        '&key=${AppConfig.googleMapsApiKey}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
          final results = data['results'] as List;
          
          for (var result in results) {
            final addressComponents = result['address_components'] as List?;
            
            if (addressComponents != null) {
              for (var component in addressComponents) {
                final types = component['types'] as List?;
                if (types != null && types.contains('postal_code')) {
                  return component['long_name'] as String?;
                }
              }
            }
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Failed to fetch pincode from coordinates: $e');
      return null;
    }
  }

  // Get current location and extract pincode
  Future<void> _getCurrentLocationPincode() async {
    setState(() => _isFetchingLocation = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled. Please enable them in settings.';
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permission denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied. Please enable them in app settings.';
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Fetch pincode from coordinates
      final pincode = await _fetchPincodeFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (pincode != null) {
        setState(() {
          _searchPincode = pincode;
          _pincodeSearchController.text = pincode;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location detected: Pincode $pincode'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw 'Unable to fetch pincode from your location';
      }
    } catch (e) {
      debugPrint('Failed to get location pincode: $e');
      
      if (mounted) {
        // Show error and prompt for manual entry
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Fall back to manual pincode entry
        await _showPincodeDialog();
      }
    } finally {
      setState(() => _isFetchingLocation = false);
    }
  }

  // Update driver online status
  Future<void> _updateOnlineStatus(bool isOnline) async {
    final authService = AuthService();
    final userId = authService.currentUser?.uid;
    
    if (userId != null) {
      try {
        if (isOnline) {
          // When going online, fetch pincode automatically from location
          if (_searchPincode == null || _searchPincode!.isEmpty) {
            await _getCurrentLocationPincode();
            if (_searchPincode == null || _searchPincode!.isEmpty) {
              // User cancelled or location fetch failed without manual entry
              return;
            }
          }
          
          // Save pincode to database
          if (_searchPincode != null) {
            await _userService.updateDriverCurrentPincode(userId, _searchPincode!);
          }
        }
        
        await _userService.updateDriverOnlineStatus(userId, isOnline);
        setState(() {
          _isDriverOnline = isOnline;
        });
      } catch (e) {
        // Handle error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update status: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Show dialog to enter pincode
  Future<void> _showPincodeDialog() async {
    final controller = TextEditingController(text: _searchPincode);
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter Your Area Pincode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the pincode of your current location to find nearby delivery requests.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Pincode',
                hintText: 'e.g., 110001',
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final pincode = controller.text.trim();
              if (pincode.length == 6) {
                setState(() {
                  _searchPincode = pincode;
                  _pincodeSearchController.text = pincode;
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid 6-digit pincode'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // Handle mode switching with verification check
  Future<void> _handleModeSwitch(UserMode newMode) async {
    if (newMode == UserMode.driver) {
      // Check if driver is verified
      final authService = AuthService();
      final userId = authService.currentUser?.uid;
      
      if (userId != null) {
        final isVerified = await _userService.isDriverVerified(userId);
        
        if (!isVerified) {
          // Show verification required dialog
          _showVerificationRequiredDialog();
          return;
        }
      }
    }
    
    // Switch mode if verified or switching to agent
    setState(() => _currentMode = newMode);
  }

  // Show dialog when driver verification is required
  void _showVerificationRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(
              Icons.verified_user_outlined,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 12),
            const Text('Driver Verification Required'),
          ],
        ),
        content: const Text(
          'Please verify your driver profile before switching to driver mode. '
          'Contact support or complete the driver verification process to get started.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Navigate to driver verification page
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DriverVerificationPage(),
                ),
              );
              
              // If verification was successful, try switching to driver mode
              if (result == true && mounted) {
                await _loadVerificationStatus();
                setState(() => _currentMode = UserMode.driver);
              }
            },
            child: const Text('Verify Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Fast Truck',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C2C2C), // Dark gray
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Refresh Button
          IconButton(
            icon: _isRefreshing 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshVerificationStatus,
            tooltip: 'Refresh verification status',
          ),
          const SizedBox(width: 4),
          // Mode Toggle
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ModeToggleButton(
                  icon: Icons.person_outline,
                  label: 'Agent',
                  isSelected: _currentMode == UserMode.agent,
                  onTap: () => _handleModeSwitch(UserMode.agent),
                  showVerificationDot: true,
                  isVerified: _isAgentVerified,
                ),
                const SizedBox(width: 4),
                _ModeToggleButton(
                  icon: Icons.local_shipping_outlined,
                  label: 'Driver',
                  isSelected: _currentMode == UserMode.driver,
                  onTap: () => _handleModeSwitch(UserMode.driver),
                  showVerificationDot: true,
                  isVerified: _isDriverVerified,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    _currentMode == UserMode.agent ? Icons.person : Icons.local_shipping,
                    size: 24,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      Text(
                        user?.email ?? 'User',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Current Mode Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _currentMode == UserMode.agent ? Icons.person : Icons.local_shipping,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_currentMode == UserMode.agent ? 'Agent' : 'Driver'} Mode',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Mode-specific content
            if (_currentMode == UserMode.agent) _buildAgentView() else _buildDriverView(),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Actions
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_circle_outline,
                title: 'New Request',
                subtitle: 'Request a trucker',
                color: Theme.of(context).primaryColor,
                onTap: () async {
                  // Check agent verification status (already loaded from database)
                  if (!_isAgentVerified) {
                    if (!mounted) return;
                    // Show verification required dialog
                    final shouldVerify = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        title: const Row(
                          children: [
                            Icon(Icons.verified_user, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Verification Required'),
                          ],
                        ),
                        content: const Text(
                          'You need to complete agent verification before creating delivery requests. Would you like to verify now?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Verify Now'),
                          ),
                        ],
                      ),
                    );
                    
                    if (shouldVerify == true && mounted) {
                      // Navigate to verification page
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AgentVerificationPage(),
                        ),
                      );
                      // Reload verification status after returning
                      if (result == true && mounted) {
                        await _loadVerificationStatus();
                      }
                    }
                    return; // Don't navigate to NewRequestPage
                  }
                  
                  // Agent is verified, proceed to new request page
                  if (!mounted) return;
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewRequestPage(),
                    ),
                  );
                  if (result == true && mounted) {
                    setState(() {}); // Refresh to show new request
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.search,
                title: 'Find Drivers',
                subtitle: 'Browse available',
                color: Colors.blue[600]!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AvailableDriversPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Active Requests
        StreamBuilder<List<DeliveryRequestModel>>(
          stream: _deliveryRequestService.getActiveRequestsStream(
            AuthService().currentUser?.uid ?? '',
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CardWidget(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CardHeader(
                      title: const Text('Active Requests'),
                      description: const Text('Your current delivery requests'),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
              );
            }

            final requests = snapshot.data ?? [];

            if (requests.isEmpty) {
              return CardWidget(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CardHeader(
                      title: const Text('Active Requests'),
                      description: const Text('Your current delivery requests'),
                    ),
                    const SizedBox(height: 16),
                    _EmptyState(
                      icon: Icons.inbox_outlined,
                      message: 'No active requests',
                      description: 'Create a new request to get started',
                    ),
                  ],
                ),
              );
            }

            return CardWidget(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardHeader(
                    title: const Text('Active Requests'),
                    description: Text('${requests.length} active request${requests.length > 1 ? 's' : ''}'),
                  ),
                  const SizedBox(height: 16),
                  ...requests.map((request) => _RequestCard(request: request)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Agent Features Info
        CardWidget(
          child: Column(
            children: [
              _FeatureItem(
                icon: Icons.request_quote_outlined,
                title: 'Request Deliveries',
                description: 'Post delivery requests and connect with drivers',
              ),
              const SizedBox(height: 12),
              _FeatureItem(
                icon: Icons.track_changes_outlined,
                title: 'Track Shipments',
                description: 'Monitor your deliveries in real-time',
              ),
              const SizedBox(height: 12),
              _FeatureItem(
                icon: Icons.receipt_outlined,
                title: 'Manage Payments',
                description: 'Handle transactions securely',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Driver Status
        CardWidget(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _isDriverOnline ? Colors.green[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _isDriverOnline ? Icons.check_circle_outline : Icons.cancel_outlined,
                  color: _isDriverOnline ? Colors.green[700] : Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isDriverOnline ? 'You\'re Online' : 'You\'re Offline',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    Text(
                      _isDriverOnline ? 'Ready to accept requests' : 'Not accepting requests',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isDriverOnline,
                onChanged: (value) async {
                  await _updateOnlineStatus(value);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value ? 'You are now online' : 'You are now offline',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                activeColor: Colors.green[700],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Active Request (if driver has one)
        StreamBuilder<DeliveryRequestModel?>(
          stream: _deliveryRequestService.getDriverActiveRequestStream(
            AuthService().currentUser?.uid ?? '',
          ),
          builder: (context, activeSnapshot) {
            final activeRequest = activeSnapshot.data;
            
            // Show active request section if there is one
            if (activeRequest != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Request',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ActiveRequestCard(request: activeRequest),
                  const SizedBox(height: 24),
                ],
              );
            }
            
            // If no active request, show available requests
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Requests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Pincode Search Field
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.search, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Search by Area Pincode',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _pincodeSearchController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              decoration: InputDecoration(
                                hintText: 'Enter pincode (e.g., 110001)',
                                prefixIcon: const Icon(Icons.location_city),
                                suffixIcon: _pincodeSearchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _pincodeSearchController.clear();
                                            _searchPincode = null;
                                          });
                                        },
                                      )
                                    : null,
                                counterText: '',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              onChanged: (value) {
                                // Only search when 6 digits are entered
                                if (value.length == 6) {
                                  setState(() {
                                    _searchPincode = value;
                                  });
                                } else if (_searchPincode != null) {
                                  setState(() {
                                    _searchPincode = null;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              final pincode = _pincodeSearchController.text.trim();
                              if (pincode.length == 6) {
                                setState(() {
                                  _searchPincode = pincode;
                                });
                                // Save pincode to database
                                final authService = AuthService();
                                final userId = authService.currentUser?.uid;
                                if (userId != null) {
                                  _userService.updateDriverCurrentPincode(userId, pincode);
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a valid 6-digit pincode'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.search, size: 20),
                            label: const Text('Search'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Show requests only if pincode is entered
                if (_searchPincode == null || _searchPincode!.isEmpty)
                  CardWidget(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Enter Pincode to Search',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your area pincode above to find available delivery requests nearby',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  StreamBuilder<List<DeliveryRequestModel>>(
                    stream: _deliveryRequestService.getPendingRequestsByPincodeStream(_searchPincode!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CardWidget(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return CardWidget(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red[300],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Error loading requests',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final pendingRequests = snapshot.data ?? [];

                      if (pendingRequests.isEmpty) {
                        return CardWidget(
                          child: _EmptyState(
                            icon: Icons.local_shipping_outlined,
                            message: 'No requests in pincode $_searchPincode',
                            description: 'Try searching with a different pincode',
                          ),
                        );
                      }

                      return Column(
                        children: pendingRequests.map((request) => 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _DriverRequestCard(request: request),
                          )
                        ).toList(),
                      );
                    },
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        // Driver Features Info
        CardWidget(
          child: Column(
            children: [
              _FeatureItem(
                icon: Icons.notifications_active_outlined,
                title: 'Get Notified',
                description: 'Receive instant alerts for new delivery requests',
              ),
              const SizedBox(height: 12),
              _FeatureItem(
                icon: Icons.route_outlined,
                title: 'Optimized Routes',
                description: 'Get the best routes for your deliveries',
              ),
              const SizedBox(height: 12),
              _FeatureItem(
                icon: Icons.payments_outlined,
                title: 'Earn Money',
                description: 'Get paid securely for completed deliveries',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModeToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showVerificationDot;
  final bool isVerified;

  const _ModeToggleButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showVerificationDot = false,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? Theme.of(context).primaryColor 
                  : Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.white.withValues(alpha: 0.9),
              ),
            ),
            if (showVerificationDot) ...[
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isVerified ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
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
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).primaryColor,
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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String description;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final DeliveryRequestModel request;

  const _RequestCard({required this.request});

  Color _getStatusColor() {
    switch (request.status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'in_progress':
        return Colors.green;
      case 'completed':
        return Colors.green[700]!;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel() {
    switch (request.status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return request.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: request.status != 'pending' && request.status != 'cancelled'
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AgentRequestDetailsPage(request: request),
                ),
              );
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 20,
                        color: _getStatusColor(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request.loadType,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                          overflow: TextOverflow.ellipsis,
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
            if (request.verificationCode != null && request.status != 'pending') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, size: 20, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Verification Code:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      request.verificationCode!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                        letterSpacing: 4,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                  ],
                ),
              ),
            ],
            if (request.status != 'pending' && request.status != 'cancelled' && 
                (request.verificationCode == null || request.status == 'pending')) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.touch_app, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'Tap for details',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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

class _DriverRequestCard extends StatelessWidget {
  final DeliveryRequestModel request;

  const _DriverRequestCard({required this.request});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestDetailsPage(request: request),
          ),
        );
      },
      child: CardWidget(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 20,
                    color: Colors.orange[700],
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
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Details Row
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.scale_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${request.weight} kg',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.straighten_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${request.distance} km',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Locations Preview
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    request.pickupLocation,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Pincode display if available
            if (request.pickupPincode != null)
              Padding(
                padding: const EdgeInsets.only(left: 22),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_city,
                      size: 14,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pincode: ${request.pickupPincode}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            if (request.pickupPincode != null)
              const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.red[600],
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    request.dropLocation,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // View Details Hint
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tap to view details',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.touch_app,
                    size: 14,
                    color: Colors.grey[700],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Active Request Card Widget
class _ActiveRequestCard extends StatelessWidget {
  final DeliveryRequestModel request;

  const _ActiveRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestDetailsPage(request: request),
          ),
        );
      },
      child: CardWidget(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green[300]!,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green[700],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ACTIVE REQUEST',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Load Type and Weight
            Row(
              children: [
                Icon(Icons.inventory_2, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${request.loadType} • ${request.weight.toStringAsFixed(0)} kg',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Distance
            Row(
              children: [
                Icon(Icons.route, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${request.distance.toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Locations Preview
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    request.pickupLocation,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Pincode display if available
            if (request.pickupPincode != null)
              Padding(
                padding: const EdgeInsets.only(left: 22),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_city,
                      size: 14,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pincode: ${request.pickupPincode}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            if (request.pickupPincode != null)
              const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.red[600],
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    request.dropLocation,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // View Details Hint
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tap to view details',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.touch_app,
                    size: 14,
                    color: Colors.green[700],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
