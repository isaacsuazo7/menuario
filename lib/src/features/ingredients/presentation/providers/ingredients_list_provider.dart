import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/shared/shared.dart';

/// Every stored [Ingredient], loaded once per container/session.
///
/// Un [AsyncNotifierProvider] (y no un [FutureProvider]) porque
/// [IngredientListNotifier.upsertIngredient] necesita estado MUTABLE para
/// parchear el catálogo en sitio tras guardarlo desde el formulario, que es
/// una ruta raíz — mismo motivo que `recipeListProvider`.
///
/// `retry: null` disables Riverpod's default automatic-retry-with-backoff:
/// the UI already offers an explicit "Reintentar" action
/// ([AppAsyncValueWidget]'s `onRetry`), so a failure must surface as
/// [AsyncError] immediately instead of silently retrying for seconds.
final ingredientsListProvider =
    AsyncNotifierProvider<IngredientListNotifier, List<Ingredient>>(
      IngredientListNotifier.new,
      dependencies: [ingredientRepositoryProvider],
      retry: (retryCount, error) => null,
    );

/// Carga el catálogo completo y expone el upsert en sitio que reemplaza a
/// la invalidación cruzada entre rutas.
class IngredientListNotifier extends AsyncNotifier<List<Ingredient>> {
  @override
  Future<List<Ingredient>> build() async {
    final repository = ref.watch(ingredientRepositoryProvider);
    final result = await repository.list();
    return result.fold(
      (failure) => throw FailureException(failure),
      (ingredients) => ingredients,
    );
  }

  /// Inserta o reemplaza [ingredient] tras guardarlo desde el formulario,
  /// sin recargar el catálogo entero.
  ///
  /// Mismo motivo que `RecipeListNotifier.upsertRecipe`: invalidar desde
  /// una ruta raíz deja el elemento sucio mientras las ramas del shell
  /// están pausadas por `TickerMode` y estalla en su siguiente build.
  /// `ingredientsByIdProvider` deriva de este provider, así que el parche
  /// también lo alcanza sin invalidarlo.
  void upsertIngredient(Ingredient ingredient) {
    final current = state.value;
    if (current == null) return;

    final exists = current.any((candidate) => candidate.id == ingredient.id);

    state = AsyncData(
      exists
          ? [
              for (final candidate in current)
                candidate.id == ingredient.id ? ingredient : candidate,
            ]
          : [...current, ingredient],
    );
  }
}
