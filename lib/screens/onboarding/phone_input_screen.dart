import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/test_data.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final String _countryCode = '+971'; // Default to UAE
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isPhoneValid = false;

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    // Simple validation: must be 9 digits (UAE format: 5XXXXXXXX)
    if (phone.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^5\d{8}').hasMatch(phone)) {
      return 'Enter a valid UAE phone number';
    }
    return null;
  }

  void _onPhoneChanged(String value) {
    final isValid = _validatePhone(value) == null;
    if (isValid != _isPhoneValid) {
      setState(() {
        _isPhoneValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    final phone = '$_countryCode${_phoneController.text.trim()}';
    
    try {
      print('📱 [DEBUG] PhoneInputScreen: Processing phone: $phone');
      
      // Check if this is a test phone number first
      if (TestData.isValidTestPhone(phone)) {
        print('🧪 [DEBUG] PhoneInputScreen: Test phone detected: $phone');
        // Test phone number - simulate successful OTP sending
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call
        
        if (mounted) {
          setState(() {
            _successMessage = 'Test OTP sent! Use code: 555555';
          });
        }
      } else {
        print('📱 [DEBUG] PhoneInputScreen: Real phone, checking if user exists: $phone');
        // Real phone number - check if user exists first
        final authService = AuthService();
        final userExists = await authService.checkUserExistsByPhone(phone);
        
        if (userExists) {
          print('✅ [DEBUG] PhoneInputScreen: User exists by phone: $phone');
        } else {
          print('🆕 [DEBUG] PhoneInputScreen: New user by phone: $phone');
        }
        
        // Send OTP regardless of user existence
        await authService.signInWithPhone(phone: phone);
        
        if (mounted) {
          setState(() {
            _successMessage = 'OTP sent! Please check your phone.';
          });
        }
      }
    } catch (e) {
      print('❌ [DEBUG] PhoneInputScreen: Error sending OTP: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to send OTP. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    
    // Navigate to OTP verification screen regardless of OTP sending result
    if (mounted) {
      context.push('/otp_verification', extra: {'phone': phone});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => context.push('/language_selection'),
            tooltip: 'Select Language',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Welcome to Dabbler Player',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enter your phone to get started',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Phone Input
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _countryCode, 
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              // Icon(
                              //   Icons.arrow_drop_down, 
                              //   size: 24,
                              //   color: Theme.of(context).colorScheme.onSurfaceVariant,
                              // ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomInputField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            placeholder: '5X XXX XXXX',
                            keyboardType: TextInputType.phone,
                            validator: _validatePhone,
                            onChanged: _onPhoneChanged,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Error/Success
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                    ),
                  if (_successMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_successMessage!, style: TextStyle(color: Colors.green))),
                          ],
                        ),
                      ),
                    ),
                  // Continue Button (Primary)
                  CustomButton(
                    onPressed: (_isLoading || !_isPhoneValid) ? null : _handleSubmit,
                    text: _isLoading ? 'Sending...' : 'Continue',
                  ),
                  const SizedBox(height: 20),
                  // Continue as Guest Button (Secondary)
                  CustomButton(
                    onPressed: () {
                      context.go('/home');
                    },
                    text: 'Continue as Guest',
                    variant: ButtonVariant.secondary,
                  ),
                  const SizedBox(height: 16),
                  // Continue with Email Button (Secondary)
                  CustomButton(
                    onPressed: () => context.push('/email_input'),
                    text: 'Continue using Email',
                    variant: ButtonVariant.secondary,
                  ),
                  const SizedBox(height: 32),
                  // Test Data Section (Development Only)
                  if (const bool.fromEnvironment('dart.vm.product') == false) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🧪 Test Phone Numbers',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to auto-fill (OTP: 555555)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue[600],
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: TestData.testPhoneNumbers.take(5).map((phone) {
                              final shortPhone = phone.replaceFirst('+971', '');
                              return GestureDetector(
                                onTap: () {
                                  _phoneController.text = shortPhone;
                                  _onPhoneChanged(shortPhone);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    shortPhone,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.blue[700],
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Terms and Privacy
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'By continuing, you agree to our Terms of Service and Privacy Policy',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
