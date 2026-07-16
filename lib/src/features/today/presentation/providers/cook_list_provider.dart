import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/features/today/presentation/models/cook_item.dart';
import 'package:menuario/src/features/today/presentation/providers/cook_schedule_provider.dart';
import 'package:menuario/src/features/today/presentation/providers/now_provider.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';
import 'package:menuario/src/shared/shared.dart';

/// The Cocinar view's resolved batch-cook targets, grouped into today's
/// ["Para hoy"] and tomorrow's ["Para mañana"] sections.
typedef CookLists = ({List<CookItem> hoy, List<CookItem> manana});

/// The Cocinar view's derived data: [cookScheduleProvider]'s targets for the
/// current [nowProvider] weekday, resolved against the active [WeekPlan],
/// grouped by [CookGroup] and ordered by [MealSlot].
///
/// Mirrors `shoppingListProvider`'s watch-upstream-`AsyncValue`s idiom:
/// loading/error propagate before any resolution happens. A target with no
/// matching [PlanEntry], or whose entry's `recipeId` no longer resolves to a
/// [Recipe] (dangling ref), is silently skipped — it never renders as a row.
final cookListProvider = Provider<AsyncValue<CookLists>>(
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

    final plan = planValue.value!;
    final recipesById = {
      for (final recipe in recipesValue.value!) recipe.id: recipe,
    };
    final entryByKey = {
      for (final entry in plan.entries) (entry.day, entry.mealSlot): entry,
    };

    final now = ref.watch(nowProvider);
    final schedule = ref.watch(cookScheduleProvider);
    final targets = schedule[now.weekday] ?? const [];

    final hoy = <CookItem>[];
    final manana = <CookItem>[];
    for (final target in targets) {
      final entry = entryByKey[(target.targetDay, target.slot)];
      if (entry == null) continue;
      final recipe = recipesById[entry.recipeId];
      if (recipe == null) continue;

      final item = (
        recipe: recipe,
        day: target.targetDay,
        slot: target.slot,
        entry: entry,
      );
      switch (target.group) {
        case CookGroup.hoy:
          hoy.add(item);
        case CookGroup.manana:
          manana.add(item);
      }
    }

    int bySlot(CookItem a, CookItem b) => MealSlot.values
        .indexOf(a.slot)
        .compareTo(MealSlot.values.indexOf(b.slot));
    hoy.sort(bySlot);
    manana.sort(bySlot);

    return AsyncData((hoy: hoy, manana: manana));
  },
  dependencies: [
    planControllerProvider,
    recipeListProvider,
    nowProvider,
    cookScheduleProvider,
  ],
);
