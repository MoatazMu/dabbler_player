import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _userNameKey = 'user_name';
  static const String _userLocationKey = 'user_location';
  static const String _languageKey = 'app_language';

  /// Get user name from preferences
  static Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (e) {
      return null;
    }
  }

  /// Save user name to preferences
  static Future<bool> setUserName(String? name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (name == null || name.trim().isEmpty) {
        return await prefs.remove(_userNameKey);
      }
      return await prefs.setString(_userNameKey, name.trim());
    } catch (e) {
      return false;
    }
  }

  /// Get user location from preferences
  static Future<String?> getUserLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userLocationKey);
    } catch (e) {
      return null;
    }
  }

  /// Save user location to preferences
  static Future<bool> setUserLocation(String? location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (location == null || location.trim().isEmpty) {
        return await prefs.remove(_userLocationKey);
      }
      return await prefs.setString(_userLocationKey, location.trim());
    } catch (e) {
      return false;
    }
  }

  /// Get app language from preferences
  static Future<String> getLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey) ?? 'en';
    } catch (e) {
      return 'en';
    }
  }

  /// Save app language to preferences
  static Future<bool> setLanguage(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_languageKey, language);
    } catch (e) {
      return false;
    }
  }

  /// Clear all user preferences
  static Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userNameKey);
      await prefs.remove(_userLocationKey);
      await prefs.remove(_languageKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validate user name
  static bool isValidName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return false;
    }
    
    final trimmedName = name.trim();
    
    // Check minimum length
    if (trimmedName.length < 2) {
      return false;
    }
    
    // Check maximum length
    if (trimmedName.length > 50) {
      return false;
    }
    
    // Check for valid characters (letters, spaces, some special characters)
    final validNameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\u0600-\u06FF\s\.\-\x27]+$');
    if (!validNameRegex.hasMatch(trimmedName)) {
      return false;
    }
    
    // Check it's not all spaces or special characters
    final hasLetter = RegExp(r'[a-zA-ZÀ-ÿ\u0600-\u06FF]').hasMatch(trimmedName);
    if (!hasLetter) {
      return false;
    }
    
    return true;
  }

  /// Sanitize user name
  static String? sanitizeName(String? name) {
    if (name == null) return null;
    
    // Trim and remove extra spaces
    String sanitized = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    
    // Capitalize first letter of each word
    sanitized = sanitized.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
    
    return sanitized;
  }
}