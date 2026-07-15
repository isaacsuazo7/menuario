import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/week/presentation/widgets/_week_day_section.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  const almuerzoRecipe = Recipe(
    id: 'r-almuerzo',
    name: 'Pollo al horno',
    emoji: '🍗',
    mealType: MealType.almuerzo,
    bomLines: [],
  );
  const almuerzoEntry = PlanEntry(
    day: DayOfWeek.mar,
    mealSlot: MealSlot.almuerzo,
    recipeId: 'r-almuerzo',
    cooked: false,
  );

  Future<void> pumpSection(
    WidgetTester tester, {
    Map<MealSlot, PlanEntry> entriesBySlot = const {},
    Map<String, Recipe> recipesById = const {},
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: WeekDaySection(
              day: DayOfWeek.mar,
              entriesBySlot: entriesBySlot,
              recipesById: recipesById,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders the day header label', (tester) async {
    await pumpSection(tester);

    expect(find.text('Mar'), findsOneWidget);
  });

  testWidgets('renders one row per meal slot (4 full-width slot rows)', (
    tester,
  ) async {
    await pumpSection(tester);

    for (final slot in MealSlot.values) {
      expect(find.text(slot.label), findsOneWidget);
    }
  });

  testWidgets('an occupied slot shows its resolved recipe', (tester) async {
    await pumpSection(
      tester,
      entriesBySlot: {MealSlot.almuerzo: almuerzoEntry},
      recipesById: {'r-almuerzo': almuerzoRecipe},
    );

    expect(find.text('Pollo al horno'), findsOneWidget);
  });
}
