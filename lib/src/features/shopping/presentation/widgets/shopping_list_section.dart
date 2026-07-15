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
/// a skipped-count badge when a per-ingredient calculation failed.
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
              _SkippedBadge(count: buyList.skipped.length),
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

class _SkippedBadge extends StatelessWidget {
  const _SkippedBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count == 1
        ? '1 artículo no se pudo calcular'
        : '$count artículos no se pudieron calcular';

    return Padding(
      padding: MenuarioSpacing.paddingAll16,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
