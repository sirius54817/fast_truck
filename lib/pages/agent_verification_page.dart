import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fast_truck/services/auth_service.dart';
import 'package:fast_truck/services/user_service.dart';
import 'package:fast_truck/ui/card.dart';
import 'package:fast_truck/ui/input.dart';
import 'package:fast_truck/ui/button.dart';

class AgentVerificationPage extends StatefulWidget {
  const AgentVerificationPage({super.key});

  @override
  State<AgentVerificationPage> createState() => _AgentVerificationPageState();
}

class _AgentVerificationPageState extends State<AgentVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _panController = TextEditingController();
  final _agencyNameController = TextEditingController();
  final _agencyContactController = TextEditingController();
  
  final UserService _userService = UserService();
  
  bool _isSubmitting = false;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _panController.dispose();
    _agencyNameController.dispose();
    _agencyContactController.dispose();
    super.dispose();
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

    setState(() => _isSubmitting = true);

    try {
      final authService = AuthService();
      final user = authService.currentUser;

      if (user == null) {
        throw 'User not authenticated';
      }

      await _userService.submitAgentVerification(
        uid: user.uid,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        pan: _panController.text.trim().toUpperCase(),
        agencyName: _agencyNameController.text.trim(),
        agencyContact: _agencyContactController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agent verification submitted successfully! Please wait for admin approval.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit verification: $e'),
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
              'Fast Truck',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              // Header
              Text(
                'Agent Verification',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Submit your information for agent verification',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),

              // Personal Information Card
              CardWidget(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.blue[700], size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    Input(
                      controller: _nameController,
                      label: 'Full Name',
                      placeholder: 'Enter your full name',
                      prefixIcon: const Icon(Icons.badge),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    Input(
                      controller: _phoneController,
                      label: 'Phone Number',
                      placeholder: 'Enter your phone number',
                      prefixIcon: const Icon(Icons.phone),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    Input(
                      controller: _panController,
                      label: 'PAN Number',
                      placeholder: 'Enter your PAN number',
                      prefixIcon: const Icon(Icons.credit_card),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your PAN number';
                        }
                        if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value.toUpperCase())) {
                          return 'Please enter a valid PAN number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Agency Information Card
              CardWidget(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.business, color: Colors.blue[700], size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Agency Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    Input(
                      controller: _agencyNameController,
                      label: 'Agency Name',
                      placeholder: 'Enter your agency name',
                      prefixIcon: const Icon(Icons.store),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your agency name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    Input(
                      controller: _agencyContactController,
                      label: 'Agency Contact',
                      placeholder: 'Enter agency contact information',
                      prefixIcon: const Icon(Icons.contact_phone),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter agency contact information';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Terms and Conditions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          onChanged: (value) {
                            setState(() => _agreedToTerms = value ?? false);
                          },
                          activeColor: Colors.blue[700],
                        ),
                        Expanded(
                          child: Text(
                            'I agree to the terms and conditions and confirm that all information provided is accurate.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: Button(
                  onPressed: _isSubmitting ? null : _submitVerification,
                  isLoading: _isSubmitting,
                  size: ButtonSize.lg,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  child: Text(_isSubmitting ? 'Submitting...' : 'Submit for Verification'),
                ),
              ),
              const SizedBox(height: 20),

              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber[800]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your verification request will be reviewed by our admin team. You will be able to create requests once verified.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
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
}
