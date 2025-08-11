import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dabbler/features/games/presentation/offline/offline_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  test('queue and retrieve actions', () async {
    await OfflineSupportService.clearQueuedActions();
    await OfflineSupportService.queueAction({'type': 'join_game', 'game_id': 'g1'});
    final actions = await OfflineSupportService.getQueuedActions();
    expect(actions.length, 1);
    expect(actions.first['type'], 'join_game');
  });
}
