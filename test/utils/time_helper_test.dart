import 'package:flutter_test/flutter_test.dart';
import 'package:dabbler/utils/helpers/time_helper.dart';

void main() {
  test('formatGameTimeRange same day', () {
    final start = DateTime(2025, 8, 11, 18, 0);
    final end = DateTime(2025, 8, 11, 20, 0);
    final s = TimeHelper.formatGameTimeRange(start, end);
    expect(s, '6:00 PM - 8:00 PM');
  });

  test('calculateDuration returns correct duration', () {
    final start = DateTime(2025, 8, 11, 18, 0);
    final end = DateTime(2025, 8, 11, 20, 45);
    final d = TimeHelper.calculateDuration(start, end);
    expect(d.inMinutes, 165);
  });

  test('formatDuration formats nicely', () {
    expect(TimeHelper.formatDuration(const Duration(minutes: 45)), '45min');
    expect(TimeHelper.formatDuration(const Duration(hours: 2)), '2h');
    expect(TimeHelper.formatDuration(const Duration(hours: 1, minutes: 15)), '1h 15min');
  });

  test('getNextAvailableTimeSlot rounds up and respects min advance', () {
    final base = DateTime(2025, 8, 11, 10, 5);
    final next = TimeHelper.getNextAvailableTimeSlot(
      baseTime: base,
      intervalMinutes: 30,
      minAdvanceMinutes: 60,
    );
    // base + 60 = 11:05 rounded up to 11:30
    expect(next.hour, 11);
    expect(next.minute, 30);
  });

  test('isWithinBusinessHours respects open/close', () {
    final bh = BusinessHours.everyday(
      openTime: const TimeOfDay(hour: 9, minute: 0),
      closeTime: const TimeOfDay(hour: 21, minute: 0),
    );
    final t1 = DateTime(2025, 8, 11, 10, 0);
    final t2 = DateTime(2025, 8, 11, 22, 0);
    expect(TimeHelper.isWithinBusinessHours(bh, checkTime: t1), isTrue);
    expect(TimeHelper.isWithinBusinessHours(bh, checkTime: t2), isFalse);
  });
}
