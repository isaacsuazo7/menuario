import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/features/recipes/presentation/providers/filtered_recipes_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/ingredients_by_id_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_detail_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_edit_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/shared/shared.dart';

/// Drives the recipe create/edit save, exposing loading/error/success as
/// [AsyncValue].
///
/// On success invalidates every read surface a saved [Recipe] can affect:
/// the list/filtered grid, the ingredient lookup (BOM row names), AND the
/// saved id's own detail/edit providers — the last two close the "editing a
/// recipe leaves its open detail stale" gap (an inline video edit + save
/// used to leave `recipeDetailProvider(id)`/`recipeEditProvider(id)`
/// un-invalidated).
final recipeSubmissionProvider =
    NotifierProvider.autoDispose<RecipeSubmissionNotifier, AsyncValue<void>>(
      RecipeSubmissionNotifier.new,
      dependencies: [
        recipeRepositoryProvider,
        recipeListProvider,
        filteredRecipesProvider,
        ingredientsByIdProvider,
        recipeDetailProvider,
        recipeEditProvider,
      ],
    );

class RecipeSubmissionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> submit(Recipe recipe) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(recipeRepositoryProvider);
      final result = await repository.save(recipe);

      if (!ref.mounted) return;

      result.fold((failure) => throw FailureException(failure), (_) {
        state = const AsyncData(null);
        ref.invalidate(recipeListProvider);
        ref.invalidate(filteredRecipesProvider);
        ref.invalidate(ingredientsByIdProvider);
        ref.invalidate(recipeDetailProvider(recipe.id));
        ref.invalidate(recipeEditProvider(recipe.id));
      });
    } on FailureException catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    } on Exception catch (e, stackTrace) {
      state = AsyncError(
        FailureException(Failure(message: e.toString())),
        stackTrace,
      );
    }
  }
}
