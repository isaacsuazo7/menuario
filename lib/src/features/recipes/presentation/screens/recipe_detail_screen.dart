import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/recipes/presentation/providers/ingredients_by_id_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_detail_provider.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-screen recipe detail: header (emoji, name, meal-type chip) plus its
/// ingredients, each `BomLine` resolved to name/emoji/quantity via
/// [ingredientsByIdProvider].
class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  /// The [Recipe.id] to load and display.
  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeValue = ref.watch(recipeDetailProvider(recipeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de receta'),
        actions: [
          IconButton(
            key: const Key('recipe-detail-edit-button'),
            icon: const Icon(Icons.edit),
            onPressed: () => context.pushNamed(
              RecipeRoutes.form,
              queryParameters: {'id': recipeId},
            ),
          ),
        ],
      ),
      body: AppAsyncValueWidget<Recipe>(
        value: recipeValue,
        onRetry: () => ref.invalidate(recipeDetailProvider(recipeId)),
        builder: (context, recipe) {
          final ingredientsValue = ref.watch(ingredientsByIdProvider);

          return AppAsyncValueWidget<Map<String, Ingredient>>(
            value: ingredientsValue,
            onRetry: () => ref.invalidate(ingredientsByIdProvider),
            builder: (context, ingredientsById) => _RecipeDetailBody(
              recipe: recipe,
              ingredientsById: ingredientsById,
            ),
          );
        },
      ),
    );
  }
}

class _RecipeDetailBody extends StatelessWidget {
  const _RecipeDetailBody({
    required this.recipe,
    required this.ingredientsById,
  });

  final Recipe recipe;
  final Map<String, Ingredient> ingredientsById;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: MenuarioSpacing.paddingAll16,
      children: [
        _RecipeHeader(recipe: recipe),
        MenuarioSpacing.gapV24,
        Text('Ingredientes', style: MenuarioTypography.h5),
        MenuarioSpacing.gapV8,
        for (final bomLine in recipe.bomLines)
          _IngredientRow(
            bomLine: bomLine,
            ingredient: ingredientsById[bomLine.ingredientId],
          ),
        if (recipe.videos.isNotEmpty) ...[
          MenuarioSpacing.gapV24,
          Text('Videos', style: MenuarioTypography.h5),
          MenuarioSpacing.gapV8,
          for (final video in recipe.videos) _VideoRow(video: video),
        ],
      ],
    );
  }
}

class _VideoRow extends StatelessWidget {
  const _VideoRow({required this.video});

  final VideoLink video;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.play_circle_outline),
      title: Text(video.url),
      subtitle: Text(video.source.label),
      onTap: () => launchUrl(Uri.parse(video.url)),
    );
  }
}

class _RecipeHeader extends StatelessWidget {
  const _RecipeHeader({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(recipe.emoji ?? '🍽️', style: MenuarioTypography.h1),
        MenuarioSpacing.gapV8,
        Text(
          recipe.name,
          style: MenuarioTypography.h3,
          textAlign: TextAlign.center,
        ),
        if (recipe.mealType != null) ...[
          MenuarioSpacing.gapV8,
          Chip(label: Text(recipe.mealType!.label)),
        ],
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.bomLine, required this.ingredient});

  final BomLine bomLine;
  final Ingredient? ingredient;

  @override
  Widget build(BuildContext context) {
    final ingredient = this.ingredient;
    if (ingredient == null) {
      return ListTile(
        leading: const Text('❔', style: MenuarioTypography.h4),
        title: const Text('Ingrediente no encontrado'),
      );
    }

    return ListTile(
      leading: Text(ingredient.emoji ?? '🥄', style: MenuarioTypography.h4),
      title: Text(ingredient.name),
      trailing: Text(
        '${bomLine.quantity.value} ${bomLine.quantity.unit.symbol}',
      ),
    );
  }
}
