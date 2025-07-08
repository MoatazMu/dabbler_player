import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dabbler/core/utils/greeting_helper.dart';
import 'package:dabbler/core/utils/user_preferences.dart';
import 'package:dabbler/core/utils/localization_helper.dart';

void main() {
  group('Fallback States Tests - User Name Validation', () {
    setUp(() async {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    group('No Name Scenarios', () {
      test('should handle null name gracefully without crashing', () async {
        final greeting = await GreetingHelper.getGreetingWithFallback(
          currentTime: DateTime(2024, 1, 1, 9, 0), // 9 AM
          userName: null,
          language: 'en',
        );

        expect(greeting, isNotNull);
        expect(greeting, contains('Good morning'));
        expect(greeting, contains('Player')); // Default fallback name
        print('Null name test: $greeting');
      });

      test('should handle empty string name gracefully without crashing', () async {
        final greeting = await GreetingHelper.getGreetingWithFallback(
          currentTime: DateTime(2024, 1, 1, 14, 0), // 2 PM
          userName: '',
          language: 'en',
        );

        expect(greeting, isNotNull);
        expect(greeting, contains('Good afternoon'));
        expect(greeting, contains('Player')); // Default fallback name
        print('Empty name test: $greeting');
      });

      test('should handle whitespace-only name gracefully without crashing', () async {
        final greeting = await GreetingHelper.getGreetingWithFallback(
          currentTime: DateTime(2024, 1, 1, 20, 0), // 8 PM
          userName: '   ',
          language: 'en',
        );

        expect(greeting, isNotNull);
        expect(greeting, contains('Good evening'));
        expect(greeting, contains('Player')); // Default fallback name
        print('Whitespace name test: $greeting');
      });

      test('should handle missing stored name without crashing', () async {
        // Ensure no name is stored
        await UserPreferences.setUserName(null);

        final greeting = await GreetingHelper.getGreetingWithFallback(
          currentTime: DateTime(2024, 1, 1, 10, 0), // 10 AM
          language: 'en',
        );

        expect(greeting, isNotNull);
        expect(greeting, contains('Good morning'));
        expect(greeting, contains('Player')); // Default fallback name
        print('No stored name test: $greeting');
      });
    });

    group('Invalid Name Scenarios', () {
      test('should handle too short name (single character) without crashing', () async {
        final greeting = await GreetingHelper.getGreetingWithFallback(
          currentTime: DateTime(2024, 1, 1, 9, 0), // 9 AM
          userName: 'A',
          language: 'en',
        );

        expect(greeting, isNotNull);
        expect(greeting, contains('Good morning'));
        expect(greeting, contains('Player')); // Should fallback to default
        print('Too short name test: $greeting');
      });

      test('should handle too long name without crashing', () async {
        final longName = 'A' * 60; // 60 characters, exceeds limit
        final greeting = await GreetingHelper.getGreetingWithFallback(
          currentTime: DateTime(2024, 1, 1, 15, 0), // 3 PM
          userName: longName,
          language: 'en',
        );

        expect(greeting, isNotNull);
        expect(greeting, contains('Good afternoon'));
        expect(greeting, contains('Player')); // Should fallback to default
        print('Too long name test: $greeting');
      });

      test('should handle name with invalid characters without crashing', () async {
        final greeting = await GreetingHelper.getGreetingWithFallback(
          currentTime: DateTime(2024, 1, 1, 21, 0), // 9 PM
          userName: '!@#\$%^&*()',
          language: 'en',
        );

        expect(greeting, isNotNull);
        expect(greeting, contains('Good evening'));
        expect(greeting, contains('Player')); // Should fallback to default
        print('Invalid characters test: $greeting');
      });

      test('should handle name with numbers only without crashing', () async {
        final greeting = await GreetingHelper.getGreetingWithFallback(
          currentTime: DateTime(2024, 1, 1, 12, 0), // 12 PM
          userName: '12345',
          language: 'en',
        );

        expect(greeting, isNotNull);
        expect(greeting, contains('Good afternoon'));
        expect(greeting, contains('Player')); // Should fallback to default
        print('Numbers only test: $greeting');
      });

      test('should handle name with mixed invalid content without crashing', () async {
        final greeting = await GreetingHelper.getGreetingWithFallback(
          currentTime: DateTime(2024, 1, 1, 18, 0), // 6 PM
          userName: '123!@#ABC',
          language: 'en',
        );

        expect(greeting, isNotNull);
        expect(greeting, contains('Good evening'));
        expect(greeting, contains('Player')); // Should fallback to default
        print('Mixed invalid content test: $greeting');
      });
    });

    group('Default Message Validation', () {
      test('should always return proper default message structure', () async {
        final testCases = [
          {'name': null, 'time': 8, 'expected': 'Good morning'},
          {'name': '', 'time': 14, 'expected': 'Good afternoon'},
          {'name': '   ', 'time': 20, 'expected': 'Good evening'},
          {'name': 'A', 'time': 6, 'expected': 'Good morning'},
          {'name': '!@#', 'time': 16, 'expected': 'Good afternoon'},
        ];

        for (final testCase in testCases) {
          final greeting = await GreetingHelper.getGreetingWithFallback(
            currentTime: DateTime(2024, 1, 1, testCase['time'] as int, 0),
            userName: testCase['name'] as String?,
            language: 'en',
          );

          expect(greeting, isNotNull);
          expect(greeting, contains(testCase['expected'] as String));
          expect(greeting, contains('Player'));
          expect(greeting, matches(RegExp(r'^Good (morning|afternoon|evening), Player!$')));
          
          print('Default message test (${testCase['name']}, ${testCase['time']}h): $greeting');
        }
      });

      test('should return proper Arabic default messages', () async {
        final testCases = [
          {'name': null, 'time': 8, 'expected': 'صباح الخير'},
          {'name': '', 'time': 14, 'expected': 'مساء الخير'},
          {'name': '   ', 'time': 20, 'expected': 'مساء الخير'},
        ];

        for (final testCase in testCases) {
          final greeting = await GreetingHelper.getGreetingWithFallback(
            currentTime: DateTime(2024, 1, 1, testCase['time'] as int, 0),
            userName: testCase['name'] as String?,
            language: 'ar',
          );

          expect(greeting, isNotNull);
          expect(greeting, contains(testCase['expected'] as String));
          expect(greeting, contains('لاعب')); // Default 'Player' in Arabic
          
          print('Arabic default message test (${testCase['name']}, ${testCase['time']}h): $greeting');
        }
      });
    });

    group('Error Handling and Crash Prevention', () {
      test('should handle concurrent access gracefully', () async {
        final futures = List.generate(10, (index) async {
          return GreetingHelper.getGreetingWithFallback(
            currentTime: DateTime(2024, 1, 1, 9 + index, 0),
            userName: index.isEven ? null : 'User$index',
            language: index.isOdd ? 'ar' : 'en',
          );
        });

        final results = await Future.wait(futures);
        
        for (final result in results) {
          expect(result, isNotNull);
          expect(result, isNotEmpty);
        }
        
        print('Concurrent access test completed with ${results.length} results');
      });

      test('should handle SharedPreferences errors gracefully', () async {
        // This test simulates SharedPreferences failure
        try {
          final greeting = await GreetingHelper.getGreetingWithFallback(
            currentTime: DateTime(2024, 1, 1, 10, 0),
            userName: 'Test User',
            language: 'en',
          );

          expect(greeting, isNotNull);
          expect(greeting, contains('Good morning'));
          print('SharedPreferences error handling test: $greeting');
        } catch (e) {
          fail('Should not throw exception even with SharedPreferences errors: $e');
        }
      });

      test('should handle unexpected language codes gracefully', () async {
        final greeting = await GreetingHelper.getGreetingWithFallback(
          currentTime: DateTime(2024, 1, 1, 15, 0),
          userName: 'Test User',
          language: 'xyz', // Invalid language code
        );

        expect(greeting, isNotNull);
        expect(greeting, contains('Good afternoon')); // Should fallback to English
        print('Invalid language code test: $greeting');
      });

      test('should handle extreme date/time values gracefully', () async {
        final extremeCases = [
          DateTime(1970, 1, 1, 0, 0), // Unix epoch
          DateTime(2100, 12, 31, 23, 59), // Far future
          DateTime(2024, 2, 29, 12, 0), // Leap year
        ];

        for (final extremeTime in extremeCases) {
          final greeting = await GreetingHelper.getGreetingWithFallback(
            currentTime: extremeTime,
            userName: null,
            language: 'en',
          );

          expect(greeting, isNotNull);
          expect(greeting, isNotEmpty);
          print('Extreme time test (${extremeTime.toString()}): $greeting');
        }
      });
    });

    group('Comprehensive User State Testing', () {
      test('should test all user states systematically', () async {
        final userStates = await GreetingHelper.testUserStates(
          currentTime: DateTime(2024, 1, 1, 10, 0), // 10 AM
          language: 'en',
        );

        // Verify all expected states are tested
        final expectedStates = [
          'valid_name',
          'empty_name',
          'null_name',
          'invalid_short',
          'invalid_long',
          'invalid_special',
          'spaces_only',
        ];

        for (final state in expectedStates) {
          expect(userStates.containsKey(state), isTrue, reason: 'Missing test for state: $state');
          expect(userStates[state], isNotNull, reason: 'Null result for state: $state');
          expect(userStates[state]!, isNotEmpty, reason: 'Empty result for state: $state');
        }

        // Verify valid name shows the actual name
        expect(userStates['valid_name']!, contains('Ahmed Ali'));
        
        // Verify all invalid states fall back to default
        final invalidStates = ['empty_name', 'null_name', 'invalid_short', 'invalid_long', 'invalid_special', 'spaces_only'];
        for (final state in invalidStates) {
          expect(userStates[state]!, contains('Player'), reason: 'Invalid state $state should use default name');
        }

        print('\n=== COMPREHENSIVE USER STATE TEST RESULTS ===');
        userStates.forEach((state, greeting) {
          print('$state: $greeting');
        });
      });

      test('should test user states in Arabic', () async {
        final userStates = await GreetingHelper.testUserStates(
          currentTime: DateTime(2024, 1, 1, 15, 0), // 3 PM
          language: 'ar',
        );

        // Verify all results are in Arabic
        for (final greeting in userStates.values) {
          expect(greeting, contains('مساء الخير')); // Good afternoon in Arabic
        }

        // Verify valid name shows the actual name
        expect(userStates['valid_name']!, contains('Ahmed Ali'));
        
        // Verify all invalid states fall back to Arabic default
        final invalidStates = ['empty_name', 'null_name', 'invalid_short', 'invalid_long', 'invalid_special', 'spaces_only'];
        for (final state in invalidStates) {
          expect(userStates[state]!, contains('لاعب'), reason: 'Invalid state $state should use Arabic default name');
        }

        print('\n=== ARABIC USER STATE TEST RESULTS ===');
        userStates.forEach((state, greeting) {
          print('$state: $greeting');
        });
      });
    });

    group('Welcome Message Fallback Tests', () {
      test('should handle welcome message fallbacks correctly', () async {
        final testCases = [
          {'name': null, 'time': 7},
          {'name': '', 'time': 13},
          {'name': '!@#', 'time': 19},
        ];

        for (final testCase in testCases) {
          final welcomeMessage = await GreetingHelper.getWelcomeMessageWithFallback(
            currentTime: DateTime(2024, 1, 1, testCase['time'] as int, 0),
            userName: testCase['name'] as String?,
            language: 'en',
          );

          expect(welcomeMessage, isNotNull);
          expect(welcomeMessage, isNotEmpty);
          expect(welcomeMessage, contains('Player'));
          expect(welcomeMessage, anyOf([contains('sports'), contains('game')]));
          
          print('Welcome message fallback test (${testCase['name']}, ${testCase['time']}h): $welcomeMessage');
        }
      });
    });
  });
}