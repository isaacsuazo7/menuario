import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/core/theme/category_colors.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredients_list_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/ingredients_by_id_provider.dart';
import 'package:menuario/src/shared/shared.dart';

/// Ingredient-picker bottom sheet opened from the recipe form's BOM editor:
/// lists every stored [Ingredient] grouped by [Category] (mirrors
/// `ingredients_list_screen.dart`'s grouping), pops with the tapped
/// ingredient's id on selection, or offers an inline "＋ Nuevo ingrediente"
/// escape hatch that pushes [IngredientRoutes.form], and — once it returns a
/// newly-created id — invalidates the ingredient read surfaces and pops the
/// sheet with that id, auto-selecting it into the BOM line.
class RecipeIngredientPickerSheet extends ConsumerWidget {
  const RecipeIngredientPickerSheet({super.key});

  Future<void> _handleCreateIngredient(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final navigator = Navigator.of(context);
    final newId = await context.pushNamed<String?>(IngredientRoutes.form);
    if (newId == null) return;

    ref.invalidate(ingredientsListProvider);
    ref.invalidate(ingredientsByIdProvider);
    navigator.pop(newId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredientsValue = ref.watch(ingredientsListProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MenuarioSpacing.paddingAll16,
            child: Text('Elegí un ingrediente', style: MenuarioTypography.h4),
          ),
          ListTile(
            key: const Key('recipe-bom-create-ingredient'),
            leading: const Icon(Icons.add),
            title: const Text('＋ Nuevo ingrediente'),
            onTap: () => _handleCreateIngredient(context, ref),
          ),
          Flexible(
            child: AppAsyncValueWidget<List<Ingredient>>(
              value: ingredientsValue,
              builder: (context, ingredients) {
                if (ingredients.isEmpty) {
                  return const Padding(
                    padding: MenuarioSpacing.paddingAll16,
                    child: Text('Aún no tienes ingredientes.'),
                  );
                }
                return ListView(
                  shrinkWrap: true,
                  children: [
                    for (final group in _groupByCategory(ingredients))
                      _CategorySection(
                        category: group.category,
                        ingredients: group.ingredients,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientCategoryGroup {
  const _IngredientCategoryGroup({
    required this.category,
    required this.ingredients,
  });

  final Category category;
  final List<Ingredient> ingredients;
}

/// Buckets [ingredients] by [Category] in the enum's fixed declaration
/// order, omitting empty categories — mirrors
/// `ingredients_list_screen.dart`'s `_groupByCategory`.
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

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category, required this.ingredients});

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
            key: Key('recipe-bom-ingredient-option-${ingredient.id}'),
            leading: Text(ingredient.emoji ?? '🥄'),
            title: Text(ingredient.name),
            onTap: () => Navigator.of(context).pop(ingredient.id),
          ),
      ],
    );
  }
}
