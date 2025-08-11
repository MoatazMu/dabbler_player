import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/test_data.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import 'package:go_router/go_router.dart';

class EmailInputScreen extends StatefulWidget {
  const EmailInputScreen({super.key});

  @override
  State<EmailInputScreen> createState() => _EmailInputScreenState();
}

class _EmailInputScreenState extends State<EmailInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isEmailValid = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  void _onEmailChanged(String value) {
    final isValid = _validateEmail(value) == null;
    if (isValid != _isEmailValid) {
      setState(() {
        _isEmailValid = isValid;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final authService = AuthService();
      
      print('🔍 [DEBUG] EmailInputScreen: Processing email: $email');
      
      // Check if this is a test user first
      final testUser = TestData.getUserByEmail(email);
      if (testUser != null) {
        print('🧪 [DEBUG] EmailInputScreen: Test user found: $email');
        // Test user exists - redirect to enter password screen
        if (mounted) {
          context.push('/enter_password', extra: {'email': email});
        }
        return;
      }
      
      // Check if user exists in database
      print('🔍 [DEBUG] EmailInputScreen: Checking if user exists in database: $email');
      final userExists = await authService.checkUserExistsByEmail(email);
      
      if (userExists) {
        print('✅ [DEBUG] EmailInputScreen: User exists in database: $email');
        // User exists - redirect to enter password screen
        if (mounted) {
          context.push('/enter_password', extra: {'email': email});
        }
      } else {
        print('🆕 [DEBUG] EmailInputScreen: New user, redirecting to profile creation: $email');
        // User doesn't exist - redirect to profile creation (account will be created there)
        if (mounted) {
          context.push('/create_user_information', extra: {'email': email, 'forceNew': true});
        }
      }
    } catch (e) {
      print('❌ [DEBUG] EmailInputScreen: Error in _handleSubmit: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                          'Enter your email to get started',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Email Input
                  CustomInputField(
                    controller: _emailController,
                    label: 'Email Address',
                    placeholder: 'Enter your email address',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    onChanged: _onEmailChanged,
                  ),
                  const SizedBox(height: 36),
                  // Get Started Button (Primary)
                  CustomButton(
                    onPressed: (_isLoading || !_isEmailValid) ? null : _handleSubmit,
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
                  // Continue with Phone Button (Secondary)
                  CustomButton(
                    onPressed: () => context.push('/'),
                    text: 'Continue with Phone',
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
                            '🧪 Test Emails',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: TestData.testUsers.map((user) {
                              return GestureDetector(
                                onTap: () {
                                  _emailController.text = user['email']!;
                                  _onEmailChanged(user['email']!);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    user['email']!,
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