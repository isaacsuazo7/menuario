import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/week/presentation/widgets/_plan_slot_cell.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  const almuerzoRecipe = Recipe(
    id: 'r-almuerzo',
    name: 'Pollo al horno',
    emoji: '🍗',
    mealType: MealType.almuerzo,
    bomLines: [],
  );
  const entry = PlanEntry(
    day: DayOfWeek.mar,
    mealSlot: MealSlot.almuerzo,
    recipeId: 'r-almuerzo',
    cooked: false,
  );
  const danglingEntry = PlanEntry(
    day: DayOfWeek.mar,
    mealSlot: MealSlot.almuerzo,
    recipeId: 'r-deleted',
    cooked: false,
  );
  const disabledRecipe = Recipe(
    id: 'r-disabled',
    name: 'Vieja receta',
    emoji: '🥘',
    mealType: MealType.almuerzo,
    enabled: false,
    bomLines: [],
  );
  const disabledEntry = PlanEntry(
    day: DayOfWeek.mar,
    mealSlot: MealSlot.almuerzo,
    recipeId: 'r-disabled',
    cooked: false,
  );

  Future<void> pumpCell(
    WidgetTester tester, {
    required PlanEntry? entry,
    required Recipe? recipe,
    VoidCallback? onTap,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: PlanSlotCell(
              day: DayOfWeek.mar,
              mealSlot: MealSlot.almuerzo,
              entry: entry,
              recipe: recipe,
              onTap: onTap ?? () {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('always renders the meal short label (scan column)', (
    tester,
  ) async {
    await pumpCell(tester, entry: null, recipe: null);

    expect(find.text('ALM'), findsOneWidget);
  });

  testWidgets('an empty slot reads as pending: add affordance, no chevron', (
    tester,
  ) async {
    await pumpCell(tester, entry: null, recipe: null);

    expect(find.text('Agregar'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('a filled slot shows emoji, name and a trailing chevron', (
    tester,
  ) async {
    await pumpCell(tester, entry: entry, recipe: almuerzoRecipe);

    expect(find.text('🍗'), findsOneWidget);
    expect(find.text('Pollo al horno'), findsOneWidget);
    expect(find.text('Agregar'), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('a dangling recipeId shows a fallback label, reads as filled', (
    tester,
  ) async {
    await pumpCell(tester, entry: danglingEntry, recipe: null);

    expect(find.text('Receta no disponible'), findsOneWidget);
    expect(find.text('Agregar'), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets(
    'a disabled planned recipe still reads as filled (name + chevron) but '
    'is visibly greyed — it stays assigned, not unplanned',
    (tester) async {
      await pumpCell(tester, entry: disabledEntry, recipe: disabledRecipe);

      expect(find.text('Vieja receta'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      final opacityFinder = find.ancestor(
        of: find.text('Vieja receta'),
        matching: find.byType(Opacity),
      );
      expect(opacityFinder, findsWidgets);
      final opacity = tester.widget<Opacity>(opacityFinder.first);
      expect(opacity.opacity, lessThan(1.0));
    },
  );

  testWidgets('tapping the cell invokes onTap', (tester) async {
    var tapped = false;
    await pumpCell(
      tester,
      entry: null,
      recipe: null,
      onTap: () => tapped = true,
    );

    await tester.tap(find.byType(PlanSlotCell));

    expect(tapped, isTrue);
  });
}
