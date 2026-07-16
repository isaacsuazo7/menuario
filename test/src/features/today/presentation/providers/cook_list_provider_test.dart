import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/features/today/data/repositories/cook_schedule_repository_impl.dart';
import 'package:menuario/src/features/today/domain/entities/cook_schedule.dart';
import 'package:menuario/src/features/today/domain/repositories/cook_schedule_repository.dart';
import 'package:menuario/src/features/today/domain/value_objects/cook_target.dart';
import 'package:menuario/src/features/today/presentation/providers/cook_list_provider.dart';
import 'package:menuario/src/features/today/presentation/providers/cook_schedule_provider.dart';
import 'package:menuario/src/features/today/presentation/providers/now_provider.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockWeekPlanRepository extends Mock implements WeekPlanRepository {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockCookScheduleRepository extends Mock implements CookScheduleRepository {}

void main() {
  const cenaLun = Recipe(id: 'r-cena-lun', name: 'Sopa', bomLines: []);
  const desMar = Recipe(id: 'r-des-mar', name: 'Avena', bomLines: []);
  const almMar = Recipe(id: 'r-alm-mar', name: 'Pollo', bomLines: []);

  late MockWeekPlanRepository mockWeekPlanRepository;
  late MockRecipeRepository mockRecipeRepository;
  late MockCookScheduleRepository mockCookScheduleRepository;

  setUp(() {
    mockWeekPlanRepository = MockWeekPlanRepository();
    mockRecipeRepository = MockRecipeRepository();
    mockCookScheduleRepository = MockCookScheduleRepository();
    // Defaults to the seed schedule (no saved doc) unless a test overrides
    // this stub — matches production's fallback behavior.
    when(
      () => mockCookScheduleRepository.getActive(),
    ).thenAnswer((_) async => const Right(null));
  });

  ProviderContainer makeContainer({required DateTime now}) {
    final container = ProviderContainer(
      overrides: [
        weekPlanRepositoryProvider.overrideWithValue(mockWeekPlanRepository),
        recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
        cookScheduleRepositoryProvider.overrideWithValue(
          mockCookScheduleRepository,
        ),
        nowProvider.overrideWithValue(now),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('Monday: resolves cena=hoy and Martes d/a/m=mañana, skipping unplanned '
      'merienda and ordering by slot', () async {
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
    await container.read(cookScheduleProvider.future);

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
    expect(result.value!.manana.map((item) => item.slot), [
      MealSlot.desayuno,
      MealSlot.almuerzo,
    ]);
    expect(result.value!.manana.map((item) => item.recipe.id), [
      'r-des-mar',
      'r-alm-mar',
    ]);
  });

  test('a target whose entry has a dangling recipeId is skipped', () async {
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
    await container.read(cookScheduleProvider.future);

    final result = container.read(cookListProvider);

    expect(result.value!.hoy, isEmpty);
    expect(result.value!.manana, isEmpty);
  });

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
    await container.read(cookScheduleProvider.future);

    final result = container.read(cookListProvider);

    expect(result.value!.hoy, isEmpty);
    expect(result.value!.manana.single.recipe.id, 'r-des-mar');
    expect(result.value!.manana.single.day, DayOfWeek.lun);
  });

  test(
    'an edited schedule (not the seed) is reflected: Domingo with a custom '
    'saved damManana-only routine resolves via the saved schedule',
    () async {
      when(() => mockCookScheduleRepository.getActive()).thenAnswer(
        (_) async => const Right(
          CookSchedule(
            byWeekday: {
              DateTime.sunday: [
                (
                  targetDay: DayOfWeek.lun,
                  slot: MealSlot.almuerzo,
                  group: CookGroup.manana,
                ),
              ],
            },
          ),
        ),
      );
      when(() => mockWeekPlanRepository.getActive()).thenAnswer(
        (_) async => const Right(
          WeekPlan(
            entries: [
              PlanEntry(
                day: DayOfWeek.lun,
                mealSlot: MealSlot.almuerzo,
                recipeId: 'r-alm-mar',
                cooked: false,
              ),
            ],
          ),
        ),
      );
      when(
        () => mockRecipeRepository.list(),
      ).thenAnswer((_) async => const Right([almMar]));

      final container = makeContainer(now: DateTime(2024, 1, 7)); // Sunday
      await container.read(planControllerProvider.future);
      await container.read(recipeListProvider.future);
      await container.read(cookScheduleProvider.future);

      final result = container.read(cookListProvider);

      expect(result.value!.manana.single.recipe.id, 'r-alm-mar');
      expect(result.value!.manana.single.slot, MealSlot.almuerzo);
    },
  );

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
    await container
        .read(planControllerProvider.future)
        .then((_) {}, onError: (_) {});
    await container.read(recipeListProvider.future);
    await container.read(cookScheduleProvider.future);

    final result = container.read(cookListProvider);

    expect(result.hasError, isTrue);
  });

  test('propagates a loading schedule AsyncValue', () async {
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) async => const Right(WeekPlan(entries: [])));
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([]));
    final scheduleCompleter = Completer<Either<Failure, CookSchedule?>>();
    when(
      () => mockCookScheduleRepository.getActive(),
    ).thenAnswer((_) => scheduleCompleter.future);

    final container = makeContainer(now: DateTime(2024, 1, 1));
    await container.read(planControllerProvider.future);
    await container.read(recipeListProvider.future);
    container.listen(cookScheduleProvider, (_, _) {});

    final result = container.read(cookListProvider);

    expect(result, isA<AsyncLoading<CookLists>>());
    scheduleCompleter.complete(const Right(null));
  });

  test('propagates a schedule load error', () async {
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) async => const Right(WeekPlan(entries: [])));
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([]));
    when(() => mockCookScheduleRepository.getActive()).thenAnswer(
      (_) async => Left(Failure(message: 'No se pudo cargar el horario.')),
    );

    final container = makeContainer(now: DateTime(2024, 1, 1));
    await container.read(planControllerProvider.future);
    await container.read(recipeListProvider.future);
    container.listen(cookScheduleProvider, (_, _) {});
    await container
        .read(cookScheduleProvider.future)
        .then((_) {}, onError: (_) {});

    final result = container.read(cookListProvider);

    expect(result.hasError, isTrue);
  });
}
