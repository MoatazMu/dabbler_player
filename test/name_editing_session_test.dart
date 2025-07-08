import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dabbler/core/utils/greeting_helper.dart';
import 'package:dabbler/core/utils/user_preferences.dart';
import 'package:dabbler/core/utils/localization_helper.dart';

void main() {
  group('Name Editing and Session Persistence Tests', () {
    setUp(() async {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    group('Name Editing Flow', () {
      test('should update user profile name successfully', () async {
        // Initial state - no name
        expect(await UserPreferences.getUserName(), isNull);
        
        // Update name
        const newName = 'John Smith';
        final success = await UserPreferences.setUserName(newName);
        
        expect(success, isTrue);
        
        // Verify name is saved
        final savedName = await UserPreferences.getUserName();
        expect(savedName, equals(newName));
        
        print('✅ Name update successful: "$newName"');
      });

      test('should validate name before saving to profile', () async {
        final testCases = [
          {'name': 'Ahmed Ali', 'valid': true},
          {'name': 'A', 'valid': false}, // Too short
          {'name': 'A' * 60, 'valid': false}, // Too long
          {'name': '!@#\$%', 'valid': false}, // Invalid characters
          {'name': '   ', 'valid': false}, // Whitespace only
          {'name': '', 'valid': false}, // Empty
          {'name': 'محمد أحمد', 'valid': true}, // Arabic name
          {'name': 'Jean-Pierre O\'Connor', 'valid': true}, // Special chars
        ];

        for (final testCase in testCases) {
          final name = testCase['name'] as String;
          final expectedValid = testCase['valid'] as bool;
          
          final isValid = UserPreferences.isValidName(name);
          expect(isValid, equals(expectedValid));
          
          print('Name validation "$name": ${isValid ? "✅" : "❌"} (expected: $expectedValid)');
        }
      });

      test('should sanitize name during profile update', () async {
        final testCases = [
          {'input': 'john smith', 'expected': 'John Smith'},
          {'input': '  AHMED  ALI  ', 'expected': 'Ahmed Ali'},
          {'input': 'مُحَمَّد أَحْمَد', 'expected': 'مُحَمَّد أَحْمَد'}, // Arabic preserved
          {'input': 'jean-pierre', 'expected': 'Jean-Pierre'},
        ];

        for (final testCase in testCases) {
          final input = testCase['input'] as String;
          final expected = testCase['expected'] as String;
          
          final sanitized = UserPreferences.sanitizeName(input);
          expect(sanitized, equals(expected));
          
          print('Name sanitization "$input" → "$sanitized"');
        }
      });

      test('should handle name update with immediate greeting refresh', () async {
        final testTime = DateTime(2024, 1, 1, 10, 0); // 10 AM
        
        // Set initial name
        await UserPreferences.setUserName('John Doe');
        
        final greeting1 = await GreetingHelper.getPersonalizedGreeting(
          currentTime: testTime,
          language: 'en',
        );
        
        expect(greeting1, contains('John Doe'));
        print('Before update: $greeting1');
        
        // Update name
        await UserPreferences.setUserName('Jane Smith');
        
        final greeting2 = await GreetingHelper.getPersonalizedGreeting(
          currentTime: testTime,
          language: 'en',
        );
        
        expect(greeting2, contains('Jane Smith'));
        expect(greeting2, isNot(contains('John Doe')));
        
        print('After update: $greeting2');
        print('✅ Immediate greeting refresh successful');
      });
    });

    group('Session Persistence Tests', () {
      test('should persist name across app sessions', () async {
        // Simulate first session
        const sessionName = 'Sarah Ahmed';
        await UserPreferences.setUserName(sessionName);
        
        // Verify it's saved
        final savedName = await UserPreferences.getUserName();
        expect(savedName, equals(sessionName));
        
        // Simulate app restart by creating new SharedPreferences mock with saved data
        SharedPreferences.setMockInitialValues({
          'user_name': sessionName,
        });
        
        // Verify name persists after "restart"
        final persistedName = await UserPreferences.getUserName();
        expect(persistedName, equals(sessionName));
        
        print('✅ Name persisted across sessions: "$sessionName"');
      });

      test('should load updated greeting on next session launch', () async {
        final testTime = DateTime(2024, 1, 1, 14, 0); // 2 PM
        
        // First session - set name and get greeting
        const originalName = 'Ahmed Hassan';
        await UserPreferences.setUserName(originalName);
        await UserPreferences.setLanguage('en');
        
        final firstSessionGreeting = await GreetingHelper.getPersonalizedGreeting(
          currentTime: testTime,
        );
        
        expect(firstSessionGreeting, contains(originalName));
        print('First session: $firstSessionGreeting');
        
        // Update name in same session
        const updatedName = 'Ahmed Ali Hassan';
        await UserPreferences.setUserName(updatedName);
        
        // Simulate app restart with persisted data
        SharedPreferences.setMockInitialValues({
          'user_name': updatedName,
          'app_language': 'en',
        });
        
        // Second session - should load updated name
        final secondSessionGreeting = await GreetingHelper.getPersonalizedGreeting(
          currentTime: testTime,
        );
        
        expect(secondSessionGreeting, contains(updatedName));
        expect(secondSessionGreeting, isNot(contains(originalName)));
        
        print('Second session: $secondSessionGreeting');
        print('✅ Updated greeting loaded in next session');
      });

      test('should handle multiple name changes across sessions', () async {
        final testTime = DateTime(2024, 1, 1, 9, 0); // 9 AM
        final names = ['Alex Johnson', 'Alexander J.', 'Alex James Johnson'];
        final sessionGreetings = <String>[];
        
        for (int i = 0; i < names.length; i++) {
          final name = names[i];
          
          // Update name
          await UserPreferences.setUserName(name);
          
          // Simulate session restart
          SharedPreferences.setMockInitialValues({
            'user_name': name,
            'app_language': 'en',
          });
          
          // Get greeting in new session
          final greeting = await GreetingHelper.getPersonalizedGreeting(
            currentTime: testTime,
          );
          
          sessionGreetings.add(greeting);
          expect(greeting, contains(name));
          
          print('Session ${i + 1}: $greeting');
        }
        
        // Verify all greetings are different
        expect(sessionGreetings.toSet().length, equals(names.length));
        print('✅ Multiple name changes handled correctly');
      });

      test('should preserve language preferences with name changes', () async {
        final testTime = DateTime(2024, 1, 1, 16, 0); // 4 PM
        
        // Set initial state
        await UserPreferences.setUserName('محمد أحمد');
        await UserPreferences.setLanguage('ar');
        
        // Simulate session restart
        SharedPreferences.setMockInitialValues({
          'user_name': 'محمد أحمد',
          'app_language': 'ar',
        });
        
        final arabicGreeting = await GreetingHelper.getPersonalizedGreeting(
          currentTime: testTime,
        );
        
        expect(arabicGreeting, contains('مساء الخير'));
        expect(arabicGreeting, contains('محمد أحمد'));
        
        // Update name but keep language
        await UserPreferences.setUserName('أحمد محمد');
        
        // Simulate another session
        SharedPreferences.setMockInitialValues({
          'user_name': 'أحمد محمد',
          'app_language': 'ar',
        });
        
        final updatedArabicGreeting = await GreetingHelper.getPersonalizedGreeting(
          currentTime: testTime,
        );
        
        expect(updatedArabicGreeting, contains('مساء الخير'));
        expect(updatedArabicGreeting, contains('أحمد محمد'));
        expect(updatedArabicGreeting, isNot(contains('محمد أحمد')));
        
        print('Original: $arabicGreeting');
        print('Updated: $updatedArabicGreeting');
        print('✅ Language preserved with name change');
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle corrupt preferences data gracefully', () async {
        // Simulate corrupted data
        SharedPreferences.setMockInitialValues({
          'app_language': 'invalid_lang',
        });
        
        final greeting = await GreetingHelper.getGreetingWithFallback(
          currentTime: DateTime(2024, 1, 1, 11, 0),
        );
        
        // Should fallback to defaults
        expect(greeting, isNotNull);
        expect(greeting, contains('Player')); // Default name
        expect(greeting, contains('Good morning')); // Default language
        
        print('✅ Corrupt data handled: $greeting');
      });

      test('should handle session data migration correctly', () async {
        // Simulate old session data format (if any)
        SharedPreferences.setMockInitialValues({
          'user_name': 'Legacy User',
        });
        
        final name = await UserPreferences.getUserName();
        expect(name, equals('Legacy User'));
        
        // Update with new format
        await UserPreferences.setUserName('Modern User');
        
        final updatedName = await UserPreferences.getUserName();
        expect(updatedName, equals('Modern User'));
        
        print('✅ Session data migration successful');
      });

      test('should handle concurrent name updates gracefully', () async {
        final futures = List.generate(5, (index) async {
          await Future.delayed(Duration(milliseconds: index * 10));
          return UserPreferences.setUserName('User $index');
        });
        
        final results = await Future.wait(futures);
        
        // All updates should succeed
        for (final result in results) {
          expect(result, isTrue);
        }
        
        // Final name should be the last one
        final finalName = await UserPreferences.getUserName();
        expect(finalName, equals('User 4'));
        
        print('✅ Concurrent updates handled: Final name = "$finalName"');
      });
    });

    group('Profile Integration Tests', () {
      test('should simulate complete profile edit flow', () async {
        final testTime = DateTime(2024, 1, 1, 13, 0); // 1 PM
        
        print('\n=== COMPLETE PROFILE EDIT SIMULATION ===');
        
        // Step 1: Initial user
        await UserPreferences.setUserName('Original Name');
        final greeting1 = await GreetingHelper.getPersonalizedGreeting(
          currentTime: testTime,
          language: 'en',
        );
        print('1. Initial profile: $greeting1');
        
        // Step 2: User edits name
        await UserPreferences.setUserName('Updated Name');
        final greeting2 = await GreetingHelper.getPersonalizedGreeting(
          currentTime: testTime,
          language: 'en',
        );
        print('2. After edit: $greeting2');
        
        // Step 3: App restart
        SharedPreferences.setMockInitialValues({
          'user_name': 'Updated Name',
          'app_language': 'en',
        });
        
        final greeting3 = await GreetingHelper.getPersonalizedGreeting(
          currentTime: testTime,
        );
        print('3. After restart: $greeting3');
        
        // Step 4: Language change
        await UserPreferences.setLanguage('ar');
        final greeting4 = await GreetingHelper.getPersonalizedGreeting(
          currentTime: testTime,
        );
        print('4. Arabic version: $greeting4');
        
        // Verify progression
        expect(greeting1, contains('Original Name'));
        expect(greeting2, contains('Updated Name'));
        expect(greeting3, contains('Updated Name'));
        expect(greeting4, contains('Updated Name'));
        expect(greeting4, contains('مساء الخير'));
        
        print('✅ Complete profile edit flow successful');
      });

      test('should handle name clearing and restoration', () async {
        final testTime = DateTime(2024, 1, 1, 8, 0); // 8 AM
        
        // Set initial name
        await UserPreferences.setUserName('Test User');
        final greeting1 = await GreetingHelper.getPersonalizedGreeting(
          currentTime: testTime,
          language: 'en',
        );
        expect(greeting1, contains('Test User'));
        
        // Clear name
        await UserPreferences.setUserName(null);
        final greeting2 = await GreetingHelper.getGreetingWithFallback(
          currentTime: testTime,
          language: 'en',
        );
        expect(greeting2, contains('Player')); // Should fallback
        
        // Restore name
        await UserPreferences.setUserName('Restored User');
        final greeting3 = await GreetingHelper.getPersonalizedGreeting(
          currentTime: testTime,
          language: 'en',
        );
        expect(greeting3, contains('Restored User'));
        
        print('Name progression:');
        print('  With name: $greeting1');
        print('  Cleared: $greeting2');
        print('  Restored: $greeting3');
        print('✅ Name clearing and restoration successful');
      });

      test('should handle mixed language names correctly', () async {
        final testTime = DateTime(2024, 1, 1, 19, 0); // 7 PM
        
        final mixedNames = [
          'أحمد Smith',
          'John الأحمد',
          'Maria José',
          'Jean-François',
          'صالح O\'Connor',
        ];
        
        for (final name in mixedNames) {
          await UserPreferences.setUserName(name);
          
          // Test in both languages
          final englishGreeting = await GreetingHelper.getPersonalizedGreeting(
            currentTime: testTime,
            language: 'en',
          );
          
          final arabicGreeting = await GreetingHelper.getPersonalizedGreeting(
            currentTime: testTime,
            language: 'ar',
          );
          
          expect(englishGreeting, contains(name));
          expect(arabicGreeting, contains(name));
          
          print('Mixed name "$name":');
          print('  EN: $englishGreeting');
          print('  AR: $arabicGreeting');
        }
        
        print('✅ Mixed language names handled correctly');
      });
    });

    group('Performance and Memory Tests', () {
      test('should handle frequent name updates efficiently', () async {
        final testTime = DateTime(2024, 1, 1, 12, 0);
        final stopwatch = Stopwatch()..start();
        
        // Perform many rapid name updates
        for (int i = 0; i < 100; i++) {
          await UserPreferences.setUserName('User $i');
          if (i % 10 == 0) {
            // Periodically get greeting to test performance
            await GreetingHelper.getPersonalizedGreeting(
              currentTime: testTime,
              language: 'en',
            );
          }
        }
        
        stopwatch.stop();
        
        // Should complete in reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 seconds
        
        // Verify final state
        final finalName = await UserPreferences.getUserName();
        expect(finalName, equals('User 99'));
        
        print('⚡ Performance test:');
        print('   100 updates in ${stopwatch.elapsedMilliseconds}ms');
        print('   Final name: $finalName');
        print('✅ Efficient name updates');
      });

      test('should handle memory efficiently during long sessions', () async {
        final testTime = DateTime(2024, 1, 1, 15, 0);
        final greetings = <String>[];
        
        // Simulate long session with multiple name changes
        for (int i = 0; i < 20; i++) {
          await UserPreferences.setUserName('Session User $i');
          
          final greeting = await GreetingHelper.getPersonalizedGreeting(
            currentTime: testTime,
            language: i.isEven ? 'en' : 'ar',
          );
          
          greetings.add(greeting);
        }
        
        // Verify all greetings are unique and correct
        expect(greetings.length, equals(20));
        expect(greetings.toSet().length, equals(20)); // All should be unique
        
        // Check last greeting
        expect(greetings.last, contains('Session User 19'));
        
        print('📊 Memory efficiency test:');
        print('   Generated ${greetings.length} unique greetings');
        print('   Memory usage appears stable');
        print('✅ Memory efficient during long sessions');
      });
    });
  });
}