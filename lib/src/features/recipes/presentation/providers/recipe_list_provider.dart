import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/shared/shared.dart';

/// Every stored [Recipe], loaded once per container/session.
///
/// Un [AsyncNotifierProvider] (y no un [FutureProvider]) porque
/// [RecipeListNotifier.upsertRecipe] necesita estado MUTABLE para parchear
/// la lista en sitio tras guardar desde el formulario, que es una ruta raíz
/// — mismo motivo que `pantryControllerProvider`.
///
/// `retry: null` disables Riverpod's default automatic-retry-with-backoff:
/// the UI already offers an explicit "Reintentar" action
/// ([AppAsyncValueWidget]'s `onRetry`), so a failure must surface as
/// [AsyncError] immediately instead of silently retrying for seconds.
final recipeListProvider =
    AsyncNotifierProvider<RecipeListNotifier, List<Recipe>>(
      RecipeListNotifier.new,
      dependencies: [recipeRepositoryProvider],
      retry: (retryCount, error) => null,
    );

/// Carga el recetario completo y expone el upsert en sitio que reemplaza a
/// la invalidación cruzada entre rutas.
class RecipeListNotifier extends AsyncNotifier<List<Recipe>> {
  @override
  Future<List<Recipe>> build() async {
    final repository = ref.watch(recipeRepositoryProvider);
    final result = await repository.list();
    return result.fold(
      (failure) => throw FailureException(failure),
      (recipes) => recipes,
    );
  }

  /// Inserta o reemplaza [recipe] tras guardarla desde el formulario, sin
  /// recargar el recetario entero.
  ///
  /// Se parchea en sitio (`state = ...`) en lugar de invalidar el provider
  /// desde otra ruta: el formulario es una ruta raíz y sus consumidores
  /// (Hoy, Semana, Recetario) viven en ramas del shell que go_router pausa
  /// con `TickerMode`. Con todas sus suscripciones pausadas el elemento
  /// queda `isActive == false`, el scheduler NO lo reconstruye y el
  /// siguiente build de esa rama lo hace a mitad de frame -> `setState
  /// during build`. Reemplaza en su posición actual (o agrega al final si
  /// es nueva), así el orden de la lista se mantiene estable.
  void upsertRecipe(Recipe recipe) {
    final current = state.value;
    if (current == null) return;

    final exists = current.any((candidate) => candidate.id == recipe.id);

    state = AsyncData(
      exists
          ? [
              for (final candidate in current)
                candidate.id == recipe.id ? recipe : candidate,
            ]
          : [...current, recipe],
    );
  }
}
