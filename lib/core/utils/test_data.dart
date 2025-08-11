/// Test data for development and testing purposes
/// This file contains dummy user credentials for testing the app
library;

class TestData {
  // Test Users with Email and Password
  static const List<Map<String, String>> testUsers = [
    {
      'email': 'test@dabbler.com',
      'password': 'test123',
      'name': 'Test User',
      'phone': '+971501234567',
    },
    {
      'email': 'demo@dabbler.com',
      'password': 'demo123',
      'name': 'Demo User',
      'phone': '+971507654321',
    },
    {
      'email': 'user@example.com',
      'password': 'password123',
      'name': 'Example User',
      'phone': '+971509876543',
    },
    {
      'email': 'admin@dabbler.com',
      'password': 'admin123',
      'name': 'Admin User',
      'phone': '+971501112223',
    },
    {
      'email': 'player@dabbler.com',
      'password': 'player123',
      'name': 'Player User',
      'phone': '+971504445556',
    },
  ];

  // Test Phone Numbers for OTP testing
  static const List<String> testPhoneNumbers = [
    '+971501234567',
    '+971507654321',
    '+971509876543',
    '+971501112223',
    '+971504445556',
    '+971508889990',
    '+971502223334',
    '+971506667778',
  ];

  // Test OTP Codes
  static const List<String> testOtpCodes = [
    '555555', // Main test OTP (already implemented)
    '123456',
    '000000',
    '111111',
    '999999',
  ];

  // Helper methods
  static Map<String, String>? getUserByEmail(String email) {
    try {
      return testUsers.firstWhere((user) => user['email'] == email);
    } catch (e) {
      return null;
    }
  }

  static Map<String, String>? getUserByPhone(String phone) {
    try {
      return testUsers.firstWhere((user) => user['phone'] == phone);
    } catch (e) {
      return null;
    }
  }

  static bool isValidTestEmail(String email) {
    return testUsers.any((user) => user['email'] == email);
  }

  static bool isValidTestPhone(String phone) {
    return testPhoneNumbers.contains(phone);
  }

  static bool isValidTestOtp(String otp) {
    return testOtpCodes.contains(otp);
  }

  // Get random test user
  static Map<String, String> getRandomUser() {
    final random = DateTime.now().millisecondsSinceEpoch % testUsers.length;
    return testUsers[random];
  }

  // Get random test phone
  static String getRandomPhone() {
    final random = DateTime.now().millisecondsSinceEpoch % testPhoneNumbers.length;
    return testPhoneNumbers[random];
  }

  // Get random test OTP
  static String getRandomOtp() {
    final random = DateTime.now().millisecondsSinceEpoch % testOtpCodes.length;
    return testOtpCodes[random];
  }
} 