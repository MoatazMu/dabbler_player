import 'dart:async';

class MockAuthService {
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;
  MockAuthService._internal();

  // Mock user data
  Map<String, dynamic>? _currentUser;
  bool _isAuthenticated = false;

  // Mock methods
  Future<void> signUpWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    // Simulate success
    _currentUser = {
      'id': 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      'email': email,
      'created_at': DateTime.now().toIso8601String(),
    };
    _isAuthenticated = true;
  }

  Future<void> signUpWithPhone(String phoneNumber, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    // Simulate success
    _currentUser = {
      'id': 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      'phone': phoneNumber,
      'created_at': DateTime.now().toIso8601String(),
    };
    _isAuthenticated = true;
  }

  Future<void> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    // Simulate success
    _currentUser = {
      'id': 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      'email': email,
      'created_at': DateTime.now().toIso8601String(),
    };
    _isAuthenticated = true;
  }

  Future<void> sendOtp(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    // In a real app, this would send an OTP to the phone number
    print('Mock OTP sent to: $phoneNumber');
  }

  Future<void> verifyOtp(String phoneNumber, String otpCode) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    // Simulate OTP verification (accept any 6-digit code)
    if (otpCode.length == 6 && int.tryParse(otpCode) != null) {
      _currentUser = {
        'id': 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
        'phone': phoneNumber,
        'created_at': DateTime.now().toIso8601String(),
      };
      _isAuthenticated = true;
    } else {
      throw Exception('Invalid OTP code');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    // In a real app, this would send a password reset email
    print('Mock password reset email sent to: $email');
  }

  Future<void> updatePassword(String newPassword) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    // In a real app, this would update the user's password
    print('Mock password updated successfully');
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    _currentUser = null;
    _isAuthenticated = false;
  }

  // Getters
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
} 