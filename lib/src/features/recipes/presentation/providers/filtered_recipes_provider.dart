import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/selected_meal_type_provider.dart';
import 'package:menuario/src/shared/shared.dart';

/// [recipeListProvider] narrowed by [selectedMealTypeProvider].
///
/// `null` (Todas) passes every recipe through, including those with a
/// `null` `mealType`. A specific [MealType] only matches recipes whose
/// `mealType` equals it — untagged recipes never appear under a specific
/// chip, only under Todas.
final filteredRecipesProvider = Provider<AsyncValue<List<Recipe>>>((ref) {
  final recipesValue = ref.watch(recipeListProvider);
  final selectedMealType = ref.watch(selectedMealTypeProvider);

  return recipesValue.whenData((recipes) {
    if (selectedMealType == null) return recipes;
    return recipes
        .where((recipe) => recipe.mealType == selectedMealType)
        .toList();
  });
}, dependencies: [recipeListProvider, selectedMealTypeProvider]);
