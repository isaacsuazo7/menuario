import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/shared/shared.dart';

/// Every stored [Ingredient], keyed by [Ingredient.id] for O(1) `BomLine`
/// resolution.
///
/// `retry: null` — see [FailureException] note on `recipeListProvider`.
final ingredientsByIdProvider = FutureProvider<Map<String, Ingredient>>(
  (ref) async {
    final repository = ref.watch(ingredientRepositoryProvider);
    final result = await repository.list();
    return result.fold(
      (failure) => throw FailureException(failure),
      (ingredients) => {
        for (final ingredient in ingredients) ingredient.id: ingredient,
      },
    );
  },
  dependencies: [ingredientRepositoryProvider],
  retry: (retryCount, error) => null,
);
