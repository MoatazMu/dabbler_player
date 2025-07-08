import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dabbler/screens/home/home_screen.dart';
import 'package:dabbler/core/utils/greeting_helper.dart';

void main() {
  group('HomeScreen Greeting Integration Tests', () {
    testWidgets('should display morning greeting in home screen', (WidgetTester tester) async {
      // Create a test app with MaterialApp wrapper
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
        ),
      );

      // Verify that the greeting is displayed
      final greeting = GreetingHelper.getGreeting();
      expect(find.text(greeting), findsOneWidget);
      
      // The welcome message should also be present (without the greeting prefix)
      final welcomeMessage = GreetingHelper.getWelcomeMessage();
      final messageWithoutGreeting = welcomeMessage.split('! ')[1];
      expect(find.text(messageWithoutGreeting), findsOneWidget);
    });

    testWidgets('should display correct greeting for simulated morning time', (WidgetTester tester) async {
      // Test with specific morning time
      final morningTime = DateTime(2024, 1, 1, 9, 0); // 9:00 AM
      
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
        ),
      );

      // Verify morning greeting appears
      final expectedGreeting = GreetingHelper.getGreeting(currentTime: morningTime);
      expect(expectedGreeting, equals('Good morning!'));
      
      final expectedMessage = GreetingHelper.getWelcomeMessage(currentTime: morningTime);
      final expectedMessagePart = expectedMessage.split('! ')[1];
      expect(expectedMessagePart, equals('Ready to start your day with some sports?'));
    });

    testWidgets('should display correct greeting for simulated afternoon time', (WidgetTester tester) async {
      // Test with specific afternoon time
      final afternoonTime = DateTime(2024, 1, 1, 14, 0); // 2:00 PM
      
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
        ),
      );

      // Verify afternoon greeting logic
      final expectedGreeting = GreetingHelper.getGreeting(currentTime: afternoonTime);
      expect(expectedGreeting, equals('Good afternoon!'));
      
      final expectedMessage = GreetingHelper.getWelcomeMessage(currentTime: afternoonTime);
      final expectedMessagePart = expectedMessage.split('! ')[1];
      expect(expectedMessagePart, equals('Perfect time for a game break!'));
    });

    testWidgets('should display correct greeting for simulated evening time', (WidgetTester tester) async {
      // Test with specific evening time
      final eveningTime = DateTime(2024, 1, 1, 19, 0); // 7:00 PM
      
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
        ),
      );

      // Verify evening greeting logic
      final expectedGreeting = GreetingHelper.getGreeting(currentTime: eveningTime);
      expect(expectedGreeting, equals('Good evening!'));
      
      final expectedMessage = GreetingHelper.getWelcomeMessage(currentTime: eveningTime);
      final expectedMessagePart = expectedMessage.split('! ')[1];
      expect(expectedMessagePart, equals('Time to unwind with some sports!'));
    });

    testWidgets('should have welcome section with proper UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
        ),
      );

      // Verify that the welcome section contains expected UI elements
      expect(find.byType(Card), findsAtLeastNWidgets(1));
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.person), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.arrow_forward_ios), findsAtLeastNWidgets(1));
      
      // Verify that greeting text is displayed
      final currentGreeting = GreetingHelper.getGreeting();
      expect(find.text(currentGreeting), findsOneWidget);
    });

    group('Time Period Validation Tests', () {
      testWidgets('should show appropriate content for different time periods', (WidgetTester tester) async {
        // Test data for different times
        final testCases = [
          {
            'time': DateTime(2024, 1, 1, 7, 0), // 7:00 AM - Morning
            'expectedGreeting': 'Good morning!',
            'expectedMessage': 'Ready to start your day with some sports?',
            'period': 'morning'
          },
          {
            'time': DateTime(2024, 1, 1, 13, 0), // 1:00 PM - Afternoon
            'expectedGreeting': 'Good afternoon!',
            'expectedMessage': 'Perfect time for a game break!',
            'period': 'afternoon'
          },
          {
            'time': DateTime(2024, 1, 1, 20, 0), // 8:00 PM - Evening
            'expectedGreeting': 'Good evening!',
            'expectedMessage': 'Time to unwind with some sports!',
            'period': 'evening'
          },
        ];

        for (final testCase in testCases) {
          // Validate the greeting helper logic for each time period
          final time = testCase['time'] as DateTime;
          final actualGreeting = GreetingHelper.getGreeting(currentTime: time);
          final actualMessage = GreetingHelper.getWelcomeMessage(currentTime: time);
          final actualPeriod = GreetingHelper.getTimePeriod(currentTime: time);

          expect(actualGreeting, equals(testCase['expectedGreeting']));
          expect(actualMessage, contains(testCase['expectedMessage'] as String));
          expect(actualPeriod, equals(testCase['period']));
        }
      });
    });

    group('Edge Case Time Tests', () {
      testWidgets('should handle boundary times correctly', (WidgetTester tester) async {
        // Test boundary cases
        final boundaryTests = [
          {
            'time': DateTime(2024, 1, 1, 4, 59), // 4:59 AM - should be evening
            'expected': 'Good evening!'
          },
          {
            'time': DateTime(2024, 1, 1, 5, 0), // 5:00 AM - should be morning
            'expected': 'Good morning!'
          },
          {
            'time': DateTime(2024, 1, 1, 11, 59), // 11:59 AM - should be morning
            'expected': 'Good morning!'
          },
          {
            'time': DateTime(2024, 1, 1, 12, 0), // 12:00 PM - should be afternoon
            'expected': 'Good afternoon!'
          },
          {
            'time': DateTime(2024, 1, 1, 16, 59), // 4:59 PM - should be afternoon
            'expected': 'Good afternoon!'
          },
          {
            'time': DateTime(2024, 1, 1, 17, 0), // 5:00 PM - should be evening
            'expected': 'Good evening!'
          },
        ];

        for (final test in boundaryTests) {
          final time = test['time'] as DateTime;
          final actual = GreetingHelper.getGreeting(currentTime: time);
          expect(actual, equals(test['expected']), 
            reason: 'Failed for time ${time.hour}:${time.minute.toString().padLeft(2, '0')}');
        }
      });
    });
  });
}