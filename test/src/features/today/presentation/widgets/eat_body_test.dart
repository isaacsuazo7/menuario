import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/today/presentation/models/cook_item.dart';
import 'package:menuario/src/features/today/presentation/providers/today_meals_provider.dart';
import 'package:menuario/src/features/today/presentation/widgets/_eat_body.dart';
import 'package:menuario/src/features/today/presentation/widgets/today_meal_detail_sheet.dart';
import 'package:menuario/src/features/week/presentation/providers/today_provider.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  const almuerzoRecipe = Recipe(id: 'r-almuerzo', name: 'Pollo', bomLines: []);
  const cenaRecipe = Recipe(id: 'r-cena', name: 'Sopa', bomLines: []);
  const almuerzoEntry = PlanEntry(
    day: DayOfWeek.mar,
    mealSlot: MealSlot.almuerzo,
    recipeId: 'r-almuerzo',
    cooked: false,
  );
  const cenaEntry = PlanEntry(
    day: DayOfWeek.mar,
    mealSlot: MealSlot.cena,
    recipeId: 'r-cena',
    cooked: false,
  );

  Future<void> pumpBody(
    WidgetTester tester, {
    required DayOfWeek? today,
    required AsyncValue<List<CookItem>> meals,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayProvider.overrideWithValue(today),
          todayMealsProvider.overrideWithValue(meals),
        ],
        child: const MaterialApp(home: Scaffold(body: EatBody())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Sunday shows "Domingo, día libre" with no list', (tester) async {
    await pumpBody(tester, today: null, meals: const AsyncData([]));

    expect(find.text('Domingo, día libre'), findsOneWidget);
    expect(find.text('Nada planeado — planificá en Semana'), findsNothing);
  });

  testWidgets('a weekday with zero planned meals shows the planning hint', (
    tester,
  ) async {
    await pumpBody(tester, today: DayOfWeek.mar, meals: const AsyncData([]));

    expect(find.text('Nada planeado — planificá en Semana'), findsOneWidget);
  });

  testWidgets(
    'a weekday with entries renders every row (already slot-ordered by '
    'todayMealsProvider) and opens the detail sheet on tap',
    (tester) async {
      // todayMealsProvider (tested separately) is the layer responsible for
      // slot ordering — this list is deliberately pre-sorted (almuerzo
      // before cena), and EatBody is expected to render it as-is.
      await pumpBody(
        tester,
        today: DayOfWeek.mar,
        meals: AsyncData([
          (
            recipe: almuerzoRecipe,
            day: DayOfWeek.mar,
            slot: MealSlot.almuerzo,
            entry: almuerzoEntry,
          ),
          (
            recipe: cenaRecipe,
            day: DayOfWeek.mar,
            slot: MealSlot.cena,
            entry: cenaEntry,
          ),
        ]),
      );

      final names = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toList();
      expect(
        names.indexOf('Pollo') < names.indexOf('Sopa'),
        isTrue,
        reason: 'Almuerzo (Pollo) must render before Cena (Sopa)',
      );

      await tester.tap(find.text('Pollo'));
      await tester.pumpAndSettle();

      expect(find.byType(TodayMealDetailSheet), findsOneWidget);
    },
  );
}
