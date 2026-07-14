import 'package:dartz/dartz.dart' hide Unit;
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';

/// Persistence port for [Ingredient]s.
///
/// Pure abstract contract: no Flutter/Firebase dependency, no
/// implementation. A concrete `IngredientRepositoryImpl` (backed by
/// Firestore) is added in a later data-layer change.
abstract class IngredientRepository {
  /// Looks up a single [Ingredient] by [id].
  Future<Either<Failure, Ingredient>> getById(String id);

  /// Returns every stored [Ingredient].
  Future<Either<Failure, List<Ingredient>>> list();

  /// Creates or updates [ingredient] (upsert by [Ingredient.id]).
  Future<Either<Failure, void>> save(Ingredient ingredient);
}
