import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/recipes/presentation/providers/ingredients_by_id_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';
import 'package:menuario/src/shared/shared.dart';

final _calculator = ProvisioningCalculator(
  converter: const MeasurementConverter(),
);

/// The shared plan+recipe+ingredients join: for every quantity-tracked
/// ingredient appearing in at least one planned recipe's `BomLine`s, its
/// weekly consumption (via [ProvisioningCalculator.weeklyConsumption]),
/// keyed by ingredient id.
///
/// This is the SAME join `shoppingListProvider` used to perform inline
/// (plan + recipes + ingredients — pantry is not needed for the need
/// number itself), extracted so it lives in exactly ONE place.
/// [shoppingListProvider]/[ShoppingListBuilder] and the Despensa coverage
/// badge/subtitle (`_quantity_pantry_row.dart`) both consume this
/// provider instead of re-deriving it.
///
/// An ingredient absent from every planned recipe's `BomLine`s has no
/// entry in the resulting map — callers treat a missing key the same as a
/// zero weekly need (see [CoverageCalculator.statusFor]'s `null`
/// handling). Boolean-tracked ingredients are never gathered here; they
/// have no numeric weekly need.
///
/// [Ingredient.needType] drives HOW each entry's value is computed (via
/// [ProvisioningCalculator.weeklyNeed]): [NeedType.recipeDriven] (default)
/// sums planned-recipe consumption same as before; [NeedType.weeklyFixed]
/// needs exactly 1 whole package once planned this week (still gathered
/// through the same BomLine-membership check — "planned" is unchanged,
/// only the need VALUE differs). [NeedType.optional] ingredients are
/// excluded from the gather entirely, regardless of whether they appear
/// in a planned recipe — they never get a map entry, are never a `Left`
/// skip, and never enter the weekly budget/shopping auto-calc.
final weeklyConsumptionByIngredientProvider =
    Provider<AsyncValue<Map<String, Either<Failure, Quantity>>>>(
      (ref) {
        final planValue = ref.watch(planControllerProvider);
        final recipesValue = ref.watch(recipeListProvider);
        final ingredientsValue = ref.watch(ingredientsByIdProvider);

        final upstream = [planValue, recipesValue, ingredientsValue];

        if (upstream.any((value) => value.isLoading)) {
          return const AsyncLoading();
        }
        for (final value in upstream) {
          if (value.hasError) {
            return AsyncError(
              value.error!,
              value.stackTrace ?? StackTrace.empty,
            );
          }
        }

        final weekPlan = planValue.value!;
        final recipes = recipesValue.value!;
        final ingredientsById = ingredientsValue.value!;

        // A disabled recipe never contributes to the weekly budget, even
        // when it still has a `weekPlan` slot (disabling after planning
        // does not auto-unplan — see `_plan_slot_cell.dart`). Both the
        // planned-recipes gather AND the `recipes:` argument fed to
        // `weeklyNeed` below must use this filtered list — the calculator
        // sums over whatever recipe list it is handed for every matching
        // ingredient, so passing the raw `recipes` list to `weeklyNeed`
        // would silently re-include a disabled recipe's contribution to an
        // ingredient shared with an enabled recipe.
        final enabledRecipes = [
          for (final recipe in recipes)
            if (recipe.enabled) recipe,
        ];

        final plannedRecipeIds = {
          for (final entry in weekPlan.entries) entry.recipeId,
        };
        final plannedRecipes = [
          for (final recipe in enabledRecipes)
            if (plannedRecipeIds.contains(recipe.id)) recipe,
        ];

        final quantityIngredientIds = <String>{};
        for (final recipe in plannedRecipes) {
          for (final line in recipe.bomLines) {
            final ingredient = ingredientsById[line.ingredientId];
            if (ingredient != null &&
                !ingredient.booleanTracked &&
                ingredient.needType != NeedType.optional) {
              quantityIngredientIds.add(line.ingredientId);
            }
          }
        }

        final result = <String, Either<Failure, Quantity>>{
          for (final ingredientId in quantityIngredientIds)
            ingredientId: _calculator.weeklyNeed(
              ingredient: ingredientsById[ingredientId]!,
              recipes: enabledRecipes,
              weekPlan: weekPlan,
            ),
        };

        return AsyncData(result);
      },
      dependencies: [
        planControllerProvider,
        recipeListProvider,
        ingredientsByIdProvider,
      ],
    );
