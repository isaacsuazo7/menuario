import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/features/week/presentation/providers/meal_slot_mapping.dart';
import 'package:menuario/src/shared/shared.dart';

/// [recipeListProvider] narrowed to only the recipes plannable into the
/// given [MealSlot] — i.e. whose `mealType` equals
/// [mealTypeForSlot]`(slot)`.
///
/// Unlike `filteredRecipesProvider` (Recetario's "Todas" passthrough), a
/// slot never shows untagged recipes: only an exact `mealType` match
/// qualifies, and `MealType.aderezo` recipes never match any slot because
/// [mealTypeForSlot] never produces `aderezo`.
final recipesForSlotProvider =
    Provider.family<AsyncValue<List<Recipe>>, MealSlot>((ref, slot) {
      final recipesValue = ref.watch(recipeListProvider);
      final mealType = mealTypeForSlot(slot);

      return recipesValue.whenData(
        (recipes) =>
            recipes.where((recipe) => recipe.mealType == mealType).toList(),
      );
    }, dependencies: [recipeListProvider]);
