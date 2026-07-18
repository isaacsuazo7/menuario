import 'package:flutter/material.dart';
import 'package:menuario/src/shared/domain/value_objects/meal_type.dart';

/// The filled pill that labels a recipe's [MealType].
///
/// Shared rather than duplicated because the same tag renders in Recetario's
/// detail screen and in Hoy's meal sheet; both must stay identical.
///
/// Colors are read from the [ColorScheme] (`secondaryContainer` /
/// `onSecondaryContainer`) so the pill re-tints with the user's chosen seed
/// instead of carrying a hardcoded palette.
class MealTypeTag extends StatelessWidget {
  const MealTypeTag({super.key, required this.mealType});

  /// The meal type whose Spanish label the pill shows.
  final MealType mealType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        mealType.label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
