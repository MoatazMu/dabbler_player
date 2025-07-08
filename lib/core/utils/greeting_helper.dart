import 'localization_helper.dart';
import 'user_preferences.dart';

class GreetingHelper {
  /// Returns a time-based greeting message
  static String getGreeting({DateTime? currentTime, String? language}) {
    final now = currentTime ?? DateTime.now();
    final hour = now.hour;
    final lang = language ?? 'en';

    return LocalizationHelper.getGreeting(hour, language: lang);
  }

  /// Returns a time-based welcome message with additional context
  static String getWelcomeMessage({DateTime? currentTime, String? language}) {
    final now = currentTime ?? DateTime.now();
    final hour = now.hour;
    final lang = language ?? 'en';

    final greeting = LocalizationHelper.getGreeting(hour, language: lang);
    final message = LocalizationHelper.getWelcomeMessage(hour, language: lang);
    
    return '$greeting! $message';
  }

  /// Returns a personalized greeting with user name
  static Future<String> getPersonalizedGreeting({
    DateTime? currentTime,
    String? userName,
    String? language,
  }) async {
    final now = currentTime ?? DateTime.now();
    final hour = now.hour;
    final lang = language ?? await UserPreferences.getLanguage();
    final name = userName ?? await UserPreferences.getUserName();

    return LocalizationHelper.getPersonalizedGreeting(name, hour, language: lang);
  }

  /// Returns a full personalized welcome message
  static Future<String> getFullPersonalizedMessage({
    DateTime? currentTime,
    String? userName,
    String? language,
  }) async {
    final now = currentTime ?? DateTime.now();
    final hour = now.hour;
    final lang = language ?? await UserPreferences.getLanguage();
    final name = userName ?? await UserPreferences.getUserName();

    return LocalizationHelper.getFullWelcomeMessage(name, hour, language: lang);
  }

  /// Returns the time period as a string for testing purposes
  static String getTimePeriod({DateTime? currentTime}) {
    final now = currentTime ?? DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 17) {
      return 'afternoon';
    } else {
      return 'evening';
    }
  }

  /// Get greeting with fallback handling
  static Future<String> getGreetingWithFallback({
    DateTime? currentTime,
    String? userName,
    String? language,
  }) async {
    try {
      final now = currentTime ?? DateTime.now();
      final hour = now.hour;
      final lang = language ?? await UserPreferences.getLanguage();
      
      // Try to get user name with validation
      String? validatedName;
      if (userName != null) {
        validatedName = UserPreferences.isValidName(userName) ? userName : null;
      } else {
        final storedName = await UserPreferences.getUserName();
        validatedName = UserPreferences.isValidName(storedName) ? storedName : null;
      }

      return LocalizationHelper.getPersonalizedGreeting(validatedName, hour, language: lang);
    } catch (e) {
      // Fallback to basic greeting in case of any error
      final now = currentTime ?? DateTime.now();
      final hour = now.hour;
      return LocalizationHelper.getGreeting(hour, language: language ?? 'en');
    }
  }

  /// Get welcome message with fallback handling
  static Future<String> getWelcomeMessageWithFallback({
    DateTime? currentTime,
    String? userName,
    String? language,
  }) async {
    try {
      final now = currentTime ?? DateTime.now();
      final hour = now.hour;
      final lang = language ?? await UserPreferences.getLanguage();
      
      // Try to get user name with validation
      String? validatedName;
      if (userName != null) {
        validatedName = UserPreferences.isValidName(userName) ? userName : null;
      } else {
        final storedName = await UserPreferences.getUserName();
        validatedName = UserPreferences.isValidName(storedName) ? storedName : null;
      }

      return LocalizationHelper.getFullWelcomeMessage(validatedName, hour, language: lang);
    } catch (e) {
      // Fallback to basic welcome message in case of any error
      final now = currentTime ?? DateTime.now();
      final hour = now.hour;
      final lang = language ?? 'en';
      final greeting = LocalizationHelper.getGreeting(hour, language: lang);
      final message = LocalizationHelper.getWelcomeMessage(hour, language: lang);
      return '$greeting! $message';
    }
  }

  /// Test helper: Simulate different user states
  static Future<Map<String, String>> testUserStates({
    DateTime? currentTime,
    String? language,
  }) async {
    final results = <String, String>{};
    final now = currentTime ?? DateTime.now();
    final lang = language ?? 'en';

    // Test with valid name
    results['valid_name'] = await getGreetingWithFallback(
      currentTime: now,
      userName: 'Ahmed Ali',
      language: lang,
    );

    // Test with empty name
    results['empty_name'] = await getGreetingWithFallback(
      currentTime: now,
      userName: '',
      language: lang,
    );

    // Test with null name
    results['null_name'] = await getGreetingWithFallback(
      currentTime: now,
      userName: null,
      language: lang,
    );

    // Test with invalid name (too short)
    results['invalid_short'] = await getGreetingWithFallback(
      currentTime: now,
      userName: 'A',
      language: lang,
    );

    // Test with invalid name (too long)
    results['invalid_long'] = await getGreetingWithFallback(
      currentTime: now,
      userName: 'A' * 60,
      language: lang,
    );

    // Test with invalid name (special characters only)
    results['invalid_special'] = await getGreetingWithFallback(
      currentTime: now,
      userName: '!@#\$%',
      language: lang,
    );

    // Test with spaces only
    results['spaces_only'] = await getGreetingWithFallback(
      currentTime: now,
      userName: '   ',
      language: lang,
    );

    return results;
  }
}