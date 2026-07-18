import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/shared/shared.dart';

/// [recipeListProvider] narrowed by a [MealType] filter.
///
/// Keyed by the filter instead of reading `selectedMealTypeProvider` so the
/// Recetario's swipeable [PageView] can build each filter's page with its
/// own correctly-filtered list, not just the selected one's.
///
/// `null` (Todas) passes every recipe through, including those with a
/// `null` `mealType`. A specific [MealType] only matches recipes whose
/// `mealType` equals it — untagged recipes never appear under a specific
/// chip, only under Todas.
///
/// Disabled ([Recipe.enabled] `false`) recipes are INCLUDED here — the
/// Recetario grid renders them greyed with a reactivate action (see
/// `recipes_screen.dart`'s `_RecipeCard`), instead of hiding them
/// unreachably. Other `enabled`-scoped consumers (weekly-planning picker,
/// budget/coverage aggregation) apply their own independent `enabled`
/// filter and are unaffected by this provider's scope.
final filteredRecipesProvider =
    Provider.family<AsyncValue<List<Recipe>>, MealType?>((ref, mealType) {
      final recipesValue = ref.watch(recipeListProvider);

      return recipesValue.whenData((recipes) {
        if (mealType == null) return recipes;
        return recipes
            .where((recipe) => recipe.mealType == mealType)
            .toList();
      });
    }, dependencies: [recipeListProvider]);
