import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/features/today/presentation/providers/today_meals_provider.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';
import 'package:menuario/src/features/week/presentation/providers/today_provider.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockWeekPlanRepository extends Mock implements WeekPlanRepository {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  const almuerzoRecipe = Recipe(id: 'r-almuerzo', name: 'Pollo', bomLines: []);
  const cenaRecipe = Recipe(id: 'r-cena', name: 'Sopa', bomLines: []);

  late MockWeekPlanRepository mockWeekPlanRepository;
  late MockRecipeRepository mockRecipeRepository;

  setUp(() {
    mockWeekPlanRepository = MockWeekPlanRepository();
    mockRecipeRepository = MockRecipeRepository();
  });

  ProviderContainer makeContainer({DayOfWeek? today}) {
    final container = ProviderContainer(
      overrides: [
        weekPlanRepositoryProvider.overrideWithValue(mockWeekPlanRepository),
        recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
        todayProvider.overrideWithValue(today),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('orders today\'s entries by slot, ignoring other days', () async {
    when(() => mockWeekPlanRepository.getActive()).thenAnswer(
      (_) async => const Right(
        WeekPlan(
          entries: [
            PlanEntry(
              day: DayOfWeek.mar,
              mealSlot: MealSlot.cena,
              recipeId: 'r-cena',
              cooked: false,
            ),
            PlanEntry(
              day: DayOfWeek.mar,
              mealSlot: MealSlot.almuerzo,
              recipeId: 'r-almuerzo',
              cooked: false,
            ),
            PlanEntry(
              day: DayOfWeek.mie,
              mealSlot: MealSlot.almuerzo,
              recipeId: 'r-almuerzo',
              cooked: false,
            ),
          ],
        ),
      ),
    );
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([almuerzoRecipe, cenaRecipe]));

    final container = makeContainer(today: DayOfWeek.mar);
    await container.read(planControllerProvider.future);
    await container.read(recipeListProvider.future);

    final result = container.read(todayMealsProvider);

    expect(result.value!.map((item) => item.slot), [
      MealSlot.almuerzo,
      MealSlot.cena,
    ]);
  });

  test('Sunday (todayProvider null) is always empty', () async {
    when(() => mockWeekPlanRepository.getActive()).thenAnswer(
      (_) async => const Right(
        WeekPlan(
          entries: [
            PlanEntry(
              day: DayOfWeek.lun,
              mealSlot: MealSlot.desayuno,
              recipeId: 'r-almuerzo',
              cooked: false,
            ),
          ],
        ),
      ),
    );
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([almuerzoRecipe]));

    final container = makeContainer();
    await container.read(planControllerProvider.future);
    await container.read(recipeListProvider.future);

    final result = container.read(todayMealsProvider);

    expect(result.value, isEmpty);
  });

  test('a dangling recipeId is skipped', () async {
    when(() => mockWeekPlanRepository.getActive()).thenAnswer(
      (_) async => const Right(
        WeekPlan(
          entries: [
            PlanEntry(
              day: DayOfWeek.mar,
              mealSlot: MealSlot.almuerzo,
              recipeId: 'missing',
              cooked: false,
            ),
          ],
        ),
      ),
    );
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    final container = makeContainer(today: DayOfWeek.mar);
    await container.read(planControllerProvider.future);
    await container.read(recipeListProvider.future);

    final result = container.read(todayMealsProvider);

    expect(result.value, isEmpty);
  });

  test('propagates a loading plan AsyncValue', () {
    final planCompleter = Completer<Either<Failure, WeekPlan?>>();
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) => planCompleter.future);
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    final container = makeContainer(today: DayOfWeek.mar);
    container.listen(planControllerProvider, (_, _) {});

    final result = container.read(todayMealsProvider);

    expect(result.isLoading, isTrue);
    planCompleter.complete(const Right(WeekPlan(entries: [])));
  });

  test('propagates a plan load error', () async {
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) async => Left(Failure(message: 'No se pudo cargar.')));
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    final container = makeContainer(today: DayOfWeek.mar);
    container.listen(planControllerProvider, (_, _) {});
    await container.read(planControllerProvider.future).then(
      (_) {},
      onError: (_) {},
    );
    await container.read(recipeListProvider.future);

    final result = container.read(todayMealsProvider);

    expect(result.hasError, isTrue);
  });
}
