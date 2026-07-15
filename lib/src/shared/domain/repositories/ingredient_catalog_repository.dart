import 'package:dartz/dartz.dart' hide Unit;
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/entities/pantry_item.dart';

/// Coordinating persistence port for the atomic `Ingredient` +
/// `PantryItem` pair: both aggregates share the same id
/// (`ingredient.id == pantryItem.ingredientId`) and are written together in
/// one commit, so neither one can be persisted without the other.
abstract class IngredientCatalogRepository {
  /// Mints a fresh id, shared by both the ingredient and pantry docs of a
  /// new aggregate.
  String newId();

  /// Creates or updates [ingredient] and [pantryItem] atomically, under
  /// their shared id.
  Future<Either<Failure, void>> saveWithPantry({
    required Ingredient ingredient,
    required PantryItem pantryItem,
  });
}
