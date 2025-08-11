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

  // Test Venues
  static const List<Map<String, dynamic>> testVenues = [
    {
      'id': 'venue_1',
      'name': 'Central Sports Complex',
      'address': 'Downtown Dubai',
      'distance': '0.5 km',
      'rating': 4.8,
      'sports': ['Football', 'Basketball', 'Tennis'],
      'price': 'AED 150/hour',
    },
    {
      'id': 'venue_2',
      'name': 'Elite Padel Center',
      'address': 'Jumeirah Beach Road',
      'distance': '0.8 km',
      'rating': 4.9,
      'sports': ['Padel', 'Squash'],
      'price': 'AED 200/hour',
    },
    {
      'id': 'venue_3',
      'name': 'Downtown Fitness Center',
      'address': 'Sheikh Zayed Road',
      'distance': '1.2 km',
      'rating': 4.6,
      'sports': ['Basketball', 'Volleyball'],
      'price': 'AED 120/hour',
    },
    {
      'id': 'venue_4',
      'name': 'Riverside Recreation',
      'address': 'Dubai Creek',
      'distance': '2.1 km',
      'rating': 4.9,
      'sports': ['Tennis', 'Badminton'],
      'price': 'AED 180/hour',
    },
  ];

  // Test Games
  static const List<Map<String, dynamic>> testGames = [
    {
      'id': 'game_1',
      'title': 'Weekend Football Match',
      'sport': 'Football',
      'venue': 'Central Sports Complex',
      'date': 'Tomorrow',
      'time': '6:00 PM',
      'players': '8/10',
      'price': 'AED 50',
    },
    {
      'id': 'game_2',
      'title': 'Padel Tournament',
      'sport': 'Padel',
      'venue': 'Elite Padel Center',
      'date': 'Saturday',
      'time': '2:00 PM',
      'players': '4/8',
      'price': 'AED 80',
    },
    {
      'id': 'game_3',
      'title': 'Basketball Pickup',
      'sport': 'Basketball',
      'venue': 'Downtown Fitness Center',
      'date': 'Friday',
      'time': '7:30 PM',
      'players': '10/12',
      'price': 'AED 40',
    },
  ];

  // Test Bookings
  static const List<Map<String, dynamic>> testBookings = [
    {
      'id': 'booking_1',
      'title': 'Football Match',
      'venue': 'Central Sports Complex',
      'date': 'Tomorrow',
      'time': '6:00 PM',
      'status': 'confirmed',
      'price': 'AED 50',
    },
    {
      'id': 'booking_2',
      'title': 'Padel Game',
      'venue': 'Elite Padel Center',
      'date': 'Saturday',
      'time': '2:00 PM',
      'status': 'confirmed',
      'price': 'AED 80',
    },
    {
      'id': 'booking_3',
      'title': 'Basketball Session',
      'venue': 'Downtown Fitness Center',
      'date': 'Friday',
      'time': '7:30 PM',
      'status': 'pending',
      'price': 'AED 40',
    },
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

/// Test scenarios for different user types
class TestScenarios {
  // New user (not in test data)
  static const Map<String, String> newUser = {
    'email': 'newuser@test.com',
    'password': 'newpass123',
    'phone': '+971509999999',
  };

  // Existing user with valid credentials
  static const Map<String, String> existingUser = {
    'email': 'test@dabbler.com',
    'password': 'test123',
    'phone': '+971501234567',
  };

  // User with wrong password
  static const Map<String, String> wrongPasswordUser = {
    'email': 'test@dabbler.com',
    'password': 'wrongpassword',
    'phone': '+971501234567',
  };

  // Invalid email format
  static const Map<String, String> invalidEmailUser = {
    'email': 'invalid-email',
    'password': 'test123',
    'phone': '+971501234567',
  };

  // Invalid phone format
  static const Map<String, String> invalidPhoneUser = {
    'email': 'test@dabbler.com',
    'password': 'test123',
    'phone': '12345', // Invalid format
  };
} 