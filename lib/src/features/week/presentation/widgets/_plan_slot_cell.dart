import 'package:flutter/material.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/features/week/presentation/widgets/_meal_slot_style.dart';
import 'package:menuario/src/shared/shared.dart';

/// One `(day, mealSlot)` row, laid out as a scannable line:
///
/// `[accent bar] [MEAL micro] [emoji tile] [recipe name — primary] [chevron]`
///
/// An empty slot reads as a pending to-do (muted accent, `+` tile, dimmed
/// "Agregar"); a filled slot reads as present and tappable (full accent,
/// emoji anchor, a trailing `chevron_right`). A dangling `recipeId` (recipe
/// deleted after planning) still reads as filled, with a fallback label.
///
/// Purely presentational — [onTap] is provided by the parent, which decides
/// whether to open the picker (empty) or the detail sheet (filled).
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

  /// The plan entry for `(day, mealSlot)`, or `null` when the slot is empty.
  final PlanEntry? entry;

  /// The [entry]'s resolved recipe, or `null` when [entry] is `null` (empty
  /// slot) OR its `recipeId` no longer resolves to a recipe (dangling ref).
  final Recipe? recipe;

  /// Invoked when the cell is tapped, regardless of its current state.
  final VoidCallback onTap;

  bool get _filled => entry != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MenuarioSpacing.md,
          vertical: 6,
        ),
        child: Row(
          children: [
            _AccentBar(color: mealSlot.accent, dim: !_filled),
            MenuarioSpacing.gapH8,
            SizedBox(
              width: 40,
              child: Text(
                mealSlot.shortLabel.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            MenuarioSpacing.gapH8,
            MealEmojiTile(
              slot: mealSlot,
              emoji: recipe?.emoji ?? '🍽️',
              filled: _filled,
            ),
            MenuarioSpacing.gapH8,
            Expanded(child: _buildLabel(context)),
            if (_filled)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (entry == null) {
      return Text(
        'Agregar',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    final resolvedRecipe = recipe;
    final isDangling = resolvedRecipe == null;

    return Text(
      isDangling ? 'Receta no disponible' : resolvedRecipe.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: isDangling ? colorScheme.onSurfaceVariant : null,
        fontStyle: isDangling ? FontStyle.italic : null,
      ),
    );
  }
}

/// The thin left identity bar carrying the meal's day-arc [color]; dimmed
/// when the slot is empty so a filled row visibly outweighs a pending one.
class _AccentBar extends StatelessWidget {
  const _AccentBar({required this.color, required this.dim});

  final Color color;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 36,
      decoration: BoxDecoration(
        color: dim ? color.withValues(alpha: 0.35) : color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
