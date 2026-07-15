import 'package:flutter/material.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/shared/shared.dart';

/// One `(day, mealSlot)` row: an empty-slot add affordance, the assigned
/// recipe's emoji+name, or a fallback label for a dangling `recipeId`
/// (the recipe was deleted after planning).
///
/// Purely presentational — [onTap] is provided by the parent (typically
/// opening the `RecipePickerSheet` for this slot), keeping this widget
/// decoupled from the picker and trivially testable in isolation.
class PlanSlotCell extends StatelessWidget {
  const PlanSlotCell({
    super.key,
    required this.day,
    required this.mealSlot,
    required this.entry,
    required this.recipe,
    required this.onTap,
  });

  /// The day this cell renders, for the caller's [onTap] wiring.
  final DayOfWeek day;

  /// The meal slot this cell renders.
  final MealSlot mealSlot;

  /// The plan entry for `(day, mealSlot)`, or `null` when the slot is
  /// empty.
  final PlanEntry? entry;

  /// The [entry]'s resolved recipe, or `null` when [entry] is `null`
  /// (empty slot) OR its `recipeId` no longer resolves to a recipe
  /// (dangling reference).
  final Recipe? recipe;

  /// Invoked when the cell is tapped, regardless of its current state.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Row(
        children: [
          Text(mealSlot.label, style: Theme.of(context).textTheme.labelMedium),
          MenuarioSpacing.gapH8,
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (entry == null) {
      return Row(
        children: [
          const Icon(Icons.add, size: 18),
          MenuarioSpacing.gapH4,
          const Text('Agregar'),
        ],
      );
    }

    final resolvedRecipe = recipe;
    if (resolvedRecipe == null) {
      return const Text('Receta no disponible');
    }

    return Row(
      children: [
        Text(resolvedRecipe.emoji ?? '🍽️'),
        MenuarioSpacing.gapH8,
        Expanded(
          child: Text(
            resolvedRecipe.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
