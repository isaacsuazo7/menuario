import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';
import 'package:menuario/src/features/week/presentation/widgets/_week_day_section.dart';
import 'package:menuario/src/shared/shared.dart';

/// The active [WeekPlan] and every loaded [Recipe], combined into one
/// value so [WeekScreen] can drive a single [AppAsyncValueWidget].
typedef _WeekScreenData = ({WeekPlan plan, List<Recipe> recipes});

/// Combines [planAsync] and [recipesAsync] into one [AsyncValue]: an error
/// on either side surfaces first, then loading until BOTH have data, then
/// the combined [_WeekScreenData].
AsyncValue<_WeekScreenData> _combine(
  AsyncValue<WeekPlan> planAsync,
  AsyncValue<List<Recipe>> recipesAsync,
) {
  if (planAsync.hasError) {
    return AsyncError(planAsync.error!, planAsync.stackTrace!);
  }
  if (recipesAsync.hasError) {
    return AsyncError(recipesAsync.error!, recipesAsync.stackTrace!);
  }

  final plan = planAsync.value;
  final recipes = recipesAsync.value;
  if (plan == null || recipes == null) {
    return const AsyncLoading();
  }

  return AsyncData((plan: plan, recipes: recipes));
}

/// The "Semana" tab body: the full week (Lun-Sáb) as a vertical list of
/// [WeekDaySection]s, each showing its 4 meal-slot rows.
///
/// Rendered inside the shell's single [Scaffold]/[AppBar]; keeps its own
/// [Scaffold] (without an `appBar`), matching [ProvisioningScreen] and
/// `RecipesScreen`.
class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planControllerProvider);
    final recipesAsync = ref.watch(recipeListProvider);
    final combined = _combine(planAsync, recipesAsync);

    return Scaffold(
      body: AppAsyncValueWidget<_WeekScreenData>(
        value: combined,
        onRetry: () {
          ref.invalidate(planControllerProvider);
          ref.invalidate(recipeListProvider);
        },
        builder: (context, data) {
          final recipesById = {
            for (final recipe in data.recipes) recipe.id: recipe,
          };
          final entriesByDay = <DayOfWeek, Map<MealSlot, PlanEntry>>{
            for (final day in DayOfWeek.values) day: {},
          };
          for (final entry in data.plan.entries) {
            entriesByDay[entry.day]![entry.mealSlot] = entry;
          }

          // A plain `Column` (not `ListView`'s sliver virtualization) so all
          // 6 day-sections build immediately — the list is small and
          // bounded (never grows), and every cell must be reachable
          // without relying on lazy scroll-triggered builds.
          return SingleChildScrollView(
            child: Column(
              children: [
                for (final day in DayOfWeek.values)
                  WeekDaySection(
                    day: day,
                    entriesBySlot: entriesByDay[day]!,
                    recipesById: recipesById,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
