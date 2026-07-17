import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/recipes/presentation/providers/filtered_recipes_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/selected_meal_type_provider.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  const desayunoRecipe = Recipe(
    id: 'r1',
    name: 'Avena',
    mealType: MealType.desayuno,
    bomLines: [],
  );
  const untaggedRecipe = Recipe(id: 'r2', name: 'Misterio', bomLines: []);
  const almuerzoRecipe = Recipe(
    id: 'r3',
    name: 'Pollo',
    mealType: MealType.almuerzo,
    bomLines: [],
  );
  const disabledRecipe = Recipe(
    id: 'r4',
    name: 'Vieja receta',
    mealType: MealType.desayuno,
    enabled: false,
    bomLines: [],
  );

  late MockRecipeRepository mockRecipeRepository;

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
    when(() => mockRecipeRepository.list()).thenAnswer(
      (_) async => const Right([
        desayunoRecipe,
        untaggedRecipe,
        almuerzoRecipe,
        disabledRecipe,
      ]),
    );
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    'Todas (null) shows every recipe, including untagged and disabled',
    () async {
      final container = makeContainer();
      await container.read(recipeListProvider.future);

      final result = container.read(filteredRecipesProvider);

      expect(result.value, [
        desayunoRecipe,
        untaggedRecipe,
        almuerzoRecipe,
        disabledRecipe,
      ]);
    },
  );

  test('a specific meal type excludes untagged recipes', () async {
    final container = makeContainer();
    await container.read(recipeListProvider.future);
    container.read(selectedMealTypeProvider.notifier).select(MealType.desayuno);

    final result = container.read(filteredRecipesProvider);

    expect(result.value, [desayunoRecipe, disabledRecipe]);
  });

  test('Todas includes disabled recipes (grid reachability)', () async {
    final container = makeContainer();
    await container.read(recipeListProvider.future);

    final result = container.read(filteredRecipesProvider);

    expect(result.value, contains(disabledRecipe));
  });

  test(
    'a specific meal type also includes disabled recipes matching it',
    () async {
      final container = makeContainer();
      await container.read(recipeListProvider.future);
      container
          .read(selectedMealTypeProvider.notifier)
          .select(MealType.desayuno);

      final result = container.read(filteredRecipesProvider);

      expect(result.value, contains(disabledRecipe));
    },
  );
}
