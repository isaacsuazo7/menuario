import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/features/today/presentation/providers/cook_list_provider.dart';
import 'package:menuario/src/features/today/presentation/providers/now_provider.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockWeekPlanRepository extends Mock implements WeekPlanRepository {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  const cenaLun = Recipe(id: 'r-cena-lun', name: 'Sopa', bomLines: []);
  const desMar = Recipe(id: 'r-des-mar', name: 'Avena', bomLines: []);
  const almMar = Recipe(id: 'r-alm-mar', name: 'Pollo', bomLines: []);

  late MockWeekPlanRepository mockWeekPlanRepository;
  late MockRecipeRepository mockRecipeRepository;

  setUp(() {
    mockWeekPlanRepository = MockWeekPlanRepository();
    mockRecipeRepository = MockRecipeRepository();
  });

  ProviderContainer makeContainer({required DateTime now}) {
    final container = ProviderContainer(
      overrides: [
        weekPlanRepositoryProvider.overrideWithValue(mockWeekPlanRepository),
        recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
        nowProvider.overrideWithValue(now),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    'Monday: resolves cena=hoy and Martes d/a/m=mañana, skipping unplanned '
    'merienda and ordering by slot',
    () async {
      when(() => mockWeekPlanRepository.getActive()).thenAnswer(
        (_) async => const Right(
          WeekPlan(
            entries: [
              PlanEntry(
                day: DayOfWeek.lun,
                mealSlot: MealSlot.cena,
                recipeId: 'r-cena-lun',
                cooked: false,
              ),
              PlanEntry(
                day: DayOfWeek.mar,
                mealSlot: MealSlot.almuerzo,
                recipeId: 'r-alm-mar',
                cooked: false,
              ),
              PlanEntry(
                day: DayOfWeek.mar,
                mealSlot: MealSlot.desayuno,
                recipeId: 'r-des-mar',
                cooked: false,
              ),
              // Merienda Martes intentionally unplanned.
            ],
          ),
        ),
      );
      when(
        () => mockRecipeRepository.list(),
      ).thenAnswer((_) async => const Right([cenaLun, desMar, almMar]));

      final container = makeContainer(now: DateTime(2024, 1, 1)); // Monday
      // Warm up upstream providers.
      await container.read(planControllerProvider.future);
      await container.read(recipeListProvider.future);

      final result = container.read(cookListProvider);

      expect(result.value!.hoy, [
        (
          recipe: cenaLun,
          day: DayOfWeek.lun,
          slot: MealSlot.cena,
          entry: const PlanEntry(
            day: DayOfWeek.lun,
            mealSlot: MealSlot.cena,
            recipeId: 'r-cena-lun',
            cooked: false,
          ),
        ),
      ]);
      expect(
        result.value!.manana.map((item) => item.slot),
        [MealSlot.desayuno, MealSlot.almuerzo],
      );
      expect(
        result.value!.manana.map((item) => item.recipe.id),
        ['r-des-mar', 'r-alm-mar'],
      );
    },
  );

  test(
    'a target whose entry has a dangling recipeId is skipped',
    () async {
      when(() => mockWeekPlanRepository.getActive()).thenAnswer(
        (_) async => const Right(
          WeekPlan(
            entries: [
              PlanEntry(
                day: DayOfWeek.vie,
                mealSlot: MealSlot.cena,
                recipeId: 'missing-recipe',
                cooked: false,
              ),
            ],
          ),
        ),
      );
      when(
        () => mockRecipeRepository.list(),
      ).thenAnswer((_) async => const Right([]));

      final container = makeContainer(now: DateTime(2024, 1, 5)); // Friday
      await container.read(planControllerProvider.future);
      await container.read(recipeListProvider.future);

      final result = container.read(cookListProvider);

      expect(result.value!.hoy, isEmpty);
      expect(result.value!.manana, isEmpty);
    },
  );

  test('Sunday resolves Monday d/a/m into mañana, with no hoy group', () async {
    when(() => mockWeekPlanRepository.getActive()).thenAnswer(
      (_) async => const Right(
        WeekPlan(
          entries: [
            PlanEntry(
              day: DayOfWeek.lun,
              mealSlot: MealSlot.desayuno,
              recipeId: 'r-des-mar',
              cooked: false,
            ),
          ],
        ),
      ),
    );
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([desMar]));

    final container = makeContainer(now: DateTime(2024, 1, 7)); // Sunday
    await container.read(planControllerProvider.future);
    await container.read(recipeListProvider.future);

    final result = container.read(cookListProvider);

    expect(result.value!.hoy, isEmpty);
    expect(result.value!.manana.single.recipe.id, 'r-des-mar');
    expect(result.value!.manana.single.day, DayOfWeek.lun);
  });

  test('propagates a loading plan AsyncValue', () async {
    final planCompleter = Completer<Either<Failure, WeekPlan?>>();
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) => planCompleter.future);
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    final container = makeContainer(now: DateTime(2024, 1, 1));
    container.listen(planControllerProvider, (_, _) {});

    final result = container.read(cookListProvider);

    expect(result, isA<AsyncLoading<CookLists>>());
    planCompleter.complete(const Right(WeekPlan(entries: [])));
  });

  test('propagates a plan load error', () async {
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) async => Left(Failure(message: 'No se pudo cargar.')));
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    final container = makeContainer(now: DateTime(2024, 1, 1));
    container.listen(planControllerProvider, (_, _) {});
    await container.read(planControllerProvider.future).then(
      (_) {},
      onError: (_) {},
    );
    await container.read(recipeListProvider.future);

    final result = container.read(cookListProvider);

    expect(result.hasError, isTrue);
  });
}
