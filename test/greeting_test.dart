import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dabbler/core/services/greeting_service.dart';

void main() {
  group('GreetingService Tests', () {
    late GreetingService greetingService;
    bool initialized = false;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      if (!initialized) {
        await Supabase.initialize(url: 'http://localhost:54321', anonKey: 'test-anon-key');
        initialized = true;
      }
      greetingService = GreetingService();
    });

    test('should return personalized greeting with user name', () {
      // Test with a specific time and user name
      final testTime = DateTime(2024, 1, 1, 8, 0); // 8:00 AM
      final greeting = greetingService.getGreetingForTime(
        testTime,
        userName: 'John',
        language: 'en',
      );
      
      expect(greeting, contains('John'));
      expect(greeting, contains('Good morning'));
    });

    test('should return fallback greeting when no name provided', () {
      final testTime = DateTime(2024, 1, 1, 14, 0); // 2:00 PM
      final greeting = greetingService.getGreetingForTime(
        testTime,
        userName: '',
        language: 'en',
      );
      
      expect(greeting, contains('Good afternoon'));
      expect(greeting, isNot(contains('John')));
    });

    test('should return different greetings for different times', () {
      final morningTime = DateTime(2024, 1, 1, 8, 0);
      final afternoonTime = DateTime(2024, 1, 1, 14, 0);
      final eveningTime = DateTime(2024, 1, 1, 19, 0);
      final nightTime = DateTime(2024, 1, 1, 23, 0);

  final morningGreeting = greetingService.getGreetingForTime(morningTime, userName: '');
  final afternoonGreeting = greetingService.getGreetingForTime(afternoonTime, userName: '');
  final eveningGreeting = greetingService.getGreetingForTime(eveningTime, userName: '');
  final nightGreeting = greetingService.getGreetingForTime(nightTime, userName: '');

      expect(morningGreeting, contains('morning'));
      expect(afternoonGreeting, contains('afternoon'));
      expect(eveningGreeting, contains('evening'));
      expect(nightGreeting, contains('evening')); // Night uses evening greeting
    });

    test('should return Arabic greetings when language is ar', () {
      final testTime = DateTime(2024, 1, 1, 8, 0);
      final greeting = greetingService.getGreetingForTime(
        testTime,
        userName: 'أحمد',
        language: 'ar',
      );
      
      expect(greeting, contains('صباح'));
    });

    test('should return available tones', () {
      final tones = greetingService.getAvailableTones();
      expect(tones, contains('formal'));
      expect(tones, contains('casual'));
      expect(tones, contains('friendly'));
      expect(tones, contains('energetic'));
    });

    test('should return available languages', () {
      final languages = greetingService.getAvailableLanguages();
      expect(languages, contains('en'));
      expect(languages, contains('ar'));
    });

    test('should return greeting preview for different times', () {
      final previews = greetingService.getGreetingPreview('John', 'en');
      
      expect(previews, contains('morning'));
      expect(previews, contains('afternoon'));
      expect(previews, contains('evening'));
      expect(previews, contains('night'));
      
      expect(previews['morning'], contains('John'));
      expect(previews['afternoon'], contains('John'));
    });
  });
} 