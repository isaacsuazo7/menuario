import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/features/recipes/presentation/providers/ingredients_by_id_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/features/shopping/presentation/models/shopping_row.dart';
import 'package:menuario/src/features/shopping/presentation/providers/shopping_list_provider.dart';
import 'package:menuario/src/features/shopping/presentation/widgets/_shopping_category_section.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';
import 'package:menuario/src/shared/shared.dart';

/// The "Comprar" tab body: the derived buy list, grouped by category, with
/// a named skipped-diagnostics badge when a per-ingredient calculation
/// failed.
class ShoppingListSection extends ConsumerWidget {
  const ShoppingListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buyListValue = ref.watch(shoppingListProvider);

    return AppAsyncValueWidget<ShoppingBuyList>(
      value: buyListValue,
      onRetry: () {
        ref.invalidate(planControllerProvider);
        ref.invalidate(pantryControllerProvider);
        ref.invalidate(recipeListProvider);
        ref.invalidate(ingredientsByIdProvider);
      },
      builder: (context, buyList) {
        if (buyList.groups.isEmpty && buyList.skipped.isEmpty) {
          return const _EmptyShoppingList();
        }
        return ListView(
          children: [
            if (buyList.skipped.isNotEmpty)
              _SkippedBadge(items: buyList.skipped),
            for (final group in buyList.groups)
              ShoppingCategorySection(group: group),
          ],
        );
      },
    );
  }
}

class _EmptyShoppingList extends StatelessWidget {
  const _EmptyShoppingList();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('ya tenés todo lo necesario'));
  }
}

/// Renders [items] as named diagnostics, grouped by [SkipReason] — e.g.
/// "Necesitan factor: espinaca, escarola" — instead of a bare skipped
/// count.
class _SkippedBadge extends StatelessWidget {
  const _SkippedBadge({required this.items});

  final List<SkippedItem> items;

  @override
  Widget build(BuildContext context) {
    final needsFactorNames = [
      for (final item in items)
        if (item.reason == SkipReason.needsFactor) item.name,
    ];
    final otherNames = [
      for (final item in items)
        if (item.reason == SkipReason.other) item.name,
    ];

    final lines = [
      if (needsFactorNames.isNotEmpty)
        'Necesitan factor: ${needsFactorNames.join(', ')}',
      if (otherNames.isNotEmpty)
        'No se pudieron calcular: ${otherNames.join(', ')}',
    ];

    final textStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error);

    return Padding(
      padding: MenuarioSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final line in lines) Text(line, style: textStyle)],
      ),
    );
  }
}
