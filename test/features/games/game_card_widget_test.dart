import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dabbler/features/games/presentation/widgets/game_card.dart';

void main() {
  testWidgets('GameCard renders and responds to tap', (tester) async {
    String tappedId = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameCard(
            id: 'g1',
            title: 'Evening Soccer',
            sport: 'soccer',
            dateTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
            venue: 'City Stadium',
            currentPlayers: 5,
            maxPlayers: 10,
            skillLevel: 'Beginner',
            distance: 2.5,
            price: 20,
            status: 'open',
            onTap: () => tappedId = 'g1',
          ),
        ),
      ),
    );

    expect(find.text('Evening Soccer'), findsOneWidget);
    await tester.tap(find.byType(GameCard));
    expect(tappedId, 'g1');
  });

  testWidgets('GameCard shows urgency on almost_full', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
  home: Scaffold(
          body: GameCard(
            id: 'g2',
            title: 'Basketball Pickup',
            sport: 'basketball',
            dateTime: DateTime(2025, 8, 12, 18, 0),
            venue: 'Downtown Court',
            currentPlayers: 9,
            maxPlayers: 10,
            skillLevel: 'Intermediate',
            distance: 1.2,
            price: 0,
            status: 'almost_full',
            variant: GameCardVariant.expanded,
          ),
        ),
      ),
    );

    expect(find.textContaining('spots left'), findsOneWidget);
  });
}
