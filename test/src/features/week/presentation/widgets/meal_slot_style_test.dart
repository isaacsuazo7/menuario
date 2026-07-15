import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/week/presentation/widgets/_meal_slot_style.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  group('MealSlotStyleX', () {
    test('every slot has a distinct accent color', () {
      final accents = {for (final s in MealSlot.values) s.accent};
      expect(accents.length, MealSlot.values.length);
    });

    test('short labels are the compact scan column', () {
      expect(MealSlot.desayuno.shortLabel, 'Des');
      expect(MealSlot.almuerzo.shortLabel, 'Alm');
      expect(MealSlot.merienda.shortLabel, 'Mer');
      expect(MealSlot.cena.shortLabel, 'Cena');
    });
  });

  group('MealEmojiTile', () {
    Future<void> pump(WidgetTester tester, {required bool filled}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealEmojiTile(
              slot: MealSlot.desayuno,
              emoji: '🥣',
              filled: filled,
            ),
          ),
        ),
      );
    }

    testWidgets('filled shows the emoji, not the add icon', (tester) async {
      await pump(tester, filled: true);

      expect(find.text('🥣'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('empty shows the add icon, not the emoji', (tester) async {
      await pump(tester, filled: false);

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('🥣'), findsNothing);
    });
  });
}
