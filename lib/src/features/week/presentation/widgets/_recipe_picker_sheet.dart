import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';
import 'package:menuario/src/features/week/presentation/providers/recipes_for_slot_provider.dart';
import 'package:menuario/src/shared/shared.dart';

/// Bottom sheet opened from a [PlanSlotCell] tap: lists every recipe
/// plannable into [mealSlot] (via [recipesForSlotProvider]) and lets the
/// user assign one to `(day, mealSlot)`, or clear the slot if already
/// occupied.
///
/// Mirrors `SetStockSheet`'s shape: reads the notifier, pops immediately,
/// then awaits the mutation and shows a `SnackBar` on `Failure`.
class RecipePickerSheet extends ConsumerWidget {
  const RecipePickerSheet({
    super.key,
    required this.day,
    required this.mealSlot,
    required this.currentEntry,
  });

  /// The day being edited.
  final DayOfWeek day;

  /// The slot being edited; also the filter passed to
  /// [recipesForSlotProvider].
  final MealSlot mealSlot;

  /// The slot's current entry, if occupied. Drives whether the "Quitar"
  /// clear action is shown.
  final PlanEntry? currentEntry;

  Future<void> _handlePick(
    BuildContext context,
    WidgetRef ref,
    String recipeId,
  ) async {
    final notifier = ref.read(planControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();

    final failure = await notifier.assign(
      day: day,
      mealSlot: mealSlot,
      recipeId: recipeId,
    );

    if (failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  Future<void> _handleClear(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(planControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();

    final failure = await notifier.clear(day: day, mealSlot: mealSlot);

    if (failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesValue = ref.watch(recipesForSlotProvider(mealSlot));

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MenuarioSpacing.paddingAll16,
            child: Text('${mealSlot.label} · ${day.label}', style: MenuarioTypography.h4),
          ),
          if (currentEntry != null)
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Quitar'),
              onTap: () => _handleClear(context, ref),
            ),
          Flexible(
            child: AppAsyncValueWidget<List<Recipe>>(
              value: recipesValue,
              builder: (context, recipes) {
                if (recipes.isEmpty) {
                  return const Padding(
                    padding: MenuarioSpacing.paddingAll16,
                    child: Text('No hay recetas para este horario.'),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return ListTile(
                      leading: Text(
                        recipe.emoji ?? '🍽️',
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(recipe.name),
                      onTap: () => _handlePick(context, ref, recipe.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
