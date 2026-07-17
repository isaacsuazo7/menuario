import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/features/week/presentation/providers/recipes_for_slot_provider.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  const pregymRecipe = Recipe(
    id: 'r6',
    name: 'Batido de proteína',
    mealType: MealType.pregym,
    bomLines: [],
  );
  const desayunoRecipe = Recipe(
    id: 'r1',
    name: 'Avena',
    mealType: MealType.desayuno,
    bomLines: [],
  );
  const almuerzoRecipe = Recipe(
    id: 'r2',
    name: 'Pollo',
    mealType: MealType.almuerzo,
    bomLines: [],
  );
  const aderezoRecipe = Recipe(
    id: 'r3',
    name: 'Vinagreta',
    mealType: MealType.aderezo,
    bomLines: [],
  );
  const untaggedRecipe = Recipe(id: 'r4', name: 'Misterio', bomLines: []);
  const disabledAlmuerzoRecipe = Recipe(
    id: 'r5',
    name: 'Vieja receta',
    mealType: MealType.almuerzo,
    enabled: false,
    bomLines: [],
  );

  late MockRecipeRepository mockRecipeRepository;

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
    when(() => mockRecipeRepository.list()).thenAnswer(
      (_) async => const Right([
        pregymRecipe,
        desayunoRecipe,
        almuerzoRecipe,
        aderezoRecipe,
        untaggedRecipe,
        disabledAlmuerzoRecipe,
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

  test('pregym recipes are plannable into the pregym slot', () async {
    final container = makeContainer();
    await container.read(recipeListProvider.future);

    final result = container.read(recipesForSlotProvider(MealSlot.pregym));

    expect(result.value, [pregymRecipe]);
  });

  test('filters by the mealType matching the given slot', () async {
    final container = makeContainer();
    await container.read(recipeListProvider.future);

    final result = container.read(recipesForSlotProvider(MealSlot.desayuno));

    expect(result.value, [desayunoRecipe]);
  });

  test('excludes aderezo recipes for every slot', () async {
    final container = makeContainer();
    await container.read(recipeListProvider.future);

    for (final slot in MealSlot.values) {
      final result = container.read(recipesForSlotProvider(slot));
      expect(result.value, isNot(contains(aderezoRecipe)));
    }
  });

  test('excludes untagged recipes from every specific slot', () async {
    final container = makeContainer();
    await container.read(recipeListProvider.future);

    final result = container.read(recipesForSlotProvider(MealSlot.almuerzo));

    expect(result.value, [almuerzoRecipe]);
  });

  test('excludes disabled recipes even when the mealType matches', () async {
    final container = makeContainer();
    await container.read(recipeListProvider.future);

    final result = container.read(recipesForSlotProvider(MealSlot.almuerzo));

    expect(result.value, isNot(contains(disabledAlmuerzoRecipe)));
  });
}
