import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/week/presentation/widgets/_meal_slot_style.dart';
import 'package:menuario/src/features/week/presentation/widgets/_recipe_detail_sheet.dart';
import 'package:menuario/src/features/week/presentation/widgets/_recipe_picker_sheet.dart';
import 'package:menuario/src/features/week/presentation/widgets/_week_day_section.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockWeekPlanRepository extends Mock implements WeekPlanRepository {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

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

  late MockWeekPlanRepository mockWeekPlanRepository;
  late MockRecipeRepository mockRecipeRepository;

  setUp(() {
    mockWeekPlanRepository = MockWeekPlanRepository();
    mockRecipeRepository = MockRecipeRepository();
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) async => const Right(WeekPlan(entries: [])));
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([almuerzoRecipe]));
  });

  Future<void> pumpSection(
    WidgetTester tester, {
    Map<MealSlot, PlanEntry> entriesBySlot = const {},
    Map<String, Recipe> recipesById = const {},
    bool isToday = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weekPlanRepositoryProvider.overrideWithValue(mockWeekPlanRepository),
          recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: WeekDaySection(
              day: DayOfWeek.mar,
              entriesBySlot: entriesBySlot,
              recipesById: recipesById,
              isToday: isToday,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders the day header label', (tester) async {
    await pumpSection(tester);

    expect(find.text('Mar'), findsOneWidget);
  });

  testWidgets('renders one scan-label row per meal slot', (tester) async {
    await pumpSection(tester);

    for (final slot in MealSlot.values) {
      expect(find.text(slot.shortLabel.toUpperCase()), findsOneWidget);
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

  testWidgets('the header shows an n/4 planned-count pill', (tester) async {
    await pumpSection(tester);
    expect(find.text('0/4'), findsOneWidget);

    await pumpSection(
      tester,
      entriesBySlot: {MealSlot.almuerzo: almuerzoEntry},
      recipesById: {'r-almuerzo': almuerzoRecipe},
    );
    expect(find.text('1/4'), findsOneWidget);
  });

  testWidgets('shows a "Hoy" chip only when isToday', (tester) async {
    await pumpSection(tester, isToday: false);
    expect(find.text('Hoy'), findsNothing);

    await pumpSection(tester, isToday: true);
    expect(find.text('Hoy'), findsOneWidget);
  });

  testWidgets('tapping an EMPTY slot opens the recipe picker', (tester) async {
    await pumpSection(tester);

    await tester.tap(find.text('ALM'));
    await tester.pumpAndSettle();

    expect(find.byType(RecipePickerSheet), findsOneWidget);
    expect(find.byType(RecipeDetailSheet), findsNothing);
  });

  testWidgets('tapping a FILLED slot opens the recipe detail sheet', (
    tester,
  ) async {
    await pumpSection(
      tester,
      entriesBySlot: {MealSlot.almuerzo: almuerzoEntry},
      recipesById: {'r-almuerzo': almuerzoRecipe},
    );

    await tester.tap(find.text('ALM'));
    await tester.pumpAndSettle();

    expect(find.byType(RecipeDetailSheet), findsOneWidget);
    expect(find.byType(RecipePickerSheet), findsNothing);
  });
}
