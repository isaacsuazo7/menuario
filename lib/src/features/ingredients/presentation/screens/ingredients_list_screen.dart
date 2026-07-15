import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/core/theme/category_colors.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredients_list_provider.dart';
import 'package:menuario/src/shared/shared.dart';

/// The drawer-reached "Ingredientes" screen: every stored [Ingredient],
/// grouped by [Category] (mirroring the Despensa grouping), with a FAB and
/// row-tap both opening [IngredientRoutes.form] — empty for create, with
/// the tapped ingredient's id for edit.
///
/// Top-level route (not nested inside the shell), so it keeps its own
/// [AppBar] and back button.
class IngredientsListScreen extends ConsumerWidget {
  const IngredientsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredientsValue = ref.watch(ingredientsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ingredientes')),
      body: AppAsyncValueWidget<List<Ingredient>>(
        value: ingredientsValue,
        onRetry: () => ref.invalidate(ingredientsListProvider),
        builder: (context, ingredients) {
          if (ingredients.isEmpty) {
            return const _EmptyIngredients();
          }
          return ListView(
            children: [
              for (final group in _groupByCategory(ingredients))
                _IngredientCategorySection(
                  category: group.category,
                  ingredients: group.ingredients,
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(IngredientRoutes.form),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// A fixed-order [Category] bucket of [Ingredient]s for the grouped list.
class _IngredientCategoryGroup {
  const _IngredientCategoryGroup({
    required this.category,
    required this.ingredients,
  });

  final Category category;
  final List<Ingredient> ingredients;
}

/// Buckets [ingredients] by [Category] in the enum's fixed declaration
/// order, omitting empty categories — mirrors `pantryGroupsProvider`.
List<_IngredientCategoryGroup> _groupByCategory(List<Ingredient> ingredients) {
  return [
    for (final category in Category.values)
      if (ingredients.where((i) => i.category == category).toList()
          case final categoryIngredients when categoryIngredients.isNotEmpty)
        _IngredientCategoryGroup(
          category: category,
          ingredients: categoryIngredients,
        ),
  ];
}

class _IngredientCategorySection extends StatelessWidget {
  const _IngredientCategorySection({
    required this.category,
    required this.ingredients,
  });

  final Category category;
  final List<Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<MenuarioCategoryColors>();
    final color =
        palette?.colorFor(
          category,
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
              Text(category.label, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
        for (final ingredient in ingredients)
          ListTile(
            leading: Text(ingredient.emoji ?? '🥄'),
            title: Text(ingredient.name),
            onTap: () => context.pushNamed(
              IngredientRoutes.form,
              queryParameters: {'id': ingredient.id},
            ),
          ),
      ],
    );
  }
}

class _EmptyIngredients extends StatelessWidget {
  const _EmptyIngredients();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: MenuarioSpacing.paddingAll16,
        child: const Text(
          'Aún no tienes ingredientes. Créalos con el botón +.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
