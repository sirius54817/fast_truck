import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fast_truck/services/auth_service.dart';
import 'package:fast_truck/services/delivery_request_service.dart';
import 'package:fast_truck/ui/input.dart';
import 'package:fast_truck/ui/button.dart';
import 'package:fast_truck/config/app_config.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewRequestPage extends StatefulWidget {
  const NewRequestPage({super.key});

  @override
  State<NewRequestPage> createState() => _NewRequestPageState();
}

class _NewRequestPageState extends State<NewRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _deliveryRequestService = DeliveryRequestService();
  
  final _loadTypeController = TextEditingController();
  final _weightController = TextEditingController();
  final _pickupLocationController = TextEditingController();
  final _dropLocationController = TextEditingController();
  final _distanceController = TextEditingController();
  
  final _pickupFocusNode = FocusNode();
  final _dropFocusNode = FocusNode();
  
  bool _isSubmitting = false;
  bool _isCalculatingDistance = false;
  String? _pickupPlaceId;
  String? _dropPlaceId;
  double? _pickupLatitude;
  double? _pickupLongitude;
  double? _dropLatitude;
  double? _dropLongitude;

  @override
  void dispose() {
    _loadTypeController.dispose();
    _weightController.dispose();
    _pickupLocationController.dispose();
    _dropLocationController.dispose();
    _distanceController.dispose();
    _pickupFocusNode.dispose();
    _dropFocusNode.dispose();
    super.dispose();
  }

  Future<void> _calculateDistance() async {
    if (_pickupPlaceId == null || _dropPlaceId == null) {
      return;
    }

    setState(() => _isCalculatingDistance = true);

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=place_id:$_pickupPlaceId'
        '&destinations=place_id:$_dropPlaceId'
        '&key=${AppConfig.googleMapsApiKey}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && 
            data['rows'] != null && 
            data['rows'].isNotEmpty &&
            data['rows'][0]['elements'] != null &&
            data['rows'][0]['elements'].isNotEmpty) {
          
          final element = data['rows'][0]['elements'][0];
          
          if (element['status'] == 'OK' && element['distance'] != null) {
            final distanceInMeters = element['distance']['value'];
            final distanceInKm = (distanceInMeters / 1000).toStringAsFixed(2);
            
            setState(() {
              _distanceController.text = distanceInKm;
              _isCalculatingDistance = false;
            });
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Distance calculated: $distanceInKm km'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
            return;
          }
        }
      }
      
      throw 'Failed to calculate distance';
    } catch (e) {
      setState(() => _isCalculatingDistance = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to calculate distance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authService = AuthService();
      final user = authService.currentUser;

      if (user == null) {
        throw 'User not authenticated';
      }

      await _deliveryRequestService.createRequest(
        agentId: user.uid,
        agentEmail: user.email ?? '',
        loadType: _loadTypeController.text.trim(),
        weight: double.parse(_weightController.text.trim()),
        pickupLocation: _pickupLocationController.text.trim(),
        pickupLatitude: _pickupLatitude,
        pickupLongitude: _pickupLongitude,
        dropLocation: _dropLocationController.text.trim(),
        dropLatitude: _dropLatitude,
        dropLongitude: _dropLongitude,
        distance: double.parse(_distanceController.text.trim()),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery request created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
              'New Delivery Request',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Request Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in the details for your delivery request',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Load Type
              Input(
                controller: _loadTypeController,
                label: 'Load Type',
                placeholder: 'e.g., Electronics, Furniture, Food',
                prefixIcon: const Icon(Icons.inventory_2_outlined),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the load type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Weight
              Input(
                controller: _weightController,
                label: 'Weight (kg)',
                placeholder: 'Enter weight in kilograms',
                prefixIcon: const Icon(Icons.scale_outlined),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the weight';
                  }
                  final weight = double.tryParse(value.trim());
                  if (weight == null || weight <= 0) {
                    return 'Please enter a valid weight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Pickup Location
              Text(
                'Pickup Location',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              GooglePlaceAutoCompleteTextField(
                textEditingController: _pickupLocationController,
                googleAPIKey: AppConfig.googleMapsApiKey,
                focusNode: _pickupFocusNode,
                textInputAction: TextInputAction.next,
                inputDecoration: InputDecoration(
                  hintText: 'Enter pickup address',
                  prefixIcon: const Icon(Icons.location_on_outlined),
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
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                debounceTime: 800,
                countries: const ["in"],
                isLatLngRequired: true,
                getPlaceDetailWithLatLng: (Prediction prediction) {
                  setState(() {
                    _pickupPlaceId = prediction.placeId;
                    _pickupLatitude = double.tryParse(prediction.lat ?? '');
                    _pickupLongitude = double.tryParse(prediction.lng ?? '');
                  });
                  if (_dropPlaceId != null) {
                    _calculateDistance();
                  }
                },
                itemClick: (Prediction prediction) {
                  _pickupLocationController.text = prediction.description ?? "";
                  _pickupLocationController.selection = TextSelection.fromPosition(
                    TextPosition(offset: prediction.description?.length ?? 0),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Drop Location
              Text(
                'Drop Location',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              GooglePlaceAutoCompleteTextField(
                textEditingController: _dropLocationController,
                googleAPIKey: AppConfig.googleMapsApiKey,
                focusNode: _dropFocusNode,
                textInputAction: TextInputAction.done,
                inputDecoration: InputDecoration(
                  hintText: 'Enter drop-off address',
                  prefixIcon: const Icon(Icons.location_searching_outlined),
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
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                debounceTime: 800,
                countries: const ["in"],
                isLatLngRequired: true,
                getPlaceDetailWithLatLng: (Prediction prediction) {
                  setState(() {
                    _dropPlaceId = prediction.placeId;
                    _dropLatitude = double.tryParse(prediction.lat ?? '');
                    _dropLongitude = double.tryParse(prediction.lng ?? '');
                  });
                  if (_pickupPlaceId != null) {
                    _calculateDistance();
                  }
                },
                itemClick: (Prediction prediction) {
                  _dropLocationController.text = prediction.description ?? "";
                  _dropLocationController.selection = TextSelection.fromPosition(
                    TextPosition(offset: prediction.description?.length ?? 0),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Distance
              Input(
                controller: _distanceController,
                label: 'Distance (km)',
                placeholder: _isCalculatingDistance ? 'Calculating...' : 'Auto-calculated from locations',
                prefixIcon: _isCalculatingDistance 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.straighten_outlined),
                keyboardType: TextInputType.number,
                enabled: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select pickup and drop locations';
                  }
                  final distance = double.tryParse(value.trim());
                  if (distance == null || distance <= 0) {
                    return 'Please wait for distance calculation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: Button(
                  onPressed: (_isSubmitting || _isCalculatingDistance || _distanceController.text.isEmpty) 
                    ? null 
                    : _submitRequest,
                  variant: ButtonVariant.primary,
                  size: ButtonSize.lg,
                  icon: const Icon(Icons.send_outlined, size: 18),
                  child: Text(
                    _isSubmitting 
                      ? 'Creating Request...' 
                      : _isCalculatingDistance 
                        ? 'Calculating Distance...'
                        : _distanceController.text.isEmpty
                          ? 'Select Locations First'
                          : 'Create Request'
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
