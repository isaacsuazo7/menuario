import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/shared/shared.dart';

/// A single [Recipe] by id, self-contained so the detail route stays
/// deep-linkable without depending on [recipeListProvider] first loading.
///
/// Si el recetario YA está cargado se lee de ahí (`ref.exists` + `watch`,
/// el patrón documentado de Riverpod para no repetir una carga que otro
/// provider ya hizo): así el upsert en sitio tras editar llega al detalle
/// por propagación, sin invalidarlo desde el formulario — que es una ruta
/// raíz y dejaría este provider sucio mientras la pantalla de detalle está
/// pausada debajo. Si el recetario no está cargado (deep link), se
/// consulta el repositorio como antes.
///
/// `retry: null` — see [FailureException] note on `recipeListProvider`.
final recipeDetailProvider = FutureProvider.autoDispose.family<Recipe, String>(
  (ref, id) async {
    if (ref.exists(recipeListProvider)) {
      final recipes = await ref.watch(recipeListProvider.future);
      for (final recipe in recipes) {
        if (recipe.id == id) return recipe;
      }
    }

    final repository = ref.watch(recipeRepositoryProvider);
    final result = await repository.getById(id);
    return result.fold(
      (failure) => throw FailureException(failure),
      (recipe) => recipe,
    );
  },
  dependencies: [recipeRepositoryProvider, recipeListProvider],
  retry: (retryCount, error) => null,
);
