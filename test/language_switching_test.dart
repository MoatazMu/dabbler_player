import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dabbler/core/utils/greeting_helper.dart';
import 'package:dabbler/core/utils/user_preferences.dart';
import 'package:dabbler/core/utils/localization_helper.dart';

void main() {
  group('Language Switching Tests - EN ↔ AR', () {
    setUp(() async {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    group('Basic Language Switching', () {
      test('should switch greeting from English to Arabic correctly', () async {
        final testTime = DateTime(2024, 1, 1, 9, 0); // 9 AM
        
        // Test English greeting
        final englishGreeting = await GreetingHelper.getGreetingWithFallback(
          currentTime: testTime,
          userName: 'Ahmed Ali',
          language: 'en',
        );
        
        // Test Arabic greeting
        final arabicGreeting = await GreetingHelper.getGreetingWithFallback(
          currentTime: testTime,
          userName: 'Ahmed Ali',
          language: 'ar',
        );
        
        // Verify English content
        expect(englishGreeting, contains('Good morning'));
        expect(englishGreeting, contains('Ahmed Ali'));
        
        // Verify Arabic content
        expect(arabicGreeting, contains('صباح الخير'));
        expect(arabicGreeting, contains('Ahmed Ali'));
        
        // Verify they are different
        expect(englishGreeting, isNot(equals(arabicGreeting)));
        
        print('English: $englishGreeting');
        print('Arabic: $arabicGreeting');
      });

      test('should switch welcome messages from English to Arabic correctly', () async {
        final testTime = DateTime(2024, 1, 1, 14, 0); // 2 PM
        
        // Test English welcome message
        final englishMessage = await GreetingHelper.getWelcomeMessageWithFallback(
          currentTime: testTime,
          userName: 'Sara Ahmed',
          language: 'en',
        );
        
        // Test Arabic welcome message
        final arabicMessage = await GreetingHelper.getWelcomeMessageWithFallback(
          currentTime: testTime,
          userName: 'Sara Ahmed',
          language: 'ar',
        );
        
        // Verify English content
        expect(englishMessage, contains('Good afternoon'));
        expect(englishMessage, contains('Perfect time for a game break'));
        expect(englishMessage, contains('Sara Ahmed'));
        
        // Verify Arabic content
        expect(arabicMessage, contains('مساء الخير'));
        expect(arabicMessage, contains('وقت مثالي لاستراحة رياضية'));
        expect(arabicMessage, contains('Sara Ahmed'));
        
        print('English Welcome: $englishMessage');
        print('Arabic Welcome: $arabicMessage');
      });

      test('should handle time periods consistently across languages', () async {
        final testCases = [
          {'hour': 7, 'en': 'Good morning', 'ar': 'صباح الخير'},
          {'hour': 13, 'en': 'Good afternoon', 'ar': 'مساء الخير'},
          {'hour': 19, 'en': 'Good evening', 'ar': 'مساء الخير'},
          {'hour': 23, 'en': 'Good evening', 'ar': 'مساء الخير'},
          {'hour': 3, 'en': 'Good evening', 'ar': 'مساء الخير'},
        ];

        for (final testCase in testCases) {
          final testTime = DateTime(2024, 1, 1, testCase['hour'] as int, 0);
          
          final englishGreeting = GreetingHelper.getGreeting(
            currentTime: testTime,
            language: 'en',
          );
          
          final arabicGreeting = GreetingHelper.getGreeting(
            currentTime: testTime,
            language: 'ar',
          );
          
          expect(englishGreeting, contains(testCase['en'] as String));
          expect(arabicGreeting, contains(testCase['ar'] as String));
          
          print('${testCase['hour']}h - EN: $englishGreeting | AR: $arabicGreeting');
        }
      });
    });

    group('Language Persistence and Session Tests', () {
      test('should persist language preference across sessions', () async {
        // Set language to Arabic
        await UserPreferences.setLanguage('ar');
        
        // Verify it's saved
        final savedLanguage = await UserPreferences.getLanguage();
        expect(savedLanguage, equals('ar'));
        
        // Use greeting without specifying language (should use saved)
        final greeting = await GreetingHelper.getPersonalizedGreeting(
          currentTime: DateTime(2024, 1, 1, 10, 0),
          userName: 'محمد أحمد',
        );
        
        expect(greeting, contains('صباح الخير'));
        print('Persisted Arabic greeting: $greeting');
        
        // Change back to English
        await UserPreferences.setLanguage('en');
        
        final englishGreeting = await GreetingHelper.getPersonalizedGreeting(
          currentTime: DateTime(2024, 1, 1, 10, 0),
          userName: 'Mohammed Ahmed',
        );
        
        expect(englishGreeting, contains('Good morning'));
        print('Persisted English greeting: $englishGreeting');
      });

      test('should handle language switching with name updates', () async {
        // Set English name
        await UserPreferences.setUserName('John Smith');
        await UserPreferences.setLanguage('en');
        
        final englishGreeting = await GreetingHelper.getPersonalizedGreeting(
          currentTime: DateTime(2024, 1, 1, 15, 0),
        );
        
        expect(englishGreeting, contains('Good afternoon'));
        expect(englishGreeting, contains('John Smith'));
        
        // Switch to Arabic but keep the same name
        await UserPreferences.setLanguage('ar');
        
        final arabicGreeting = await GreetingHelper.getPersonalizedGreeting(
          currentTime: DateTime(2024, 1, 1, 15, 0),
        );
        
        expect(arabicGreeting, contains('مساء الخير'));
        expect(arabicGreeting, contains('John Smith')); // Name should remain
        
        print('EN with name: $englishGreeting');
        print('AR with same name: $arabicGreeting');
      });

      test('should update greeting immediately after language change', () async {
        final testTime = DateTime(2024, 1, 1, 8, 0); // 8 AM
        
        // Start with English
        await UserPreferences.setLanguage('en');
        final greeting1 = await GreetingHelper.getPersonalizedGreeting(
          currentTime: testTime,
          userName: 'Test User',
        );
        
        // Switch to Arabic
        await UserPreferences.setLanguage('ar');
        final greeting2 = await GreetingHelper.getPersonalizedGreeting(
          currentTime: testTime,
          userName: 'Test User',
        );
        
        // Switch back to English
        await UserPreferences.setLanguage('en');
        final greeting3 = await GreetingHelper.getPersonalizedGreeting(
          currentTime: testTime,
          userName: 'Test User',
        );
        
        expect(greeting1, contains('Good morning'));
        expect(greeting2, contains('صباح الخير'));
        expect(greeting3, contains('Good morning'));
        
        expect(greeting1, isNot(equals(greeting2)));
        expect(greeting1, equals(greeting3));
        
        print('1st (EN): $greeting1');
        print('2nd (AR): $greeting2');
        print('3rd (EN): $greeting3');
      });
    });

    group('String Rendering and Alignment Tests', () {
      test('should detect RTL language correctly', () {
        expect(LocalizationHelper.isRTL('en'), isFalse);
        expect(LocalizationHelper.isRTL('ar'), isTrue);
        expect(LocalizationHelper.isRTL('fr'), isFalse);
        expect(LocalizationHelper.isRTL('invalid'), isFalse);
      });

      test('should return correct text direction', () {
        expect(LocalizationHelper.getTextDirection('en'), equals('ltr'));
        expect(LocalizationHelper.getTextDirection('ar'), equals('rtl'));
        expect(LocalizationHelper.getTextDirection('fr'), equals('ltr'));
      });

      test('should handle Arabic name formatting correctly', () {
        final arabicName = 'محمد أحمد الزهراني';
        final formattedName = LocalizationHelper.formatNameForDisplay(
          arabicName,
          language: 'ar',
        );
        
        expect(formattedName, equals(arabicName)); // Should preserve Arabic formatting
        print('Arabic name formatting: $formattedName');
        
        final englishName = 'john doe';
        final formattedEnglish = LocalizationHelper.formatNameForDisplay(
          englishName,
          language: 'en',
        );
        
        expect(formattedEnglish, equals('John Doe')); // Should capitalize
        print('English name formatting: $formattedEnglish');
      });

      test('should render all supported language display names', () {
        final languages = LocalizationHelper.getSupportedLanguages();
        
        for (final lang in languages) {
          final displayName = LocalizationHelper.getLanguageDisplayName(lang);
          expect(displayName, isNotNull);
          expect(displayName, isNotEmpty);
          print('Language $lang: $displayName');
        }
        
        expect(languages, contains('en'));
        expect(languages, contains('ar'));
      });

      test('should handle mixed language content correctly', () async {
        // Test English greeting with Arabic name
        final englishWithArabicName = await GreetingHelper.getGreetingWithFallback(
          currentTime: DateTime(2024, 1, 1, 11, 0),
          userName: 'محمد أحمد',
          language: 'en',
        );
        
        expect(englishWithArabicName, contains('Good morning'));
        expect(englishWithArabicName, contains('محمد أحمد'));
        
        // Test Arabic greeting with English name
        final arabicWithEnglishName = await GreetingHelper.getGreetingWithFallback(
          currentTime: DateTime(2024, 1, 1, 11, 0),
          userName: 'John Smith',
          language: 'ar',
        );
        
        expect(arabicWithEnglishName, contains('صباح الخير'));
        expect(arabicWithEnglishName, contains('John Smith'));
        
        print('EN greeting + AR name: $englishWithArabicName');
        print('AR greeting + EN name: $arabicWithEnglishName');
      });
    });

    group('Language Fallback and Error Handling', () {
      test('should fallback to English for unsupported languages', () {
        final greeting = LocalizationHelper.getGreeting(10, language: 'fr'); // French not supported
        expect(greeting, equals('Good morning')); // Should fallback to English
        
        final message = LocalizationHelper.getWelcomeMessage(15, language: 'de'); // German not supported
        expect(message, contains('Perfect time for a game break')); // Should fallback to English
      });

      test('should handle empty language parameter gracefully', () {
        final greeting = LocalizationHelper.getGreeting(14, language: '');
        expect(greeting, equals('Good afternoon')); // Should fallback to English
      });

      test('should handle null language parameter gracefully', () {
        final greeting = GreetingHelper.getGreeting(
          currentTime: DateTime(2024, 1, 1, 16, 0),
          language: null,
        );
        expect(greeting, contains('Good afternoon')); // Should use default English
      });

      test('should maintain functionality during rapid language switches', () async {
        final testTime = DateTime(2024, 1, 1, 12, 0);
        final languages = ['en', 'ar', 'en', 'ar', 'en'];
        final greetings = <String>[];
        
        for (final lang in languages) {
          final greeting = await GreetingHelper.getGreetingWithFallback(
            currentTime: testTime,
            userName: 'Test User',
            language: lang,
          );
          greetings.add(greeting);
        }
        
        // Verify alternating patterns
        expect(greetings[0], contains('Good afternoon'));
        expect(greetings[1], contains('مساء الخير'));
        expect(greetings[2], contains('Good afternoon'));
        expect(greetings[3], contains('مساء الخير'));
        expect(greetings[4], contains('Good afternoon'));
        
        print('Rapid switching test results:');
        for (int i = 0; i < greetings.length; i++) {
          print('${languages[i]}: ${greetings[i]}');
        }
      });
    });

    group('Complete Language Simulation', () {
      test('should simulate complete day in both languages', () async {
        final hours = [6, 9, 12, 15, 18, 21];
        final userName = 'أحمد محمد'; // Arabic name
        
        print('\n=== COMPLETE DAY SIMULATION - ENGLISH ===');
        for (final hour in hours) {
          final greeting = await GreetingHelper.getWelcomeMessageWithFallback(
            currentTime: DateTime(2024, 1, 1, hour, 0),
            userName: userName,
            language: 'en',
          );
          print('${hour.toString().padLeft(2, '0')}:00 - $greeting');
        }
        
        print('\n=== COMPLETE DAY SIMULATION - ARABIC ===');
        for (final hour in hours) {
          final greeting = await GreetingHelper.getWelcomeMessageWithFallback(
            currentTime: DateTime(2024, 1, 1, hour, 0),
            userName: userName,
            language: 'ar',
          );
          print('${hour.toString().padLeft(2, '0')}:00 - $greeting');
        }
      });

      test('should validate translation consistency', () {
        final keys = ['good_morning', 'good_afternoon', 'good_evening', 'default_user'];
        
        for (final key in keys) {
          final english = LocalizationHelper.translate(key, language: 'en');
          final arabic = LocalizationHelper.translate(key, language: 'ar');
          
          expect(english, isNotNull);
          expect(arabic, isNotNull);
          expect(english, isNotEmpty);
          expect(arabic, isNotEmpty);
          expect(english, isNot(equals(arabic)));
          
          print('$key: EN="$english" | AR="$arabic"');
        }
      });

      test('should handle language-specific punctuation correctly', () async {
        final testTime = DateTime(2024, 1, 1, 10, 0);
        
        final englishGreeting = LocalizationHelper.getPersonalizedGreeting(
          'Ahmed',
          testTime.hour,
          language: 'en',
        );
        
        final arabicGreeting = LocalizationHelper.getPersonalizedGreeting(
          'Ahmed',
          testTime.hour,
          language: 'ar',
        );
        
        // English should use comma: "Good morning, Ahmed!"
        expect(englishGreeting, matches(RegExp(r'Good morning, Ahmed!')));
        
        // Arabic should use Arabic comma: "صباح الخير، Ahmed!"
        expect(arabicGreeting, matches(RegExp(r'صباح الخير، Ahmed!')));
        
        print('EN punctuation: $englishGreeting');
        print('AR punctuation: $arabicGreeting');
      });
    });

    group('Performance and Memory Tests', () {
      test('should handle multiple concurrent language operations', () async {
        final futures = List.generate(20, (index) async {
          final lang = index.isEven ? 'en' : 'ar';
          final hour = 6 + (index % 12);
          
          return GreetingHelper.getGreetingWithFallback(
            currentTime: DateTime(2024, 1, 1, hour, 0),
            userName: 'User$index',
            language: lang,
          );
        });
        
        final results = await Future.wait(futures);
        
        expect(results.length, equals(20));
        
        for (int i = 0; i < results.length; i++) {
          expect(results[i], isNotNull);
          expect(results[i], isNotEmpty);
          
          if (i.isEven) {
            expect(results[i], contains('Good'));
          } else {
            expect(results[i], anyOf([contains('الخير'), contains('مساء')]));
          }
        }
        
        print('Concurrent language operations completed: ${results.length} results');
      });
    });
  });
}