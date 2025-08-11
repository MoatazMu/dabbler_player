import 'package:flutter_test/flutter_test.dart';
import 'package:dabbler/utils/helpers/location_helper.dart';

void main() {
  group('LocationHelper.calculateDistance', () {
    test('returns ~0 for same coordinates', () {
      final d = LocationHelper.calculateDistance(25.0, 55.0, 25.0, 55.0);
      expect(d, closeTo(0.0, 0.0001));
    });

    test('returns known distance Abu Dhabi -> Dubai (~123 km)', () {
      final d = LocationHelper.calculateDistance(24.4539, 54.3773, 25.2048, 55.2708);
      expect(d, inInclusiveRange(100, 150));
    });

    test('isWithinRadius works', () {
      final within = LocationHelper.isWithinRadius(24.4539, 54.3773, 24.5, 54.4, 10);
      expect(within, isTrue);
    });
  });

  group('LocationHelper.formatDistance', () {
    test('formats meters for short metric distances', () {
      expect(LocationHelper.formatDistance(0.12), '120m');
    });

    test('formats km for longer metric distances', () {
      expect(LocationHelper.formatDistance(3.456), '3.5km');
    });
  });
}
