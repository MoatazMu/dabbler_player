import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:dabbler/core/services/location_service.dart';

void main() {
  group('Location Detection Tests', () {
    late LocationService locationService;

    setUp(() {
      locationService = LocationService.instance;
      locationService.resetSimulation(); // Reset all simulation flags
    });

    tearDown(() {
      locationService.resetSimulation();
    });

    group('Successful Location Detection', () {
      test('should detect location successfully and populate chip correctly', () async {
        locationService.resetSimulation(); // Ensure clean state
        
        final locationData = await locationService.detectLocation();
        
        expect(locationData.status, equals(LocationStatus.success));
        expect(locationData.isValid, isTrue);
        expect(locationData.latitude, isNotNull);
        expect(locationData.longitude, isNotNull);
        expect(locationData.address, isNotNull);
        expect(locationData.city, isNotNull);
        expect(locationData.country, isNotNull);
        expect(locationData.displayName, isNotEmpty);
        
        print('✅ Successful location detection:');
        print('   Address: ${locationData.address}');
        print('   City: ${locationData.city}');
        print('   Country: ${locationData.country}');
        print('   Coordinates: ${locationData.latitude}, ${locationData.longitude}');
        print('   Display Name: ${locationData.displayName}');
        print('   Timestamp: ${locationData.timestamp}');
      });

      test('should populate location chip correctly after successful detection', () async {
        final locationData = await locationService.detectLocation();
        
        // Verify chip would be populated with correct data
        expect(locationData.isValid, isTrue);
        expect(locationData.displayName, contains('Dubai')); // Should contain city name
        
        // Verify the chip display format
        final chipText = locationData.displayName;
        expect(chipText, isNotEmpty);
        expect(chipText, contains(','));
        
        print('📍 Location chip would display: "$chipText"');
      });

      test('should provide location stream updates correctly', () async {
        final completer = Completer<LocationData>();
        late StreamSubscription subscription;
        
        subscription = locationService.locationStream.listen((locationData) {
          subscription.cancel();
          completer.complete(locationData);
        });
        
        // Trigger location detection
        locationService.detectLocation();
        
        // Wait for stream update
        final streamLocation = await completer.future.timeout(
          const Duration(seconds: 3),
          onTimeout: () => throw TimeoutException('Location stream timeout'),
        );
        
        expect(streamLocation.status, equals(LocationStatus.success));
        expect(streamLocation.isValid, isTrue);
        
        print('📡 Location stream update received: ${streamLocation.displayName}');
      });
    });

    group('Permission Denied Scenarios', () {
      test('should handle permission denied gracefully with fallback UI', () async {
        locationService.simulatePermissionDenied(true);
        
        final locationData = await locationService.detectLocation();
        
        expect(locationData.status, equals(LocationStatus.permissionDenied));
        expect(locationData.isValid, isFalse);
        expect(locationData.errorMessage, equals('Location permission denied'));
        
        // Verify fallback UI message
        final statusMessage = locationService.getStatusMessage(locationData.status, 'en');
        expect(statusMessage, equals('Location access denied'));
        
        final arabicMessage = locationService.getStatusMessage(locationData.status, 'ar');
        expect(arabicMessage, equals('تم رفض الوصول للموقع'));
        
        print('🚫 Permission denied test:');
        print('   Status: ${locationData.status}');
        print('   Error: ${locationData.errorMessage}');
        print('   EN Message: $statusMessage');
        print('   AR Message: $arabicMessage');
      });

      test('should show retry and manual location options on permission denied', () async {
        locationService.simulatePermissionDenied(true);
        
        await locationService.detectLocation();
        
        // Test retry functionality
        final retryResult = await locationService.retryLocationDetection();
        expect(retryResult.status, equals(LocationStatus.success)); // Should work after retry
        
        print('🔄 Retry after permission denied successful');
      });

      test('should ensure smooth retry prompt without crashes', () async {
        locationService.simulatePermissionDenied(true);
        
        // Multiple rapid retry attempts
        final futures = List.generate(3, (index) async {
          await Future.delayed(Duration(milliseconds: index * 100));
          return locationService.retryLocationDetection();
        });
        
        final results = await Future.wait(futures);
        
        for (final result in results) {
          expect(result, isNotNull);
          expect(result.status, isNot(equals(LocationStatus.permissionDenied))); // Should not remain denied
        }
        
        print('🔄 Multiple retry attempts handled gracefully');
      });
    });

    group('GPS Failure and Service Disabled', () {
      test('should handle GPS service disabled with fallback UI', () async {
        locationService.simulateGPSDisabled(true);
        
        final locationData = await locationService.detectLocation();
        
        expect(locationData.status, equals(LocationStatus.serviceDisabled));
        expect(locationData.isValid, isFalse);
        expect(locationData.errorMessage, equals('GPS service disabled'));
        
        final statusMessage = locationService.getStatusMessage(locationData.status, 'en');
        expect(statusMessage, equals('Location service disabled'));
        
        print('📱 GPS disabled test:');
        print('   Status: ${locationData.status}');
        print('   Error: ${locationData.errorMessage}');
        print('   Message: $statusMessage');
      });

      test('should handle location detection timeout gracefully', () async {
        locationService.simulateTimeout(true);
        
        final stopwatch = Stopwatch()..start();
        final locationData = await locationService.detectLocation();
        stopwatch.stop();
        
        expect(locationData.status, equals(LocationStatus.timeout));
        expect(locationData.isValid, isFalse);
        expect(stopwatch.elapsedMilliseconds, greaterThan(9000)); // Should take ~10 seconds
        
        print('⏱️ Timeout test:');
        print('   Duration: ${stopwatch.elapsedMilliseconds}ms');
        print('   Status: ${locationData.status}');
      });

      test('should handle general location errors with smooth UI', () async {
        locationService.simulateError(true);
        
        final locationData = await locationService.detectLocation();
        
        expect(locationData.status, equals(LocationStatus.error));
        expect(locationData.isValid, isFalse);
        expect(locationData.errorMessage, isNotNull);
        
        // Verify UI doesn't crash
        final statusMessage = locationService.getStatusMessage(locationData.status, 'en');
        expect(statusMessage, isNotEmpty);
        
        print('❌ General error test:');
        print('   Status: ${locationData.status}');
        print('   Error: ${locationData.errorMessage}');
        print('   UI Message: $statusMessage');
      });
    });

    group('Manual Area Selection Flow', () {
      test('should handle bottom sheet manual location input correctly', () async {
        const userInput = 'Dubai Marina, Dubai';
        
        final locationData = await locationService.setManualLocation(userInput);
        
        expect(locationData.status, equals(LocationStatus.manualSelection));
        expect(locationData.isValid, isTrue);
        expect(locationData.address, equals(userInput));
        expect(locationData.city, equals('Dubai'));
        expect(locationData.country, equals('UAE'));
        
        print('📝 Manual location input test:');
        print('   Input: $userInput');
        print('   Address: ${locationData.address}');
        print('   City: ${locationData.city}');
        print('   Display: ${locationData.displayName}');
      });

      test('should update chip and filters after manual selection', () async {
        const locations = [
          'Downtown Dubai',
          'Dubai Mall, Downtown',
          'Abu Dhabi Marina',
          'Sharjah City Center',
        ];
        
        for (final location in locations) {
          final locationData = await locationService.setManualLocation(location);
          
          expect(locationData.status, equals(LocationStatus.manualSelection));
          expect(locationData.isValid, isTrue);
          expect(locationData.address, equals(location));
          
          // Verify chip would update
          final chipDisplay = locationData.displayName;
          expect(chipDisplay, isNotEmpty);
          
          print('🏷️ Manual location "$location" → Chip: "$chipDisplay"');
        }
      });

      test('should handle invalid manual location input gracefully', () async {
        final invalidInputs = ['', '   ', null];
        
        for (final input in invalidInputs) {
          try {
            final locationData = await locationService.setManualLocation(input ?? '');
            
            expect(locationData.status, equals(LocationStatus.error));
            expect(locationData.isValid, isFalse);
            expect(locationData.errorMessage, equals('Invalid location input'));
            
            print('❌ Invalid input "$input" handled correctly');
          } catch (e) {
            // Should not throw exceptions
            fail('Manual location should handle invalid input gracefully: $e');
          }
        }
      });

      test('should simulate bottom sheet search flow correctly', () async {
        // Simulate user typing in search
        final searchTerms = ['Dub', 'Dubai', 'Dubai M', 'Dubai Mall'];
        
        for (final term in searchTerms) {
          if (term.length >= 3) { // Minimum search length
            final result = await locationService.setManualLocation(term);
            expect(result.status, equals(LocationStatus.manualSelection));
            print('🔍 Search "$term" → Result: ${result.displayName}');
          }
        }
        
        // Final selection
        const finalSelection = 'Dubai Mall, Downtown Dubai';
        final finalResult = await locationService.setManualLocation(finalSelection);
        
        expect(finalResult.isValid, isTrue);
        expect(finalResult.address, equals(finalSelection));
        
        print('✅ Final selection: ${finalResult.displayName}');
      });
    });

    group('Rapid Movement and Debounce Logic', () {
      test('should handle rapid movement without constant feed reloads', () async {
        locationService.simulateRapidMovement(true);
        
        // Start location detection which will trigger rapid updates
        await locationService.detectLocation();
        
        final locationUpdates = <LocationData>[];
        final completer = Completer<void>();
        
        // Listen to location stream for rapid updates
        final subscription = locationService.locationStream.listen((location) {
          locationUpdates.add(location);
        });
        
        // Wait for multiple updates
        await Future.delayed(const Duration(seconds: 6));
        subscription.cancel();
        locationService.simulateRapidMovement(false);
        
        expect(locationUpdates.length, greaterThan(1));
        expect(locationUpdates.length, lessThan(20)); // Should be debounced, not too many
        
        print('🏃 Rapid movement test:');
        print('   Updates received: ${locationUpdates.length}');
        print('   Time span: 6 seconds');
        print('   Debounce working: ${locationUpdates.length < 20 ? "✅" : "❌"}');
        
        // Verify coordinates are changing
        if (locationUpdates.length > 1) {
          final first = locationUpdates.first;
          final last = locationUpdates.last;
          expect(first.latitude, isNot(equals(last.latitude)));
          print('   Coordinates changed: ${first.latitude} → ${last.latitude}');
        }
      });

      test('should prevent flickering with debounce logic', () async {
        final updateTimestamps = <DateTime>[];
        
        locationService.simulateRapidMovement(true);
        await locationService.detectLocation();
        
        final subscription = locationService.locationStream.listen((location) {
          updateTimestamps.add(DateTime.now());
        });
        
        await Future.delayed(const Duration(seconds: 3));
        subscription.cancel();
        locationService.simulateRapidMovement(false);
        
        // Check intervals between updates
        if (updateTimestamps.length > 1) {
          for (int i = 1; i < updateTimestamps.length; i++) {
            final interval = updateTimestamps[i].difference(updateTimestamps[i - 1]);
            expect(interval.inMilliseconds, greaterThan(400)); // Should be debounced
          }
        }
        
        print('⏱️ Debounce test:');
        print('   Total updates: ${updateTimestamps.length}');
        print('   Debounce working: Updates spaced properly');
      });

      test('should handle changing IP and GPS coordinates smoothly', () async {
        // Simulate IP/GPS coordinate changes
        final locations = <LocationData>[];
        
        locationService.simulateRapidMovement(true);
        final initialLocation = await locationService.detectLocation();
        locations.add(initialLocation);
        
        // Wait for coordinate changes
        final subscription = locationService.locationStream.listen((location) {
          locations.add(location);
        });
        
        await Future.delayed(const Duration(seconds: 4));
        subscription.cancel();
        locationService.simulateRapidMovement(false);
        
        expect(locations.length, greaterThan(1));
        
        // Verify smooth transitions without jarring jumps
        for (int i = 1; i < locations.length; i++) {
          final prev = locations[i - 1];
          final curr = locations[i];
          
          if (prev.latitude != null && curr.latitude != null) {
            final latDiff = (curr.latitude! - prev.latitude!).abs();
            final lngDiff = (curr.longitude! - prev.longitude!).abs();
            
            // Changes should be small and smooth
            expect(latDiff, lessThan(0.1)); // Within reasonable bounds
            expect(lngDiff, lessThan(0.1));
          }
        }
        
        print('🌍 Coordinate changes test:');
        print('   Locations tracked: ${locations.length}');
        print('   Smooth transitions: ✅');
      });

      test('should avoid constant feed reloads during movement', () async {
        int feedReloadCount = 0;
        
        locationService.simulateRapidMovement(true);
        await locationService.detectLocation();
        
        // Simulate feed reload logic
        final subscription = locationService.locationStream.listen((location) {
          // In real app, this would trigger feed reload
          feedReloadCount++;
        });
        
        await Future.delayed(const Duration(seconds: 5));
        subscription.cancel();
        locationService.simulateRapidMovement(false);
        
        // Should not have excessive reloads
        expect(feedReloadCount, lessThan(15)); // Reasonable limit with debounce
        
        print('📱 Feed reload prevention test:');
        print('   Potential reloads: $feedReloadCount');
        print('   Excessive reloads prevented: ${feedReloadCount < 15 ? "✅" : "❌"}');
      });
    });

    group('Location Service State Management', () {
      test('should check location service status correctly', () {
        expect(locationService.isLocationServiceEnabled, isTrue);
        expect(locationService.hasLocationPermission, isTrue);
        
        locationService.setLocationServiceEnabled(false);
        expect(locationService.isLocationServiceEnabled, isFalse);
        
        locationService.setLocationPermission(false);
        expect(locationService.hasLocationPermission, isFalse);
        
        print('📊 Location service state management: ✅');
      });

      test('should handle current location property correctly', () async {
        expect(locationService.currentLocation, isNull);
        
        await locationService.detectLocation();
        
        expect(locationService.currentLocation, isNotNull);
        expect(locationService.currentLocation!.isValid, isTrue);
        
        print('📍 Current location property: ${locationService.currentLocation!.displayName}');
      });

      test('should provide proper status messages in both languages', () {
        final statuses = LocationStatus.values;
        
        for (final status in statuses) {
          final englishMessage = locationService.getStatusMessage(status, 'en');
          final arabicMessage = locationService.getStatusMessage(status, 'ar');
          
          expect(englishMessage, isNotEmpty);
          expect(arabicMessage, isNotEmpty);
          expect(englishMessage, isNot(equals(arabicMessage)));
          
          print('$status: EN="$englishMessage" | AR="$arabicMessage"');
        }
      });
    });

    group('Error Recovery and Resilience', () {
      test('should recover from multiple consecutive failures', () async {
        // Test sequence of failures followed by success
        locationService.simulateError(true);
        final error1 = await locationService.detectLocation();
        expect(error1.status, equals(LocationStatus.error));
        
        locationService.simulateTimeout(true);
        final error2 = await locationService.detectLocation();
        expect(error2.status, equals(LocationStatus.timeout));
        
        locationService.simulatePermissionDenied(true);
        final error3 = await locationService.detectLocation();
        expect(error3.status, equals(LocationStatus.permissionDenied));
        
        // Reset and should work
        locationService.resetSimulation();
        final success = await locationService.detectLocation();
        expect(success.status, equals(LocationStatus.success));
        
        print('🔄 Error recovery test: Multiple failures → Success ✅');
      });

      test('should handle concurrent location requests gracefully', () async {
        final futures = List.generate(5, (index) async {
          await Future.delayed(Duration(milliseconds: index * 100));
          return locationService.detectLocation();
        });
        
        final results = await Future.wait(futures);
        
        for (final result in results) {
          expect(result, isNotNull);
          expect(result.status, equals(LocationStatus.success));
        }
        
        print('🔀 Concurrent requests test: ${results.length} successful requests');
      });

      test('should handle service disposal gracefully', () {
        // Test that disposal doesn't crash
        expect(() => locationService.dispose(), returnsNormally);
        
        print('🧹 Service disposal test: ✅');
      });
    });

    group('Performance and Memory Tests', () {
      test('should handle long-running location tracking', () async {
        final updates = <LocationData>[];
        
        locationService.simulateRapidMovement(true);
        await locationService.detectLocation();
        
        final subscription = locationService.locationStream.listen((location) {
          updates.add(location);
        });
        
        // Run for longer period
        await Future.delayed(const Duration(seconds: 8));
        subscription.cancel();
        locationService.simulateRapidMovement(false);
        
        expect(updates.length, greaterThan(0));
        
        // Check memory usage doesn't grow excessively
        expect(updates.length, lessThan(30)); // Reasonable limit
        
        print('⏱️ Long-running tracking test:');
        print('   Duration: 8 seconds');
        print('   Updates: ${updates.length}');
        print('   Memory efficient: ✅');
      });
    });
  });
}