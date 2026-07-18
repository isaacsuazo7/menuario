import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/recipes/presentation/providers/ingredients_by_id_provider.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';
import 'package:menuario/src/features/week/presentation/widgets/_meal_slot_style.dart';
import 'package:menuario/src/features/week/presentation/widgets/_recipe_picker_sheet.dart';
import 'package:menuario/src/shared/shared.dart';

/// Bottom sheet opened by tapping a FILLED slot: shows the planned recipe
/// "all at hand" (emoji, name, meal-type, its ingredients) plus the three
/// slot actions — Ver receta / Cambiar / Quitar.
///
/// Mirrors `SetStockSheet`'s shape: reads the notifier, pops immediately,
/// then awaits the mutation and shows a `SnackBar` on `Failure`. Empty and
/// dangling slots never reach here — the parent routes those to the picker.
class RecipeDetailSheet extends ConsumerWidget {
  const RecipeDetailSheet({
    super.key,
    required this.day,
    required this.mealSlot,
    required this.recipe,
    required this.entry,
  });

  /// The day of the slot being viewed.
  final DayOfWeek day;

  /// The slot being viewed.
  final MealSlot mealSlot;

  /// The recipe currently planned in the slot (always non-null here).
  final Recipe recipe;

  /// The slot's current entry, forwarded to the picker on "Cambiar".
  final PlanEntry entry;

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

  /// Closes this sheet and reopens the picker for the same slot, reusing the
  /// existing assign flow (the picker shows "Quitar" because [entry] exists).
  void _handleCambiar(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    showModalBottomSheet<void>(
      context: navigator.context,
      isScrollControlled: true,
      builder: (_) =>
          RecipePickerSheet(day: day, mealSlot: mealSlot, currentEntry: entry),
    );
  }

  /// Clears the slot via [PlanController.clear], mirroring the picker's
  /// optimistic-then-toast idiom.
  Future<void> _handleQuitar(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(planControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();

    final failure = await notifier.clear(day: day, mealSlot: mealSlot);

    if (failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
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
            _Actions(
              onVerReceta: () => _handleVerReceta(context),
              onCambiar: () => _handleCambiar(context),
              onQuitar: () => _handleQuitar(context, ref),
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

/// The recipe's bill of materials, ingredient names resolved best-effort
/// via [ingredientsByIdProvider]. While it loads (or if it fails), each line
/// still shows its quantity, so the sheet never blocks on ingredient data.
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
                  bomQuantityLabel(line.quantity),
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

class _Actions extends StatelessWidget {
  const _Actions({
    required this.onVerReceta,
    required this.onCambiar,
    required this.onQuitar,
  });

  final VoidCallback onVerReceta;
  final VoidCallback onCambiar;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: onQuitar,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Quitar'),
        ),
        const Spacer(),
        TextButton(onPressed: onVerReceta, child: const Text('Ver receta')),
        MenuarioSpacing.gapH8,
        FilledButton(onPressed: onCambiar, child: const Text('Cambiar')),
      ],
    );
  }
}
