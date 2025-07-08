class LocalizationHelper {
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'good_morning': 'Good morning',
      'good_afternoon': 'Good afternoon',
      'good_evening': 'Good evening',
      'welcome_back': 'Welcome back',
      'morning_message': 'Ready to start your day with some sports?',
      'afternoon_message': 'Perfect time for a game break!',
      'evening_message': 'Time to unwind with some sports!',
      'default_user': 'Player',
      'location_loading': 'Finding your location...',
      'location_error': 'Unable to detect location',
      'location_denied': 'Location access denied',
      'retry': 'Retry',
      'manual_location': 'Set manually',
      'search_location': 'Search for your area',
      'current_location': 'Current location',
    },
    'ar': {
      'good_morning': 'صباح الخير',
      'good_afternoon': 'مساء الخير',
      'good_evening': 'مساء الخير',
      'welcome_back': 'أهلاً بعودتك',
      'morning_message': 'جاهز لبدء يومك ببعض الرياضة؟',
      'afternoon_message': 'وقت مثالي لاستراحة رياضية!',
      'evening_message': 'وقت للاسترخاء مع بعض الرياضة!',
      'default_user': 'لاعب',
      'location_loading': 'جاري تحديد موقعك...',
      'location_error': 'لا يمكن تحديد الموقع',
      'location_denied': 'تم رفض الوصول للموقع',
      'retry': 'إعادة المحاولة',
      'manual_location': 'تحديد يدوياً',
      'search_location': 'ابحث عن منطقتك',
      'current_location': 'الموقع الحالي',
    },
  };

  /// Get translated string for given key and language
  static String translate(String key, {String language = 'en'}) {
    final translations = _translations[language];
    if (translations == null) {
      // Fallback to English if language not found
      return _translations['en']![key] ?? key;
    }
    return translations[key] ?? _translations['en']![key] ?? key;
  }

  /// Get greeting based on time and language
  static String getGreeting(int hour, {String language = 'en'}) {
    String greetingKey;
    if (hour >= 5 && hour < 12) {
      greetingKey = 'good_morning';
    } else if (hour >= 12 && hour < 17) {
      greetingKey = 'good_afternoon';
    } else {
      greetingKey = 'good_evening';
    }
    
    return translate(greetingKey, language: language);
  }

  /// Get welcome message based on time and language
  static String getWelcomeMessage(int hour, {String language = 'en'}) {
    String messageKey;
    if (hour >= 5 && hour < 12) {
      messageKey = 'morning_message';
    } else if (hour >= 12 && hour < 17) {
      messageKey = 'afternoon_message';
    } else {
      messageKey = 'evening_message';
    }
    
    return translate(messageKey, language: language);
  }

  /// Get personalized greeting with user name
  static String getPersonalizedGreeting(String? userName, int hour, {String language = 'en'}) {
    final greeting = getGreeting(hour, language: language);
    final displayName = _getDisplayName(userName, language: language);
    
    if (language == 'ar') {
      // Arabic: "صباح الخير، أحمد!" (Good morning, Ahmed!)
      return '$greeting، $displayName!';
    } else {
      // English: "Good morning, Ahmed!" 
      return '$greeting, $displayName!';
    }
  }

  /// Get full personalized welcome message
  static String getFullWelcomeMessage(String? userName, int hour, {String language = 'en'}) {
    final greeting = getPersonalizedGreeting(userName, hour, language: language);
    final welcomeMessage = getWelcomeMessage(hour, language: language);
    
    return '$greeting $welcomeMessage';
  }

  /// Get display name with fallback
  static String _getDisplayName(String? userName, {String language = 'en'}) {
    if (userName != null && userName.trim().isNotEmpty) {
      return userName.trim();
    }
    return translate('default_user', language: language);
  }

  /// Check if language is RTL (Right-to-Left)
  static bool isRTL(String language) {
    return language == 'ar';
  }

  /// Get text direction for language
  static String getTextDirection(String language) {
    return isRTL(language) ? 'rtl' : 'ltr';
  }

  /// Get supported languages
  static List<String> getSupportedLanguages() {
    return _translations.keys.toList();
  }

  /// Get language display name
  static String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return languageCode.toUpperCase();
    }
  }

  /// Format name for display (considering RTL languages)
  static String formatNameForDisplay(String? name, {String language = 'en'}) {
    if (name == null || name.trim().isEmpty) {
      return translate('default_user', language: language);
    }

    final trimmedName = name.trim();
    
    // For Arabic, names might need special handling
    if (language == 'ar') {
      // Keep original Arabic name formatting
      return trimmedName;
    } else {
      // For English, capitalize properly
      return trimmedName.split(' ').map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }
  }
}