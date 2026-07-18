import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/shared/shared.dart';

/// Drives the recipe create/edit save, exposing loading/error/success as
/// [AsyncValue].
///
/// En éxito NO invalida nada: parchea la receta guardada dentro de
/// [recipeListProvider], y de ahí se propaga por `ref.watch` al resto de
/// superficies de lectura ([filteredRecipesProvider] y
/// [recipeDetailProvider] derivan de la lista). El formulario es una ruta
/// raíz y sus consumidores viven en ramas del shell pausadas por
/// `TickerMode`: una invalidación cruzada quedaría pendiente ahí y estalla
/// en el siguiente build (`setState during build`).
final recipeSubmissionProvider =
    NotifierProvider.autoDispose<RecipeSubmissionNotifier, AsyncValue<void>>(
      RecipeSubmissionNotifier.new,
      dependencies: [recipeRepositoryProvider, recipeListProvider],
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
        // Solo si el recetario ya está montado: leer su notifier cuando no
        // existe dispararía una carga completa innecesaria, y su primera
        // carga ya traería la receta recién guardada.
        if (ref.exists(recipeListProvider)) {
          ref.read(recipeListProvider.notifier).upsertRecipe(recipe);
        }
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
