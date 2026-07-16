import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/today/presentation/models/cook_item.dart';
import 'package:menuario/src/features/today/presentation/providers/cook_list_provider.dart';
import 'package:menuario/src/features/today/presentation/widgets/_cook_body.dart';
import 'package:menuario/src/features/today/presentation/widgets/today_meal_detail_sheet.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  const cenaRecipe = Recipe(id: 'r-cena', name: 'Sopa', bomLines: []);
  const desayunoRecipe = Recipe(id: 'r-des', name: 'Avena', bomLines: []);
  const cenaEntry = PlanEntry(
    day: DayOfWeek.vie,
    mealSlot: MealSlot.cena,
    recipeId: 'r-cena',
    cooked: false,
  );
  const desayunoLunEntry = PlanEntry(
    day: DayOfWeek.lun,
    mealSlot: MealSlot.desayuno,
    recipeId: 'r-des',
    cooked: false,
  );

  Future<void> pumpBody(
    WidgetTester tester, {
    required AsyncValue<CookLists> lists,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [cookListProvider.overrideWithValue(lists)],
        child: const MaterialApp(home: Scaffold(body: CookBody())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Friday: only "Para hoy" renders (cena)', (tester) async {
    await pumpBody(
      tester,
      lists: AsyncData((
        hoy: [
          (
            recipe: cenaRecipe,
            day: DayOfWeek.vie,
            slot: MealSlot.cena,
            entry: cenaEntry,
          ),
        ],
        manana: const <CookItem>[],
      )),
    );

    expect(find.text('Para hoy'), findsOneWidget);
    expect(find.text('Para mañana'), findsNothing);
    expect(find.text('Sopa'), findsOneWidget);
  });

  testWidgets('Sunday: only "Para mañana" renders (Monday targets)', (
    tester,
  ) async {
    await pumpBody(
      tester,
      lists: AsyncData((
        hoy: const <CookItem>[],
        manana: [
          (
            recipe: desayunoRecipe,
            day: DayOfWeek.lun,
            slot: MealSlot.desayuno,
            entry: desayunoLunEntry,
          ),
        ],
      )),
    );

    expect(find.text('Para hoy'), findsNothing);
    expect(find.text('Para mañana'), findsOneWidget);
    expect(find.text('Avena'), findsOneWidget);
  });

  testWidgets('both groups empty shows a fallback message, no section '
      'headers', (tester) async {
    await pumpBody(
      tester,
      lists: const AsyncData((hoy: <CookItem>[], manana: <CookItem>[])),
    );

    expect(find.text('Para hoy'), findsNothing);
    expect(find.text('Para mañana'), findsNothing);
  });

  testWidgets('tapping a row opens TodayMealDetailSheet for that target', (
    tester,
  ) async {
    await pumpBody(
      tester,
      lists: AsyncData((
        hoy: const <CookItem>[],
        manana: [
          (
            recipe: desayunoRecipe,
            day: DayOfWeek.lun,
            slot: MealSlot.desayuno,
            entry: desayunoLunEntry,
          ),
        ],
      )),
    );

    await tester.tap(find.text('Avena'));
    await tester.pumpAndSettle();

    expect(find.byType(TodayMealDetailSheet), findsOneWidget);
  });
}
