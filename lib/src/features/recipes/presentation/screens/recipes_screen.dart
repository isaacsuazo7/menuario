import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/recipes/presentation/providers/filtered_recipes_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_submission_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/selected_meal_type_provider.dart';
import 'package:menuario/src/shared/shared.dart';

/// The "Recetario" tab: a 2-column grid of recipes, filterable by
/// [MealType], with loading/error/empty states.
///
/// Rendered inside the shell's single [AppBar]; keeps its own [Scaffold]
/// (without an `appBar`) purely to provide the [Material] ancestor its
/// [ChoiceChip]/[Card] descendants require.
class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredRecipes = ref.watch(filteredRecipesProvider);

    return Scaffold(
      body: Column(
        children: [
          const _MealFilterChips(),
          Expanded(
            child: AppAsyncValueWidget<List<Recipe>>(
              value: filteredRecipes,
              onRetry: () => ref.invalidate(recipeListProvider),
              loadingBuilder: (context) => const _RecipeGridSkeleton(),
              builder: (context, recipes) {
                if (recipes.isEmpty) {
                  return const _EmptyRecipes();
                }
                return _RecipeGrid(recipes: recipes);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(RecipeRoutes.form),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MealFilterChips extends ConsumerWidget {
  const _MealFilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMealType = ref.watch(selectedMealTypeProvider);

    return Padding(
      padding: MenuarioSpacing.paddingAll8,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: const Text('Todas'),
              selected: selectedMealType == null,
              onSelected: (_) =>
                  ref.read(selectedMealTypeProvider.notifier).select(null),
            ),
            for (final mealType in MealType.values) ...[
              MenuarioSpacing.gapH8,
              ChoiceChip(
                label: Text(mealType.label),
                selected: selectedMealType == mealType,
                onSelected: (_) => ref
                    .read(selectedMealTypeProvider.notifier)
                    .select(mealType),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecipeGrid extends StatelessWidget {
  const _RecipeGrid({required this.recipes});

  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: MenuarioSpacing.paddingAll16,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: MenuarioSpacing.md,
        crossAxisSpacing: MenuarioSpacing.md,
        // Slightly taller than square so a 2-line name plus the meal chip
        // always fits without overflowing the cell.
        childAspectRatio: 0.85,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) => _RecipeCard(recipe: recipes[index]),
    );
  }
}

/// A disabled recipe stays reachable instead of vanishing from the grid: it
/// renders greyed (via [Opacity]) with a "Desactivada" marker chip, and
/// tapping it reactivates it in place (`enabled: true`, persisted through
/// [recipeSubmissionProvider]) rather than navigating to its detail — an
/// enabled card's tap still navigates as before.
class _RecipeCard extends ConsumerWidget {
  const _RecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => recipe.enabled
            ? context.pushNamed(
                ShellRoutes.recipeDetailName,
                pathParameters: {'id': recipe.id},
              )
            : ref
                  .read(recipeSubmissionProvider.notifier)
                  .submit(recipe.copyWith(enabled: true)),
        child: Opacity(
          opacity: recipe.enabled ? 1.0 : 0.5,
          child: Padding(
            padding: MenuarioSpacing.paddingAll16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(recipe.emoji ?? '🍽️', style: MenuarioTypography.h2),
                MenuarioSpacing.gapV4,
                Text(
                  recipe.name,
                  style: MenuarioTypography.h6,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (recipe.mealType != null) ...[
                  MenuarioSpacing.gapV4,
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Chip(
                      label: Text(recipe.mealType!.label),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
                if (!recipe.enabled) ...[
                  MenuarioSpacing.gapV4,
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Chip(
                      label: const Text('Desactivada'),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.errorContainer,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeGridSkeleton extends StatelessWidget {
  const _RecipeGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: MenuarioSpacing.paddingAll16,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: MenuarioSpacing.md,
        crossAxisSpacing: MenuarioSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _EmptyRecipes extends StatelessWidget {
  const _EmptyRecipes();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: MenuarioSpacing.paddingAll16,
        child: const Text(
          'Aún no tienes recetas. Impórtalas o créalas desde el menú.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
