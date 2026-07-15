import 'package:flutter/material.dart';
import 'package:menuario/src/core/theme/category_colors.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/features/shopping/presentation/models/shopping_row.dart';
import 'package:menuario/src/features/shopping/presentation/widgets/_shopping_row.dart';

/// A [Category] header (label + color dot) followed by its
/// [ShoppingCategoryGroup.rows], mirroring `CategorySection`'s Despensa
/// layout.
class ShoppingCategorySection extends StatelessWidget {
  const ShoppingCategorySection({super.key, required this.group});

  /// The category and its rows to render.
  final ShoppingCategoryGroup group;

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
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              MenuarioSpacing.gapH8,
              Text(group.category.label, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
        for (final row in group.rows) ShoppingRowTile(row: row),
      ],
    );
  }
}
