import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/category_colors.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredients_list_provider.dart';
import 'package:menuario/src/shared/shared.dart';

/// Ingredient-picker bottom sheet opened from the recipe form's BOM editor:
/// lists every EXISTING ingredient grouped by [Category] (mirrors
/// `ingredients_list_screen.dart`'s grouping) and pops with the tapped
/// ingredient's id on selection.
///
/// EVERY ingredient is selectable, boolean-mode ones included: a recipe
/// must be able to list everything it uses, and condiments/seeds are used
/// for real even though nobody weighs them. They become "al gusto" BOM
/// lines — no quantity, no unit (`recipeUnitsFor` returns `{}`) — and their
/// buy signal comes from the pantry's `haveIt` flag instead.
///
/// There is NO inline "create ingredient" action: ingredient creation is a
/// product decision reserved for the Ingredients screen. The old inline
/// escape hatch invalidated `ingredientsListProvider`/`ingredientsByIdProvider`
/// right after an awaited pushed route returned, which crashed with a
/// "setState/markNeedsBuild during build" error; removing the flow entirely
/// removes that crash site.
class RecipeIngredientPickerSheet extends ConsumerWidget {
  const RecipeIngredientPickerSheet({super.key});

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
          Flexible(
            child: AppAsyncValueWidget<List<Ingredient>>(
              value: ingredientsValue,
              builder: (context, selectable) {
                if (selectable.isEmpty) {
                  return const Padding(
                    padding: MenuarioSpacing.paddingAll16,
                    child: Text('Aún no tienes ingredientes.'),
                  );
                }
                return ListView(
                  shrinkWrap: true,
                  children: [
                    for (final group in _groupByCategory(selectable))
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
            leading: EmojiAvatar(emoji: ingredient.emoji ?? '🥄', size: 32),
            title: Text(ingredient.name),
            onTap: () => Navigator.of(context).pop(ingredient.id),
          ),
      ],
    );
  }
}
