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

  Future<void> pumpCell(
    WidgetTester tester, {
    required PlanEntry? entry,
    required Recipe? recipe,
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
              onTap: () {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('an empty slot shows an add affordance', (tester) async {
    await pumpCell(tester, entry: null, recipe: null);

    expect(find.text('Agregar'), findsOneWidget);
  });

  testWidgets('an assigned slot shows the recipe emoji and name', (
    tester,
  ) async {
    await pumpCell(tester, entry: entry, recipe: almuerzoRecipe);

    expect(find.text('🍗'), findsOneWidget);
    expect(find.text('Pollo al horno'), findsOneWidget);
    expect(find.text('Agregar'), findsNothing);
  });

  testWidgets('a dangling recipeId shows a fallback label', (tester) async {
    await pumpCell(tester, entry: danglingEntry, recipe: null);

    expect(find.text('Receta no disponible'), findsOneWidget);
    expect(find.text('Agregar'), findsNothing);
  });

  testWidgets('tapping the cell invokes onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: PlanSlotCell(
              day: DayOfWeek.mar,
              mealSlot: MealSlot.almuerzo,
              entry: null,
              recipe: null,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PlanSlotCell));

    expect(tapped, isTrue);
  });
}
