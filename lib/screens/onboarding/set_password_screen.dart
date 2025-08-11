import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/onboarding_service.dart';
import '../../features/authentication/presentation/providers/auth_providers.dart';
import 'create_user_information.dart' show RegistrationData;

class SetPasswordScreen extends ConsumerStatefulWidget {
  final RegistrationData? registrationData;

  const SetPasswordScreen({super.key, this.registrationData});

  @override
  ConsumerState<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _cooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final registrationData = widget.registrationData;
    try {
      if (registrationData == null) {
        throw Exception('Registration data is missing');
      }
    final email = registrationData.email.trim();
    // Defensive: strip invisible chars that can sneak in from copy/paste
    final normalizedEmail = email.replaceAll(RegExp(r"[\u200B-\u200D\uFEFF]"), "");
      final password = _passwordController.text;

      final authService = AuthService();
      final onboardingService = OnboardingService();

      // Check if user already exists before attempting signup
      print('🔍 [DEBUG] SetPasswordScreen: Checking if user already exists: $normalizedEmail');
      
      final userExists = await authService.checkUserExistsByEmail(normalizedEmail);
      if (userExists) {
        print('⚠️ [DEBUG] SetPasswordScreen: User already exists, redirecting to login');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account already exists. Please sign in with your password.'),
            backgroundColor: Colors.orange,
          ),
        );
        context.go('/enter-password', extra: normalizedEmail);
        return;
      }

      bool createdAccount = false;
      try {
        print('👤 [DEBUG] SetPasswordScreen: Creating new account for: $normalizedEmail');
        
        // Create account with complete user metadata so database trigger creates proper profile
        await authService.signUpWithEmailAndMetadata(
          email: normalizedEmail, 
          password: password,
          metadata: {
            'name': registrationData.name,
            'age': registrationData.age,
            'gender': registrationData.gender,
            'sports': registrationData.sports,
            'intent': registrationData.intent,
          }
        );
        
        createdAccount = true;
        print('✅ [DEBUG] SetPasswordScreen: Account created successfully with complete profile');
      } catch (e) {
        final msg = e.toString();
        print('❌ [DEBUG] SetPasswordScreen: Signup error: $msg');
        
        if (msg.contains('already registered') || msg.contains('user_already_exists')) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account already exists. Please sign in with your password.'),
              backgroundColor: Colors.orange,
            ),
          );
          context.go('/enter-password', extra: normalizedEmail);
          return;
        }
        if (msg.contains('over_email_send_rate_limit') || msg.contains('after 12 seconds')) {
          if (!mounted) return;
          setState(() => _cooldown = 12);
          _cooldownTimer?.cancel();
          _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
            if (!mounted) {
              t.cancel();
              return;
            }
            setState(() {
              _cooldown = (_cooldown - 1).clamp(0, 999);
              if (_cooldown == 0) t.cancel();
            });
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please wait a few seconds before trying again.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        rethrow;
      }

      // Ensure authenticated if necessary
      if (!authService.isAuthenticated() && createdAccount) {
        // If email confirmations disabled, signUp usually authenticates. Otherwise, sign in.
        try {
      await authService.signInWithEmail(email: normalizedEmail, password: password);
        } catch (_) {/* ignore */}
      }

      // Profile was already created with complete data by the database trigger
      print('✅ [DEBUG] SetPasswordScreen: User profile created automatically during signup');
      await onboardingService.markOnboardingComplete();

      // Refresh auth state to update Riverpod providers
      print('🔄 [DEBUG] SetPasswordScreen: Refreshing auth state...');
      await ref.read(authControllerProvider.notifier).refreshAuthState();
      
      // Verify the user is now authenticated
      final isAuthenticated = ref.read(authControllerProvider).isAuthenticated;
      print('✅ [DEBUG] SetPasswordScreen: Auth state refreshed - isAuthenticated: $isAuthenticated');

      if (!mounted) return;
      
      if (isAuthenticated) {
        // Navigate to welcome screen with user's display name
        final displayName = registrationData.name ?? 'Player';
        print('🎉 [DEBUG] SetPasswordScreen: User authenticated, navigating to welcome screen for: $displayName');
        context.go('/welcome', extra: {'displayName': displayName});
      } else {
        print('❌ [DEBUG] SetPasswordScreen: User not authenticated after refresh, redirecting to login');
        context.go('/login');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.registrationData?.email ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Set Password'), backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (email.isNotEmpty)
                  Text('Email: $email', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                CustomInputField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Enter a strong password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: _isLoading ? 'Creating account...' : (_cooldown > 0 ? 'Wait $_cooldown s' : 'Create Account'),
                  onPressed: _isLoading || _cooldown > 0 ? null : _handleSubmit,
                  loading: _isLoading,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}