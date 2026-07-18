import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/recipes/presentation/providers/ingredients_by_id_provider.dart';
import 'package:menuario/src/features/week/presentation/widgets/_meal_slot_style.dart';
import 'package:menuario/src/shared/shared.dart';

/// Read-only "all at hand" bottom sheet for a Hoy row: emoji, name and
/// ingredients, plus a single "Ver receta" action.
///
/// Unlike `RecipeDetailSheet` (Semana's sheet), Hoy is a read-only lens over
/// the existing `WeekPlan` — this sheet never imports `PlanController` and
/// carries no "Cambiar"/"Quitar" actions.
class TodayMealDetailSheet extends ConsumerWidget {
  const TodayMealDetailSheet({
    super.key,
    required this.recipe,
    required this.mealSlot,
  });

  /// The recipe to display.
  final Recipe recipe;

  /// The slot this recipe is planned into, driving the emoji tile's accent.
  final MealSlot mealSlot;

  /// Closes this sheet and pushes the full recipe-detail route (Recetario's
  /// deep-linkable `/recipes/:id`).
  void _handleVerReceta(BuildContext context) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.pushNamed(
      ShellRoutes.recipeDetailName,
      pathParameters: {'id': recipe.id},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: MenuarioSpacing.paddingAll16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(slot: mealSlot, recipe: recipe),
            MenuarioSpacing.gapV16,
            if (recipe.bomLines.isNotEmpty) ...[
              Text('Ingredientes', style: MenuarioTypography.h6),
              MenuarioSpacing.gapV8,
              _Ingredients(recipe: recipe),
              MenuarioSpacing.gapV16,
            ],
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => _handleVerReceta(context),
                child: const Text('Ver receta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.slot, required this.recipe});

  final MealSlot slot;
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MealEmojiTile(slot: slot, emoji: recipe.emoji ?? '🍽️', filled: true),
        MenuarioSpacing.gapH16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(recipe.name, style: MenuarioTypography.h4),
              if (recipe.mealType != null) ...[
                MenuarioSpacing.gapV4,
                Align(
                  alignment: Alignment.centerLeft,
                  child: MealTypeTag(mealType: recipe.mealType!),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The recipe's bill of materials, ingredient names resolved best-effort via
/// [ingredientsByIdProvider]. While it loads (or if it fails), each line
/// still shows its quantity, so the sheet never blocks on ingredient data.
///
/// Mirrors `_recipe_detail_sheet.dart`'s `_Ingredients` — kept as a
/// deliberate copy (not a shared widget) so Hoy's read-only sheet has zero
/// coupling to Semana's mutable sheet.
class _Ingredients extends ConsumerWidget {
  const _Ingredients({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredientsById = ref
        .watch(ingredientsByIdProvider)
        .maybeWhen(
          data: (map) => map,
          orElse: () => const <String, Ingredient>{},
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in recipe.bomLines)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                EmojiAvatar(
                  emoji: ingredientsById[line.ingredientId]?.emoji ?? '•',
                  size: 32,
                ),
                MenuarioSpacing.gapH8,
                Expanded(
                  child: Text(
                    ingredientsById[line.ingredientId]?.name ?? 'Ingrediente',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${line.quantity.value} ${line.quantity.unit.symbol}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
