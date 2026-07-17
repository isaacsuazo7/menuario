import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/shared/shared.dart';

/// The [PantryItem] being edited by [id] (an ingredient id), or `null` for
/// a `null` id (create mode short-circuits without hitting the repository).
///
/// `retry: null` — see [FailureException] note on `ingredientEditProvider`.
final ingredientPantryEditProvider =
    FutureProvider.autoDispose.family<PantryItem?, String?>(
      (ref, id) async {
        if (id == null) return null;

        final repository = ref.watch(pantryRepositoryProvider);
        final result = await repository.getById(id);
        return result.fold(
          (failure) => throw FailureException(failure),
          (pantryItem) => pantryItem,
        );
      },
      dependencies: [pantryRepositoryProvider],
      retry: (retryCount, error) => null,
    );
