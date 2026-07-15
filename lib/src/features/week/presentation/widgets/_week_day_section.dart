import 'package:flutter/material.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/week/presentation/widgets/_plan_slot_cell.dart';
import 'package:menuario/src/features/week/presentation/widgets/_recipe_detail_sheet.dart';
import 'package:menuario/src/features/week/presentation/widgets/_recipe_picker_sheet.dart';
import 'package:menuario/src/shared/shared.dart';

/// One day's card: a [day] header (name, `n/4` planned-count pill, and a
/// "Hoy" chip when [isToday]) followed by its 4 [MealSlot] rows.
///
/// Each row routes on tap: an EMPTY (or dangling) slot opens the
/// [RecipePickerSheet]; a FILLED slot opens the [RecipeDetailSheet].
class WeekDaySection extends StatelessWidget {
  const WeekDaySection({
    super.key,
    required this.day,
    required this.entriesBySlot,
    required this.recipesById,
    this.isToday = false,
  });

  /// The day this section renders.
  final DayOfWeek day;

  /// This day's [PlanEntry]s keyed by [MealSlot], pre-filtered by the caller.
  /// A missing key means that slot is empty.
  final Map<MealSlot, PlanEntry> entriesBySlot;

  /// Every loaded recipe keyed by id, used to resolve each entry's `recipeId`
  /// to its [Recipe] (or leave it dangling when absent).
  final Map<String, Recipe> recipesById;

  /// Whether this section is today's day. Drives the "Hoy" chip. The caller
  /// (`WeekScreen`) computes it from the injectable `todayProvider`, so it
  /// stays testable without touching the wall clock here.
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: MenuarioSpacing.paddingAll8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DayHeader(
            day: day,
            plannedCount: entriesBySlot.length,
            isToday: isToday,
          ),
          for (final slot in MealSlot.values) _buildSlotRow(context, slot),
          MenuarioSpacing.gapV8,
        ],
      ),
    );
  }

  Widget _buildSlotRow(BuildContext context, MealSlot slot) {
    final entry = entriesBySlot[slot];
    final recipe = entry == null ? null : recipesById[entry.recipeId];

    return PlanSlotCell(
      day: day,
      mealSlot: slot,
      entry: entry,
      recipe: recipe,
      onTap: () => _openSheet(context, slot, entry, recipe),
    );
  }

  /// A filled slot (entry AND its recipe both resolve) opens the detail
  /// sheet; an empty or dangling slot opens the picker so the user can
  /// assign or fix it.
  void _openSheet(
    BuildContext context,
    MealSlot slot,
    PlanEntry? entry,
    Recipe? recipe,
  ) {
    if (entry != null && recipe != null) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => RecipeDetailSheet(
          day: day,
          mealSlot: slot,
          recipe: recipe,
          entry: entry,
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          RecipePickerSheet(day: day, mealSlot: slot, currentEntry: entry),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.day,
    required this.plannedCount,
    required this.isToday,
  });

  final DayOfWeek day;
  final int plannedCount;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MenuarioSpacing.md,
        MenuarioSpacing.md,
        MenuarioSpacing.md,
        MenuarioSpacing.sm,
      ),
      child: Row(
        children: [
          Text(day.label, style: MenuarioTypography.h4),
          if (isToday) ...[
            MenuarioSpacing.gapH8,
            _HoyChip(colorScheme: colorScheme),
          ],
          const Spacer(),
          Text(
            '$plannedCount/${MealSlot.values.length}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// The brand-teal "Hoy" pill marking today's section — the one interactive
/// brand accent allowed in the header.
class _HoyChip extends StatelessWidget {
  const _HoyChip({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Hoy',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
