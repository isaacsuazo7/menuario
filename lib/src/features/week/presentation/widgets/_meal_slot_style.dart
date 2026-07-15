import 'package:flutter/material.dart';
import 'package:menuario/src/shared/shared.dart';

/// Local "day arc" visual styling for the week feature: a subtle
/// time-of-day accent and a scannable short label per [MealSlot].
///
/// Kept local to the week feature (not in the shared theme) on purpose:
/// these are identity marks for the planner rows only, and the brand color
/// (`colorScheme.primary`) stays reserved for interactive affordances
/// (selection, the "Hoy" chip, primary buttons).
extension MealSlotStyleX on MealSlot {
  /// The time-of-day accent, morning → night. Used as a SMALL identity mark
  /// (a thin left bar / tile ring), never as a fill.
  Color get accent => switch (this) {
    MealSlot.desayuno => const Color(0xFFFBBF24), // amber — morning
    MealSlot.almuerzo => const Color(0xFF2DD4BF), // teal — midday
    MealSlot.merienda => const Color(0xFFFB923C), // orange — afternoon
    MealSlot.cena => const Color(0xFF818CF8), // indigo — night
  };

  /// The compact, fixed-width label shown at the start of each row so the
  /// eye scans Des/Alm/Mer/Cena straight down the day card.
  String get shortLabel => switch (this) {
    MealSlot.desayuno => 'Des',
    MealSlot.almuerzo => 'Alm',
    MealSlot.merienda => 'Mer',
    MealSlot.cena => 'Cena',
  };
}

/// A fixed-size rounded emoji anchor for a meal row: the recipe's emoji when
/// [filled], or a `+` add-affordance (muted, accent-ringed) when empty.
class MealEmojiTile extends StatelessWidget {
  const MealEmojiTile({
    super.key,
    required this.slot,
    required this.emoji,
    required this.filled,
  });

  /// The meal slot, for its [MealSlotStyleX.accent].
  final MealSlot slot;

  /// The emoji to show when [filled]; ignored (a `+` shows instead) when not.
  final String emoji;

  /// Whether the slot carries a recipe. Drives emoji-vs-`+` and the ring.
  final bool filled;

  static const double _size = 40;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: filled
            ? null
            : Border.all(color: slot.accent.withValues(alpha: 0.45)),
      ),
      alignment: Alignment.center,
      child: filled
          ? Text(emoji, style: const TextStyle(fontSize: 20))
          : Icon(
              Icons.add,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
    );
  }
}
