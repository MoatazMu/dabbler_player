import 'package:flutter_test/flutter_test.dart';
import 'package:dabbler/core/utils/greeting_helper.dart';

void main() {
  group('Greeting Simulation Tests - Time-based Display Logic', () {
    test('Morning Greeting Simulation (5:00 AM - 11:59 AM)', () {
      print('\n=== MORNING GREETING SIMULATION ===');
      
      final morningHours = [5, 6, 7, 8, 9, 10, 11];
      
      for (final hour in morningHours) {
        final testTime = DateTime(2024, 1, 1, hour, 0);
        final greeting = GreetingHelper.getGreeting(currentTime: testTime);
        final welcomeMessage = GreetingHelper.getWelcomeMessage(currentTime: testTime);
        final timePeriod = GreetingHelper.getTimePeriod(currentTime: testTime);
        
        print('Time: ${hour.toString().padLeft(2, '0')}:00');
        print('  Greeting: $greeting');
        print('  Welcome Message: $welcomeMessage');
        print('  Time Period: $timePeriod');
        print('  ---');
        
        // Assertions
        expect(greeting, equals('Good morning!'));
        expect(welcomeMessage, equals('Good morning! Ready to start your day with some sports?'));
        expect(timePeriod, equals('morning'));
      }
      
      print('Morning simulation completed successfully!\n');
    });

    test('Afternoon Greeting Simulation (12:00 PM - 4:59 PM)', () {
      print('=== AFTERNOON GREETING SIMULATION ===');
      
      final afternoonHours = [12, 13, 14, 15, 16];
      
      for (final hour in afternoonHours) {
        final testTime = DateTime(2024, 1, 1, hour, 0);
        final greeting = GreetingHelper.getGreeting(currentTime: testTime);
        final welcomeMessage = GreetingHelper.getWelcomeMessage(currentTime: testTime);
        final timePeriod = GreetingHelper.getTimePeriod(currentTime: testTime);
        
        final displayHour = hour > 12 ? hour - 12 : hour;
        final amPm = hour >= 12 ? 'PM' : 'AM';
        
        print('Time: ${displayHour.toString().padLeft(2, '0')}:00 $amPm');
        print('  Greeting: $greeting');
        print('  Welcome Message: $welcomeMessage');
        print('  Time Period: $timePeriod');
        print('  ---');
        
        // Assertions
        expect(greeting, equals('Good afternoon!'));
        expect(welcomeMessage, equals('Good afternoon! Perfect time for a game break!'));
        expect(timePeriod, equals('afternoon'));
      }
      
      print('Afternoon simulation completed successfully!\n');
    });

    test('Evening Greeting Simulation (5:00 PM - 4:59 AM)', () {
      print('=== EVENING GREETING SIMULATION ===');
      
      // Evening hours: 17-23 (5 PM - 11 PM) and 0-4 (12 AM - 4:59 AM)
      final eveningHours = [17, 18, 19, 20, 21, 22, 23, 0, 1, 2, 3, 4];
      
      for (final hour in eveningHours) {
        final testTime = DateTime(2024, 1, 1, hour, 0);
        final greeting = GreetingHelper.getGreeting(currentTime: testTime);
        final welcomeMessage = GreetingHelper.getWelcomeMessage(currentTime: testTime);
        final timePeriod = GreetingHelper.getTimePeriod(currentTime: testTime);
        
        String displayTime;
        if (hour == 0) {
          displayTime = '12:00 AM';
        } else if (hour < 12) {
          displayTime = '${hour.toString().padLeft(2, '0')}:00 AM';
        } else if (hour == 12) {
          displayTime = '12:00 PM';
        } else {
          displayTime = '${(hour - 12).toString().padLeft(2, '0')}:00 PM';
        }
        
        print('Time: $displayTime');
        print('  Greeting: $greeting');
        print('  Welcome Message: $welcomeMessage');
        print('  Time Period: $timePeriod');
        print('  ---');
        
        // Assertions
        expect(greeting, equals('Good evening!'));
        expect(welcomeMessage, equals('Good evening! Time to unwind with some sports!'));
        expect(timePeriod, equals('evening'));
      }
      
      print('Evening simulation completed successfully!\n');
    });

    test('Boundary Time Transition Simulation', () {
      print('=== BOUNDARY TRANSITION SIMULATION ===');
      
      final boundaryTimes = [
        {'hour': 4, 'minute': 59, 'expected': 'evening', 'description': 'Last minute of evening'},
        {'hour': 5, 'minute': 0, 'expected': 'morning', 'description': 'First minute of morning'},
        {'hour': 11, 'minute': 59, 'expected': 'morning', 'description': 'Last minute of morning'},
        {'hour': 12, 'minute': 0, 'expected': 'afternoon', 'description': 'First minute of afternoon'},
        {'hour': 16, 'minute': 59, 'expected': 'afternoon', 'description': 'Last minute of afternoon'},
        {'hour': 17, 'minute': 0, 'expected': 'evening', 'description': 'First minute of evening'},
      ];
      
      for (final timeTest in boundaryTimes) {
        final hour = timeTest['hour'] as int;
        final minute = timeTest['minute'] as int;
        final expected = timeTest['expected'] as String;
        final description = timeTest['description'] as String;
        
        final testTime = DateTime(2024, 1, 1, hour, minute);
        final greeting = GreetingHelper.getGreeting(currentTime: testTime);
        final timePeriod = GreetingHelper.getTimePeriod(currentTime: testTime);
        
        String displayTime;
        if (hour == 0) {
          displayTime = '12:${minute.toString().padLeft(2, '0')} AM';
        } else if (hour < 12) {
          displayTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} AM';
        } else if (hour == 12) {
          displayTime = '12:${minute.toString().padLeft(2, '0')} PM';
        } else {
          displayTime = '${(hour - 12).toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} PM';
        }
        
        print('$description:');
        print('  Time: $displayTime');
        print('  Expected: ${expected.toUpperCase()}');
        print('  Actual Period: ${timePeriod.toUpperCase()}');
        print('  Greeting: $greeting');
        print('  Status: ${timePeriod == expected ? "✅ PASS" : "❌ FAIL"}');
        print('  ---');
        
        // Assertions
        expect(timePeriod, equals(expected));
      }
      
      print('Boundary transition simulation completed successfully!\n');
    });

    test('Complete Day Cycle Simulation (24-hour overview)', () {
      print('=== COMPLETE 24-HOUR CYCLE SIMULATION ===');
      
      final timeResults = <String, List<String>>{
        'morning': [],
        'afternoon': [],
        'evening': [],
      };
      
      print('Hour | Greeting       | Time Period | Welcome Message Preview');
      print('-----|----------------|-------------|------------------------');
      
      for (int hour = 0; hour < 24; hour++) {
        final testTime = DateTime(2024, 1, 1, hour, 0);
        final greeting = GreetingHelper.getGreeting(currentTime: testTime);
        final timePeriod = GreetingHelper.getTimePeriod(currentTime: testTime);
        final welcomeMessage = GreetingHelper.getWelcomeMessage(currentTime: testTime);
        final messagePreview = welcomeMessage.split('! ')[1].substring(0, 
          welcomeMessage.split('! ')[1].length > 20 ? 20 : welcomeMessage.split('! ')[1].length) + '...';
        
        timeResults[timePeriod]!.add('$hour:00');
        
        String displayHour;
        if (hour == 0) {
          displayHour = '12AM';
        } else if (hour < 12) {
          displayHour = '${hour}AM';
        } else if (hour == 12) {
          displayHour = '12PM';
        } else {
          displayHour = '${hour - 12}PM';
        }
        
        print('${displayHour.padRight(4)} | ${greeting.padRight(14)} | ${timePeriod.padRight(11)} | $messagePreview');
      }
      
      print('\n=== SUMMARY ===');
      print('Morning hours (5AM-11AM): ${timeResults['morning']!.length} hours');
      print('  Hours: ${timeResults['morning']!.join(', ')}');
      print('Afternoon hours (12PM-4PM): ${timeResults['afternoon']!.length} hours');
      print('  Hours: ${timeResults['afternoon']!.join(', ')}');
      print('Evening hours (5PM-4AM): ${timeResults['evening']!.length} hours');
      print('  Hours: ${timeResults['evening']!.join(', ')}');
      
      // Verify the distribution
      expect(timeResults['morning']!.length, equals(7));
      expect(timeResults['afternoon']!.length, equals(5));
      expect(timeResults['evening']!.length, equals(12));
      
      print('\n24-hour cycle simulation completed successfully!');
    });

    test('Real-time Greeting Display Test', () {
      print('\n=== REAL-TIME GREETING TEST ===');
      
      // Test current time functionality
      final currentGreeting = GreetingHelper.getGreeting();
      final currentMessage = GreetingHelper.getWelcomeMessage();
      final currentPeriod = GreetingHelper.getTimePeriod();
      final now = DateTime.now();
      
      print('Current System Time: ${now.toString()}');
      print('Detected Time Period: ${currentPeriod.toUpperCase()}');
      print('Current Greeting: $currentGreeting');
      print('Current Welcome Message: $currentMessage');
      
      // Verify the greeting matches the expected pattern
      expect(currentGreeting, isIn(['Good morning!', 'Good afternoon!', 'Good evening!']));
      expect(currentPeriod, isIn(['morning', 'afternoon', 'evening']));
      expect(currentMessage, contains(currentGreeting));
      
      print('Real-time greeting test completed successfully!');
    });
  });
}