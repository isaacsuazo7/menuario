import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/shared/shared.dart';

/// Every stored [Recipe], loaded once per container/session.
///
/// Unpaginated small list -> plain [FutureProvider] rather than an
/// [AsyncNotifierProvider]. Folds the repository's `Either<Failure, T>`
/// into a thrown [FailureException] at the provider boundary, matching the
/// shared `Either` -> `AsyncValue` pipeline.
///
/// `retry: null` disables Riverpod's default automatic-retry-with-backoff:
/// the UI already offers an explicit "Reintentar" action
/// ([AppAsyncValueWidget]'s `onRetry`), so a failure must surface as
/// [AsyncError] immediately instead of silently retrying for seconds.
final recipeListProvider = FutureProvider<List<Recipe>>(
  (ref) async {
    final repository = ref.watch(recipeRepositoryProvider);
    final result = await repository.list();
    return result.fold(
      (failure) => throw FailureException(failure),
      (recipes) => recipes,
    );
  },
  dependencies: [recipeRepositoryProvider],
  retry: (retryCount, error) => null,
);
