import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/features/today/presentation/models/cook_item.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';
import 'package:menuario/src/features/week/presentation/providers/today_provider.dart';
import 'package:menuario/src/shared/shared.dart';

/// The Comer view's derived data: today's [PlanEntry]s (`day ==
/// todayProvider`), resolved to their [Recipe] and ordered by [MealSlot].
///
/// Sunday (`todayProvider == null`) always resolves to an empty list —
/// Domingo has no plannable day. A dangling `recipeId` is silently skipped,
/// mirroring [cookListProvider]'s resolution rule. Mirrors
/// `shoppingListProvider`'s watch-upstream-`AsyncValue`s idiom.
final todayMealsProvider = Provider<AsyncValue<List<CookItem>>>(
  (ref) {
    final planValue = ref.watch(planControllerProvider);
    final recipesValue = ref.watch(recipeListProvider);

    final upstream = [planValue, recipesValue];
    if (upstream.any((value) => value.isLoading)) {
      return const AsyncLoading();
    }
    for (final value in upstream) {
      if (value.hasError) {
        return AsyncError(value.error!, value.stackTrace ?? StackTrace.empty);
      }
    }

    final today = ref.watch(todayProvider);
    if (today == null) {
      return const AsyncData([]);
    }

    final recipesById = {for (final recipe in recipesValue.value!) recipe.id: recipe};

    final items = <CookItem>[];
    for (final entry in planValue.value!.entries) {
      if (entry.day != today) continue;
      final recipe = recipesById[entry.recipeId];
      if (recipe == null) continue;
      items.add((
        recipe: recipe,
        day: entry.day,
        slot: entry.mealSlot,
        entry: entry,
      ));
    }

    items.sort(
      (a, b) => MealSlot.values.indexOf(a.slot).compareTo(MealSlot.values.indexOf(b.slot)),
    );

    return AsyncData(items);
  },
  dependencies: [planControllerProvider, recipeListProvider, todayProvider],
);
