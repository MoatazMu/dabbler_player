import 'package:flutter_test/flutter_test.dart';
import 'package:dabbler/features/games/utils/validators/game_validators.dart';

void main() {
  group('GameValidators', () {
    test('validateTitle basic cases', () {
      expect(GameValidators.validateTitle(null).isError, isTrue);
      expect(GameValidators.validateTitle('ab').isError, isTrue);
      expect(GameValidators.validateTitle('Valid Title').isSuccess, isTrue);
    });

    test('validatePlayerCount rules', () {
      // Soccer config has minPlayers 6, so minPlayers below that is an error
      final r1 = GameValidators.validatePlayerCount(minPlayers: 0, maxPlayers: 5, sport: 'soccer');
      expect(r1.isError, isTrue);
      // maxPlayers less than minPlayers is an error regardless of sport
      final r2 = GameValidators.validatePlayerCount(minPlayers: 6, maxPlayers: 3, sport: 'soccer');
      expect(r2.isError, isTrue);
      // A valid soccer range meeting min >= 6
      final r3 = GameValidators.validatePlayerCount(minPlayers: 6, maxPlayers: 10, sport: 'soccer');
      expect(r3.isSuccess, isTrue);
    });

    test('validatePrice and per-person', () {
      expect(GameValidators.validatePrice(-1).isError, isTrue);
      expect(GameValidators.validatePrice(0).isSuccess, isTrue);
      expect(GameValidators.validatePrice(1500).isWarning, isTrue);
      final per = GameValidators.validatePricePerPerson(1000, 4);
      expect(per.isWarning, isTrue); // 250 per person is high warning per rules
    });

    test('validateTimeSlotAvailability detects overlap', () {
      final occupied = [
        TimeSlot(
          startTime: DateTime(2025, 8, 11, 18, 0),
          duration: const Duration(hours: 2),
        ),
      ];
      final res = GameValidators.validateTimeSlotAvailability(
        startTime: DateTime(2025, 8, 11, 19, 0),
        duration: const Duration(hours: 1),
        occupiedSlots: occupied,
      );
      expect(res.isError, isTrue);
    });
  });
}
