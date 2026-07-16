import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/weekly_consumption_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/ingredients_by_id_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockIngredientRepository extends Mock implements IngredientRepository {}

class MockWeekPlanRepository extends Mock implements WeekPlanRepository {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  late MockIngredientRepository mockIngredientRepository;
  late MockWeekPlanRepository mockWeekPlanRepository;
  late MockRecipeRepository mockRecipeRepository;

  const pollo = Ingredient(
    id: 'ing-pollo',
    name: 'Pollo',
    category: Category.proteina,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    measurementMode: MeasurementMode.mass,
    conversionFactor: 1,
  );
  const recipePollo = Recipe(
    id: 'recipe-pollo',
    name: 'Pollo asado',
    bomLines: [
      BomLine(
        recipeId: 'recipe-pollo',
        ingredientId: 'ing-pollo',
        quantity: Quantity(value: 170, unit: Unit.gram),
      ),
    ],
  );

  const arroz = Ingredient(
    id: 'ing-arroz',
    name: 'Arroz',
    category: Category.cereal,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
  );
  const recipeArroz = Recipe(
    id: 'recipe-arroz',
    name: 'Arroz blanco',
    bomLines: [
      BomLine(
        recipeId: 'recipe-arroz',
        ingredientId: 'ing-arroz',
        quantity: Quantity(value: 2, unit: Unit.gram),
      ),
    ],
  );

  const comino = Ingredient(
    id: 'ing-comino',
    name: 'Comino',
    category: Category.condimento,
    measurementKind: MeasurementKind.unit,
    booleanTracked: true,
  );

  setUp(() {
    mockIngredientRepository = MockIngredientRepository();
    mockWeekPlanRepository = MockWeekPlanRepository();
    mockRecipeRepository = MockRecipeRepository();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        ingredientRepositoryProvider.overrideWithValue(
          mockIngredientRepository,
        ),
        weekPlanRepositoryProvider.overrideWithValue(mockWeekPlanRepository),
        recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('weeklyConsumptionByIngredientProvider', () {
    test('is AsyncLoading while any upstream source is still loading', () {
      when(
        () => mockWeekPlanRepository.getActive(),
      ).thenAnswer((_) => Future.delayed(const Duration(days: 1)));
      when(
        () => mockRecipeRepository.list(),
      ).thenAnswer((_) => Future.delayed(const Duration(days: 1)));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) => Future.delayed(const Duration(days: 1)));

      final container = makeContainer();

      final result = container.read(weeklyConsumptionByIngredientProvider);

      expect(
        result,
        isA<AsyncLoading<Map<String, Either<Failure, Quantity>>>>(),
      );
    });

    test('is AsyncError when any upstream source errors', () async {
      final failure = Failure(message: 'no se pudo cargar el plan');
      when(
        () => mockWeekPlanRepository.getActive(),
      ).thenAnswer((_) async => Left(failure));
      when(
        () => mockRecipeRepository.list(),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([]));

      final container = makeContainer();

      try {
        await container.read(planControllerProvider.future);
      } on FailureException catch (_) {
        // Expected — the week-plan repository is stubbed to fail.
      }
      await container.read(recipeListProvider.future);
      await container.read(ingredientsByIdProvider.future);

      final result = container.read(weeklyConsumptionByIngredientProvider);

      expect(
        result,
        isA<AsyncError<Map<String, Either<Failure, Quantity>>>>(),
      );
    });

    test(
      'sums a BomLine appearing twice this week (pollo 170 g x2 = 340 g)',
      () async {
        when(
          () => mockWeekPlanRepository.getActive(),
        ).thenAnswer(
          (_) async => const Right(
            WeekPlan(
              entries: [
                PlanEntry(
                  day: DayOfWeek.lun,
                  mealSlot: MealSlot.almuerzo,
                  recipeId: 'recipe-pollo',
                  cooked: false,
                ),
                PlanEntry(
                  day: DayOfWeek.mar,
                  mealSlot: MealSlot.almuerzo,
                  recipeId: 'recipe-pollo',
                  cooked: false,
                ),
              ],
            ),
          ),
        );
        when(
          () => mockRecipeRepository.list(),
        ).thenAnswer((_) async => const Right([recipePollo]));
        when(
          () => mockIngredientRepository.list(),
        ).thenAnswer((_) async => const Right([pollo]));

        final container = makeContainer();
        await container.read(planControllerProvider.future);
        await container.read(recipeListProvider.future);
        await container.read(ingredientsByIdProvider.future);

        final result = container.read(weeklyConsumptionByIngredientProvider);

        final map = result.value!;
        expect(
          map['ing-pollo'],
          const Right<Failure, Quantity>(Quantity(value: 340, unit: Unit.gram)),
        );
      },
    );

    test(
      'carries a Left(missingConversionFactor) for an ingredient whose '
      'conversion factor is missing, instead of throwing',
      () async {
        when(
          () => mockWeekPlanRepository.getActive(),
        ).thenAnswer(
          (_) async => const Right(
            WeekPlan(
              entries: [
                PlanEntry(
                  day: DayOfWeek.lun,
                  mealSlot: MealSlot.almuerzo,
                  recipeId: 'recipe-arroz',
                  cooked: false,
                ),
              ],
            ),
          ),
        );
        when(
          () => mockRecipeRepository.list(),
        ).thenAnswer((_) async => const Right([recipeArroz]));
        when(
          () => mockIngredientRepository.list(),
        ).thenAnswer((_) async => const Right([arroz]));

        final container = makeContainer();
        await container.read(planControllerProvider.future);
        await container.read(recipeListProvider.future);
        await container.read(ingredientsByIdProvider.future);

        final result = container.read(weeklyConsumptionByIngredientProvider);

        final map = result.value!;
        expect(
          map['ing-arroz'],
          isA<Left<Failure, Quantity>>().having(
            (left) => left.value.code,
            'code',
            'missingConversionFactor',
          ),
        );
      },
    );

    test(
      'omits boolean-tracked ingredients entirely — they are never routed '
      'through the numeric weekly-need map',
      () async {
        when(
          () => mockWeekPlanRepository.getActive(),
        ).thenAnswer((_) async => const Right(WeekPlan(entries: [])));
        when(
          () => mockRecipeRepository.list(),
        ).thenAnswer((_) async => const Right([]));
        when(
          () => mockIngredientRepository.list(),
        ).thenAnswer((_) async => const Right([comino]));

        final container = makeContainer();
        await container.read(planControllerProvider.future);
        await container.read(recipeListProvider.future);
        await container.read(ingredientsByIdProvider.future);

        final result = container.read(weeklyConsumptionByIngredientProvider);

        expect(result.value, isEmpty);
      },
    );

    test(
      'an ingredient absent from every planned recipe has no entry in the '
      'map (treated as zero need by callers)',
      () async {
        when(
          () => mockWeekPlanRepository.getActive(),
        ).thenAnswer((_) async => const Right(WeekPlan(entries: [])));
        when(
          () => mockRecipeRepository.list(),
        ).thenAnswer((_) async => const Right([recipePollo]));
        when(
          () => mockIngredientRepository.list(),
        ).thenAnswer((_) async => const Right([pollo]));

        final container = makeContainer();
        await container.read(planControllerProvider.future);
        await container.read(recipeListProvider.future);
        await container.read(ingredientsByIdProvider.future);

        final result = container.read(weeklyConsumptionByIngredientProvider);

        expect(result.value, isNot(contains('ing-pollo')));
      },
    );
  });
}
