import 'package:flutter_test/flutter_test.dart';
import 'package:dabbler/core/utils/greeting_helper.dart';

void main() {
  group('GreetingHelper Tests', () {
    group('getGreeting()', () {
      test('should return "Good morning!" for morning hours (5:00-11:59)', () {
        // Test early morning
        var morningTime = DateTime(2024, 1, 1, 6, 0); // 6:00 AM
        expect(GreetingHelper.getGreeting(currentTime: morningTime), equals('Good morning!'));

        // Test late morning
        morningTime = DateTime(2024, 1, 1, 11, 30); // 11:30 AM
        expect(GreetingHelper.getGreeting(currentTime: morningTime), equals('Good morning!'));

        // Test edge case - exactly 5:00 AM
        morningTime = DateTime(2024, 1, 1, 5, 0); // 5:00 AM
        expect(GreetingHelper.getGreeting(currentTime: morningTime), equals('Good morning!'));

        // Test edge case - exactly 11:59 AM
        morningTime = DateTime(2024, 1, 1, 11, 59); // 11:59 AM
        expect(GreetingHelper.getGreeting(currentTime: morningTime), equals('Good morning!'));
      });

      test('should return "Good afternoon!" for afternoon hours (12:00-16:59)', () {
        // Test early afternoon
        var afternoonTime = DateTime(2024, 1, 1, 12, 0); // 12:00 PM
        expect(GreetingHelper.getGreeting(currentTime: afternoonTime), equals('Good afternoon!'));

        // Test mid afternoon
        afternoonTime = DateTime(2024, 1, 1, 14, 30); // 2:30 PM
        expect(GreetingHelper.getGreeting(currentTime: afternoonTime), equals('Good afternoon!'));

        // Test late afternoon
        afternoonTime = DateTime(2024, 1, 1, 16, 45); // 4:45 PM
        expect(GreetingHelper.getGreeting(currentTime: afternoonTime), equals('Good afternoon!'));

        // Test edge case - exactly 4:59 PM
        afternoonTime = DateTime(2024, 1, 1, 16, 59); // 4:59 PM
        expect(GreetingHelper.getGreeting(currentTime: afternoonTime), equals('Good afternoon!'));
      });

      test('should return "Good evening!" for evening hours (17:00-4:59)', () {
        // Test early evening
        var eveningTime = DateTime(2024, 1, 1, 17, 0); // 5:00 PM
        expect(GreetingHelper.getGreeting(currentTime: eveningTime), equals('Good evening!'));

        // Test late evening
        eveningTime = DateTime(2024, 1, 1, 22, 30); // 10:30 PM
        expect(GreetingHelper.getGreeting(currentTime: eveningTime), equals('Good evening!'));

        // Test midnight
        eveningTime = DateTime(2024, 1, 1, 0, 0); // 12:00 AM
        expect(GreetingHelper.getGreeting(currentTime: eveningTime), equals('Good evening!'));

        // Test early morning before 5 AM
        eveningTime = DateTime(2024, 1, 1, 3, 30); // 3:30 AM
        expect(GreetingHelper.getGreeting(currentTime: eveningTime), equals('Good evening!'));

        // Test edge case - exactly 4:59 AM
        eveningTime = DateTime(2024, 1, 1, 4, 59); // 4:59 AM
        expect(GreetingHelper.getGreeting(currentTime: eveningTime), equals('Good evening!'));
      });
    });

    group('getWelcomeMessage()', () {
      test('should return appropriate morning welcome message', () {
        var morningTime = DateTime(2024, 1, 1, 8, 0); // 8:00 AM
        var message = GreetingHelper.getWelcomeMessage(currentTime: morningTime);
        expect(message, equals('Good morning! Ready to start your day with some sports?'));
      });

      test('should return appropriate afternoon welcome message', () {
        var afternoonTime = DateTime(2024, 1, 1, 14, 0); // 2:00 PM
        var message = GreetingHelper.getWelcomeMessage(currentTime: afternoonTime);
        expect(message, equals('Good afternoon! Perfect time for a game break!'));
      });

      test('should return appropriate evening welcome message', () {
        var eveningTime = DateTime(2024, 1, 1, 19, 0); // 7:00 PM
        var message = GreetingHelper.getWelcomeMessage(currentTime: eveningTime);
        expect(message, equals('Good evening! Time to unwind with some sports!'));
      });
    });

    group('getTimePeriod()', () {
      test('should return "morning" for morning hours', () {
        var morningTime = DateTime(2024, 1, 1, 9, 0); // 9:00 AM
        expect(GreetingHelper.getTimePeriod(currentTime: morningTime), equals('morning'));
      });

      test('should return "afternoon" for afternoon hours', () {
        var afternoonTime = DateTime(2024, 1, 1, 15, 0); // 3:00 PM
        expect(GreetingHelper.getTimePeriod(currentTime: afternoonTime), equals('afternoon'));
      });

      test('should return "evening" for evening hours', () {
        var eveningTime = DateTime(2024, 1, 1, 20, 0); // 8:00 PM
        expect(GreetingHelper.getTimePeriod(currentTime: eveningTime), equals('evening'));
      });
    });

    group('Edge Cases and Boundary Testing', () {
      test('should handle transition from evening to morning correctly', () {
        // 4:59 AM should be evening
        var lateNight = DateTime(2024, 1, 1, 4, 59);
        expect(GreetingHelper.getGreeting(currentTime: lateNight), equals('Good evening!'));
        
        // 5:00 AM should be morning
        var earlyMorning = DateTime(2024, 1, 1, 5, 0);
        expect(GreetingHelper.getGreeting(currentTime: earlyMorning), equals('Good morning!'));
      });

      test('should handle transition from morning to afternoon correctly', () {
        // 11:59 AM should be morning
        var lateMorning = DateTime(2024, 1, 1, 11, 59);
        expect(GreetingHelper.getGreeting(currentTime: lateMorning), equals('Good morning!'));
        
        // 12:00 PM should be afternoon
        var earlyAfternoon = DateTime(2024, 1, 1, 12, 0);
        expect(GreetingHelper.getGreeting(currentTime: earlyAfternoon), equals('Good afternoon!'));
      });

      test('should handle transition from afternoon to evening correctly', () {
        // 4:59 PM should be afternoon
        var lateAfternoon = DateTime(2024, 1, 1, 16, 59);
        expect(GreetingHelper.getGreeting(currentTime: lateAfternoon), equals('Good afternoon!'));
        
        // 5:00 PM should be evening
        var earlyEvening = DateTime(2024, 1, 1, 17, 0);
        expect(GreetingHelper.getGreeting(currentTime: earlyEvening), equals('Good evening!'));
      });

      test('should work without providing currentTime parameter (uses DateTime.now())', () {
        // This test verifies that the function works when no time is provided
        var greeting = GreetingHelper.getGreeting();
        expect(greeting, isIn(['Good morning!', 'Good afternoon!', 'Good evening!']));
        
        var welcomeMessage = GreetingHelper.getWelcomeMessage();
        expect(welcomeMessage, contains('!'));
        
        var timePeriod = GreetingHelper.getTimePeriod();
        expect(timePeriod, isIn(['morning', 'afternoon', 'evening']));
      });
    });

    group('Integration Tests - Complete Day Simulation', () {
      test('should cycle through all time periods correctly in a 24-hour period', () {
        var testResults = <String, List<String>>{
          'morning': [],
          'afternoon': [],
          'evening': [],
        };

        // Test every hour in a day
        for (int hour = 0; hour < 24; hour++) {
          var testTime = DateTime(2024, 1, 1, hour, 0);
          var greeting = GreetingHelper.getGreeting(currentTime: testTime);
          var timePeriod = GreetingHelper.getTimePeriod(currentTime: testTime);
          
          testResults[timePeriod]!.add('$hour:00 - $greeting');
        }

        // Verify morning hours (5-11)
        expect(testResults['morning']!.length, equals(7)); // 5,6,7,8,9,10,11
        
        // Verify afternoon hours (12-16)
        expect(testResults['afternoon']!.length, equals(5)); // 12,13,14,15,16
        
        // Verify evening hours (0-4, 17-23)
        expect(testResults['evening']!.length, equals(12)); // 0,1,2,3,4,17,18,19,20,21,22,23

        // Print results for manual verification during testing
        print('Morning greetings: ${testResults['morning']}');
        print('Afternoon greetings: ${testResults['afternoon']}');
        print('Evening greetings: ${testResults['evening']}');
      });
    });
  });
}