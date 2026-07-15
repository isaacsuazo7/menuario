import 'package:flutter/material.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/week/presentation/widgets/_plan_slot_cell.dart';
import 'package:menuario/src/features/week/presentation/widgets/_recipe_picker_sheet.dart';
import 'package:menuario/src/shared/shared.dart';

/// One day's card: a [day] header followed by its 4 full-width
/// [MealSlot] rows ([PlanSlotCell]), each opening a [RecipePickerSheet]
/// on tap.
class WeekDaySection extends StatelessWidget {
  const WeekDaySection({
    super.key,
    required this.day,
    required this.entriesBySlot,
    required this.recipesById,
  });

  /// The day this section renders.
  final DayOfWeek day;

  /// This day's [PlanEntry]s keyed by [MealSlot], pre-filtered by the
  /// caller. A missing key means that slot is empty.
  final Map<MealSlot, PlanEntry> entriesBySlot;

  /// Every loaded recipe keyed by id, used to resolve each entry's
  /// `recipeId` to its [Recipe] (or leave it dangling when absent).
  final Map<String, Recipe> recipesById;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: MenuarioSpacing.paddingAll8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MenuarioSpacing.paddingAll16,
            child: Text(day.label, style: MenuarioTypography.h4),
          ),
          for (final slot in MealSlot.values)
            _buildSlotRow(context, slot),
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
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) =>
            RecipePickerSheet(day: day, mealSlot: slot, currentEntry: entry),
      ),
    );
  }
}
