import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/shared/shared.dart';

/// A single [Recipe] by id, self-contained so the detail route stays
/// deep-linkable without depending on [recipeListProvider] first loading.
///
/// `retry: null` — see [FailureException] note on `recipeListProvider`.
final recipeDetailProvider = FutureProvider.autoDispose.family<Recipe, String>(
  (ref, id) async {
    final repository = ref.watch(recipeRepositoryProvider);
    final result = await repository.getById(id);
    return result.fold(
      (failure) => throw FailureException(failure),
      (recipe) => recipe,
    );
  },
  dependencies: [recipeRepositoryProvider],
  retry: (retryCount, error) => null,
);
