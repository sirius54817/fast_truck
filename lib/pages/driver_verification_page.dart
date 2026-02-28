import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fast_truck/services/auth_service.dart';
import 'package:fast_truck/services/user_service.dart';
import 'package:fast_truck/services/storage_service.dart';
import 'package:fast_truck/ui/card.dart';
import 'package:fast_truck/ui/input.dart';
import 'package:fast_truck/ui/button.dart';
import 'package:image_picker/image_picker.dart';

class DriverVerificationPage extends StatefulWidget {
  const DriverVerificationPage({super.key});

  @override
  State<DriverVerificationPage> createState() => _DriverVerificationPageState();
}

class _DriverVerificationPageState extends State<DriverVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _phoneController = TextEditingController();
  
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();
  
  bool _isSubmitting = false;
  bool _agreedToTerms = false;
  
  XFile? _licensePlateImage;
  XFile? _vehicleImage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _licenseNumberController.dispose();
    _vehicleTypeController.dispose();
    _vehiclePlateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Show image source selection dialog
  Future<void> _showImageSourceDialog(bool isLicensePlate) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLicensePlate ? 'License Plate Photo' : 'Vehicle Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isLicensePlate);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isLicensePlate);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pick image
  Future<void> _pickImage(ImageSource source, bool isLicensePlate) async {
    try {
      final XFile? image = source == ImageSource.camera
          ? await _storageService.pickImageFromCamera()
          : await _storageService.pickImageFromGallery();

      if (image != null) {
        setState(() {
          if (isLicensePlate) {
            _licensePlateImage = image;
          } else {
            _vehicleImage = image;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Remove image
  void _removeImage(bool isLicensePlate) {
    setState(() {
      if (isLicensePlate) {
        _licensePlateImage = null;
      } else {
        _vehicleImage = null;
      }
    });
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_licensePlateImage == null || _vehicleImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload both license plate and vehicle photos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authService = AuthService();
      final userId = authService.currentUser?.uid;

      if (userId != null) {
        // Upload images first
        final imageUrls = await _storageService.uploadVerificationImages(
          userId: userId,
          licensePlateImage: File(_licensePlateImage!.path),
          vehicleImage: File(_vehicleImage!.path),
        );

        // Save verification data with image URLs
        await _userService.submitDriverVerification(
          uid: userId,
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          licenseNumber: _licenseNumberController.text.trim(),
          vehicleType: _vehicleTypeController.text.trim(),
          vehiclePlate: _vehiclePlateController.text.trim(),
          licensePlateImageUrl: imageUrls['licensePlateImageUrl'],
          vehicleImageUrl: imageUrls['vehicleImageUrl'],
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Driver verification submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Go back to previous page
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Driver Verification',
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              CardWidget(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(
                        Icons.verified_user,
                        size: 32,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CardHeader(
                      title: const Text('Become a Verified Driver'),
                      description: const Text(
                        'Complete the form below to verify your driver profile and start accepting delivery requests.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Verification Form
              CardWidget(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Full Name
                    Input(
                      controller: _fullNameController,
                      label: 'Full Name',
                      placeholder: 'John Doe',
                      prefixIcon: Icon(Icons.person_outline, size: 18, color: Colors.grey[400]),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Full name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
                    Input(
                      controller: _phoneController,
                      label: 'Phone Number',
                      placeholder: '+1 234 567 8900',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icon(Icons.phone_outlined, size: 18, color: Colors.grey[400]),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Driver Information
                    Text(
                      'Driver Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // License Number
                    Input(
                      controller: _licenseNumberController,
                      label: 'Driver License Number',
                      placeholder: 'DL123456789',
                      prefixIcon: Icon(Icons.badge_outlined, size: 18, color: Colors.grey[400]),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'License number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Vehicle Information
                    Text(
                      'Vehicle Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Vehicle Type
                    Input(
                      controller: _vehicleTypeController,
                      label: 'Vehicle Type',
                      placeholder: 'Pickup Truck, Van, etc.',
                      prefixIcon: Icon(Icons.local_shipping_outlined, size: 18, color: Colors.grey[400]),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vehicle type is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Vehicle Plate Number
                    Input(
                      controller: _vehiclePlateController,
                      label: 'License Plate Number',
                      placeholder: 'ABC-1234',
                      prefixIcon: Icon(Icons.pin_outlined, size: 18, color: Colors.grey[400]),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'License plate is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Photo Upload Section
              CardWidget(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Photos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please upload clear photos for verification',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // License Plate Photo
                    _buildImageUploadCard(
                      title: 'License Plate Photo',
                      description: 'Upload a clear photo of your license plate',
                      icon: Icons.credit_card,
                      image: _licensePlateImage,
                      onTap: () => _showImageSourceDialog(true),
                      onRemove: () => _removeImage(true),
                    ),
                    const SizedBox(height: 16),

                    // Vehicle Photo
                    _buildImageUploadCard(
                      title: 'Vehicle Photo',
                      description: 'Upload a photo of your vehicle',
                      icon: Icons.local_shipping,
                      image: _vehicleImage,
                      onTap: () => _showImageSourceDialog(false),
                      onRemove: () => _removeImage(false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Terms and Conditions
              CardWidget(
                child: CheckboxListTile(
                  value: _agreedToTerms,
                  onChanged: (value) {
                    setState(() => _agreedToTerms = value ?? false);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'I agree to the terms and conditions',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                  subtitle: Text(
                    'By becoming a driver, you agree to follow all safety guidelines and delivery protocols.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              Button(
                onPressed: _isSubmitting ? null : _submitVerification,
                isLoading: _isSubmitting,
                size: ButtonSize.lg,
                child: const Text('Submit Verification'),
              ),
              const SizedBox(height: 16),

              // Info Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your application will be reviewed within 24-48 hours. You will be notified once approved.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[900],
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
    );
  }

  // Build image upload card widget
  Widget _buildImageUploadCard({
    required String title,
    required String description,
    required IconData icon,
    required XFile? image,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: image != null ? Colors.green[300]! : Colors.grey[300]!,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: image != null 
                          ? Colors.green[100] 
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      image != null ? Icons.check_circle : icon,
                      color: image != null 
                          ? Colors.green[700] 
                          : Colors.grey[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          image != null ? 'Photo uploaded' : description,
                          style: TextStyle(
                            fontSize: 13,
                            color: image != null 
                                ? Colors.green[700] 
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    image != null ? Icons.check_circle : Icons.camera_alt_outlined,
                    color: image != null 
                        ? Colors.green[700] 
                        : Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (image != null) ...[
            Divider(color: Colors.grey[300], height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(image.path),
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      IconButton(
                        onPressed: onTap,
                        icon: const Icon(Icons.edit),
                        tooltip: 'Change Photo',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(Icons.delete),
                        tooltip: 'Remove Photo',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red[100],
                          foregroundColor: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
