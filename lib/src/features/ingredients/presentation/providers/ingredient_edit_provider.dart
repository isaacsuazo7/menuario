import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/shared/shared.dart';

/// The [Ingredient] being edited by [id], or `null` for a `null` id
/// (create mode short-circuits without hitting the repository).
///
/// `retry: null` — see [FailureException] note on `recipeListProvider`.
final ingredientEditProvider =
    FutureProvider.autoDispose.family<Ingredient?, String?>(
  (ref, id) async {
    if (id == null) return null;

    final repository = ref.watch(ingredientRepositoryProvider);
    final result = await repository.getById(id);
    return result.fold(
      (failure) => throw FailureException(failure),
      (ingredient) => ingredient,
    );
  },
  dependencies: [ingredientRepositoryProvider],
  retry: (retryCount, error) => null,
);
