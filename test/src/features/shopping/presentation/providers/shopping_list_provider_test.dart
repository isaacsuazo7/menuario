import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/features/recipes/presentation/providers/ingredients_by_id_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/features/shopping/presentation/models/shopping_row.dart';
import 'package:menuario/src/features/shopping/presentation/providers/shopping_list_provider.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockPantryRepository extends Mock implements PantryRepository {}

class MockIngredientRepository extends Mock implements IngredientRepository {}

class MockWeekPlanRepository extends Mock implements WeekPlanRepository {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  late MockPantryRepository mockPantryRepository;
  late MockIngredientRepository mockIngredientRepository;
  late MockWeekPlanRepository mockWeekPlanRepository;
  late MockRecipeRepository mockRecipeRepository;

  const comino = Ingredient(
    id: 'ing-comino',
    name: 'Comino',
    category: Category.condimento,
    measurementKind: MeasurementKind.unit,
    booleanTracked: true,
  );
  const cominoItem = PantryItem.booleanTracked(
    ingredientId: 'ing-comino',
    category: Category.condimento,
    presentation: Presentation.loose(),
    haveIt: false,
  );

  setUpAll(() {
    registerFallbackValue(cominoItem);
  });

  setUp(() {
    mockPantryRepository = MockPantryRepository();
    mockIngredientRepository = MockIngredientRepository();
    mockWeekPlanRepository = MockWeekPlanRepository();
    mockRecipeRepository = MockRecipeRepository();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        pantryRepositoryProvider.overrideWithValue(mockPantryRepository),
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

  group('shoppingListProvider', () {
    test('is AsyncLoading while any upstream source is still loading', () {
      // Arrange — none of the mocks resolve before the first read.
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) => Future.delayed(const Duration(days: 1)));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) => Future.delayed(const Duration(days: 1)));
      when(
        () => mockWeekPlanRepository.getActive(),
      ).thenAnswer((_) => Future.delayed(const Duration(days: 1)));
      when(
        () => mockRecipeRepository.list(),
      ).thenAnswer((_) => Future.delayed(const Duration(days: 1)));

      final container = makeContainer();

      // Act
      final result = container.read(shoppingListProvider);

      // Assert
      expect(result, isA<AsyncLoading<ShoppingBuyList>>());
    });

    test('is AsyncError when any upstream source errors', () async {
      // Arrange
      final failure = Failure(message: 'no se pudo cargar la despensa');
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => Left(failure));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => mockWeekPlanRepository.getActive(),
      ).thenAnswer((_) async => const Right(WeekPlan(entries: [])));
      when(
        () => mockRecipeRepository.list(),
      ).thenAnswer((_) async => const Right([]));

      final container = makeContainer();

      // Act — drive every upstream future to completion (errors included).
      try {
        await container.read(pantryControllerProvider.future);
      } on FailureException catch (_) {
        // Expected — the pantry repository is stubbed to fail.
      }
      await container.read(planControllerProvider.future);
      await container.read(recipeListProvider.future);
      await container.read(ingredientsByIdProvider.future);

      final result = container.read(shoppingListProvider);

      // Assert
      expect(result, isA<AsyncError<ShoppingBuyList>>());
    });

    test('delegates to ShoppingListBuilder once every upstream source has '
        'loaded', () async {
      // Arrange
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([cominoItem]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([comino]));
      when(
        () => mockWeekPlanRepository.getActive(),
      ).thenAnswer((_) async => const Right(WeekPlan(entries: [])));
      when(
        () => mockRecipeRepository.list(),
      ).thenAnswer((_) async => const Right([]));

      final container = makeContainer();

      // Act
      await container.read(pantryControllerProvider.future);
      await container.read(planControllerProvider.future);
      await container.read(recipeListProvider.future);
      await container.read(ingredientsByIdProvider.future);

      final result = container.read(shoppingListProvider);

      // Assert — same shape ShoppingListBuilder.build would have produced.
      final buyList = result.value!;
      expect(buyList.groups, hasLength(1));
      expect(buyList.groups.single.rows.single.ingredientId, 'ing-comino');
    });

    test(
      'recomputes when an upstream pantry patch changes the derived state',
      () async {
        // Arrange
        when(
          () => mockPantryRepository.list(),
        ).thenAnswer((_) async => const Right([cominoItem]));
        when(
          () => mockIngredientRepository.list(),
        ).thenAnswer((_) async => const Right([comino]));
        when(
          () => mockWeekPlanRepository.getActive(),
        ).thenAnswer((_) async => const Right(WeekPlan(entries: [])));
        when(
          () => mockRecipeRepository.list(),
        ).thenAnswer((_) async => const Right([]));
        when(
          () => mockPantryRepository.save(any()),
        ).thenAnswer((_) async => const Right(null));

        final container = makeContainer();
        await container.read(pantryControllerProvider.future);
        await container.read(planControllerProvider.future);
        await container.read(recipeListProvider.future);
        await container.read(ingredientsByIdProvider.future);

        expect(
          container.read(shoppingListProvider).value!.groups,
          hasLength(1),
        );

        // Act — "tengo" now, via the real optimistic mutation surface.
        await container
            .read(pantryControllerProvider.notifier)
            .toggleHave('ing-comino');

        // Assert
        expect(container.read(shoppingListProvider).value!.groups, isEmpty);
      },
    );
  });
}
