import 'package:flutter/material.dart';
import 'package:menuario/src/core/theme/category_colors.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_boolean_pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_quantity_pantry_row.dart';
import 'package:menuario/src/shared/shared.dart';

/// A [Category] header (label + color dot, via `colorFor`) followed by its
/// [PantryCategoryGroup.rows], rendered as [QuantityPantryRow] or
/// [BooleanPantryRow] depending on each item's tracking shape.
class CategorySection extends StatelessWidget {
  const CategorySection({super.key, required this.group});

  /// The category and its rows to render.
  final PantryCategoryGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<MenuarioCategoryColors>();
    final color =
        palette?.colorFor(
          group.category,
          fallback: theme.colorScheme.onSurfaceVariant,
        ) ??
        theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: MenuarioSpacing.paddingAll16,
          child: Row(
            children: [
              Container(
                key: const ValueKey('category-color-dot'),
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              MenuarioSpacing.gapH8,
              Text(group.category.label, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
        for (final row in group.rows)
          row.item is QuantityTrackedPantryItem
              ? QuantityPantryRow(row: row)
              : BooleanPantryRow(row: row),
      ],
    );
  }
}
