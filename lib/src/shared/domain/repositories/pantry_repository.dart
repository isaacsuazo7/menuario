import 'package:dartz/dartz.dart' hide Unit;
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/entities/pantry_item.dart';

/// Persistence port for [PantryItem]s.
///
/// Pure abstract contract: no Flutter/Firebase dependency, no
/// implementation. A concrete `PantryRepositoryImpl` (backed by Firestore)
/// is added in a later data-layer change.
abstract class PantryRepository {
  /// Looks up a single [PantryItem] by its ingredient id.
  Future<Either<Failure, PantryItem>> getById(String ingredientId);

  /// Returns every stored [PantryItem] (the full pantry).
  Future<Either<Failure, List<PantryItem>>> list();

  /// Creates or updates [pantryItem] (upsert by ingredient id).
  Future<Either<Failure, void>> save(PantryItem pantryItem);
}
