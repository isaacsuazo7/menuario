import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/shared/shared.dart';

/// Owns the Despensa's pantry list and its optimistic mutations.
///
/// A single `AsyncNotifier` (not a plain `FutureProvider`) because
/// [adjustStock]/[toggleHave] need MUTABLE list state to patch optimistically
/// before `save()` resolves. This is the app's first mutation surface.
final pantryControllerProvider =
    AsyncNotifierProvider<PantryController, List<PantryRow>>(
      PantryController.new,
      dependencies: [pantryRepositoryProvider, ingredientRepositoryProvider],
      // Disables Riverpod's default automatic-retry-with-backoff so a load
      // failure surfaces as `AsyncError` immediately — see the matching note
      // on `recipeListProvider`/`ingredientsByIdProvider`.
      retry: (retryCount, error) => null,
    );

/// Loads the pantry (resolved with ingredient display data) and exposes
/// optimistic, per-item stock/have-flag edits with functional rollback.
class PantryController extends AsyncNotifier<List<PantryRow>> {
  @override
  Future<List<PantryRow>> build() async {
    final pantryRepository = ref.watch(pantryRepositoryProvider);
    final ingredientRepository = ref.watch(ingredientRepositoryProvider);

    final itemsResult = await pantryRepository.list();
    final items = itemsResult.fold(
      (failure) => throw FailureException(failure),
      (items) => items,
    );

    final ingredientsResult = await ingredientRepository.list();
    final ingredientsById = ingredientsResult.fold(
      (failure) => throw FailureException(failure),
      (ingredients) => {
        for (final ingredient in ingredients) ingredient.id: ingredient,
      },
    );

    return [
      for (final item in items)
        if (ingredientsById[item.ingredientId] case final ingredient?)
          PantryRow(item: item, ingredient: ingredient),
    ];
  }

  /// Adjusts a quantity-tracked item's stock by [delta] stock units.
  ///
  /// Optimistically patches [state], persists via `save()`, and on
  /// `Left(Failure)` reverts ONLY that item (a per-item functional patch,
  /// never a whole-list replace) so a concurrent success on another item
  /// survives. Clamped so stock never goes negative; a delta that would go
  /// below 0 is a no-op (no state patch, no `save()` call).
  Future<Failure?> adjustStock(String ingredientId, num delta) async {
    final current = state.value;
    if (current == null) return null;

    final index = current.indexWhere(
      (row) => row.item.ingredientId == ingredientId,
    );
    if (index == -1) return null;

    final snapshot = current[index];
    final item = snapshot.item;
    if (item is! QuantityTrackedPantryItem) return null;

    final newValue = item.stock.value + delta;
    if (newValue < 0) return null;

    final patchedItem = item.copyWith(
      stock: Quantity(value: newValue, unit: item.stock.unit),
    );
    final patchedRow = PantryRow(
      item: patchedItem,
      ingredient: snapshot.ingredient,
    );

    state = AsyncData([
      for (final row in current)
        row.item.ingredientId == ingredientId ? patchedRow : row,
    ]);

    final repository = ref.read(pantryRepositoryProvider);
    final result = await repository.save(patchedItem);

    if (!ref.mounted) return null;

    return result.fold((failure) {
      _revert(ingredientId, snapshot);
      return failure;
    }, (_) => null);
  }

  /// Sets a quantity-tracked item's stock to the absolute [newValue] stock
  /// units (grams for mass, count for count) — the modal's persist path.
  ///
  /// Same optimistic-patch/persist/per-item-rollback shape as [adjustStock].
  /// No-op (no state patch, no `save()`) if the item is not
  /// [QuantityTrackedPantryItem], if [newValue] is unchanged from the
  /// current stock, or if [newValue] is negative.
  Future<Failure?> setStock(String ingredientId, num newValue) async {
    final current = state.value;
    if (current == null) return null;

    final index = current.indexWhere(
      (row) => row.item.ingredientId == ingredientId,
    );
    if (index == -1) return null;

    final snapshot = current[index];
    final item = snapshot.item;
    if (item is! QuantityTrackedPantryItem) return null;

    if (newValue < 0) return null;
    if (newValue == item.stock.value) return null;

    final patchedItem = item.copyWith(
      stock: Quantity(value: newValue, unit: item.stock.unit),
    );
    final patchedRow = PantryRow(
      item: patchedItem,
      ingredient: snapshot.ingredient,
    );

    state = AsyncData([
      for (final row in current)
        row.item.ingredientId == ingredientId ? patchedRow : row,
    ]);

    final repository = ref.read(pantryRepositoryProvider);
    final result = await repository.save(patchedItem);

    if (!ref.mounted) return null;

    return result.fold((failure) {
      _revert(ingredientId, snapshot);
      return failure;
    }, (_) => null);
  }

  /// Flips a boolean-tracked item's have/don't-have flag.
  ///
  /// Same optimistic-patch/persist/per-item-rollback shape as [adjustStock].
  Future<Failure?> toggleHave(String ingredientId) async {
    final current = state.value;
    if (current == null) return null;

    final index = current.indexWhere(
      (row) => row.item.ingredientId == ingredientId,
    );
    if (index == -1) return null;

    final snapshot = current[index];
    final item = snapshot.item;
    if (item is! BooleanTrackedPantryItem) return null;

    final patchedItem = item.copyWith(haveIt: !item.haveIt);
    final patchedRow = PantryRow(
      item: patchedItem,
      ingredient: snapshot.ingredient,
    );

    state = AsyncData([
      for (final row in current)
        row.item.ingredientId == ingredientId ? patchedRow : row,
    ]);

    final repository = ref.read(pantryRepositoryProvider);
    final result = await repository.save(patchedItem);

    if (!ref.mounted) return null;

    return result.fold((failure) {
      _revert(ingredientId, snapshot);
      return failure;
    }, (_) => null);
  }

  /// Inserta o reemplaza la fila de [ingredient] tras guardarlo desde el
  /// formulario del catálogo, sin recargar la despensa entera.
  ///
  /// Se parchea en sitio (`state = ...`) en lugar de invalidar el provider
  /// desde otra pantalla: la invalidación deja el elemento sucio mientras
  /// la rama del shell está pausada por `TickerMode`, y el siguiente build
  /// de la Despensa lo vacía a mitad de frame -> `setState during build`.
  /// Reemplaza en su posición actual (o agrega al final si es nuevo), así
  /// el orden de la lista se mantiene estable.
  void upsertRow({required Ingredient ingredient, required PantryItem item}) {
    final current = state.value;
    if (current == null) return;

    final row = PantryRow(item: item, ingredient: ingredient);
    final exists = current.any(
      (candidate) => candidate.item.ingredientId == ingredient.id,
    );

    state = AsyncData(
      exists
          ? [
              for (final candidate in current)
                candidate.item.ingredientId == ingredient.id ? row : candidate,
            ]
          : [...current, row],
    );
  }

  /// Patches [ingredientId]'s row back to [snapshot] against the LATEST
  /// state (not the pre-edit list), so a concurrent edit on another item
  /// that already landed is never clobbered.
  void _revert(String ingredientId, PantryRow snapshot) {
    final latest = state.value;
    if (latest == null) return;

    state = AsyncData([
      for (final row in latest)
        row.item.ingredientId == ingredientId ? snapshot : row,
    ]);
  }
}
