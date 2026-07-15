import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';
import 'package:menuario/src/features/week/presentation/widgets/_recipe_detail_sheet.dart';
import 'package:menuario/src/features/week/presentation/widgets/_recipe_picker_sheet.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockWeekPlanRepository extends Mock implements WeekPlanRepository {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  const recipe = Recipe(
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

  late MockWeekPlanRepository mockWeekPlanRepository;
  late MockRecipeRepository mockRecipeRepository;

  setUpAll(() {
    registerFallbackValue(const WeekPlan(entries: []));
  });

  setUp(() {
    mockWeekPlanRepository = MockWeekPlanRepository();
    mockRecipeRepository = MockRecipeRepository();
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) async => const Right(WeekPlan(entries: [entry])));
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([recipe]));
  });

  Future<void> pumpSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weekPlanRepositoryProvider.overrideWithValue(mockWeekPlanRepository),
          recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  ref.watch(planControllerProvider);
                  return ElevatedButton(
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const RecipeDetailSheet(
                        day: DayOfWeek.mar,
                        mealSlot: MealSlot.almuerzo,
                        recipe: recipe,
                        entry: entry,
                      ),
                    ),
                    child: const Text('open'),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the recipe and the three slot actions', (tester) async {
    await pumpSheet(tester);

    expect(find.text('Pollo al horno'), findsOneWidget);
    expect(find.text('🍗'), findsOneWidget);
    expect(find.text('Ver receta'), findsOneWidget);
    expect(find.text('Cambiar'), findsOneWidget);
    expect(find.text('Quitar'), findsOneWidget);
  });

  testWidgets('"Cambiar" closes the detail sheet and opens the picker', (
    tester,
  ) async {
    await pumpSheet(tester);

    await tester.tap(find.text('Cambiar'));
    await tester.pumpAndSettle();

    expect(find.byType(RecipeDetailSheet), findsNothing);
    expect(find.byType(RecipePickerSheet), findsOneWidget);
  });

  testWidgets('"Quitar" clears the slot via the controller', (tester) async {
    when(
      () => mockWeekPlanRepository.save(any()),
    ).thenAnswer((_) async => const Right(null));

    await pumpSheet(tester);

    await tester.tap(find.text('Quitar'));
    await tester.pumpAndSettle();

    expect(find.byType(RecipeDetailSheet), findsNothing);
    final captured = verify(
      () => mockWeekPlanRepository.save(captureAny()),
    ).captured;
    final savedPlan = captured.single as WeekPlan;
    expect(savedPlan.entries, isEmpty);
  });
}
