import 'package:dartz/dartz.dart' hide Unit;
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/entities/recipe.dart';

/// Persistence port for [Recipe]s.
///
/// Pure abstract contract: no Flutter/Firebase dependency, no
/// implementation. A concrete `RecipeRepositoryImpl` (backed by Firestore)
/// is added in a later data-layer change.
abstract class RecipeRepository {
  /// Looks up a single [Recipe] by [id].
  Future<Either<Failure, Recipe>> getById(String id);

  /// Returns every stored [Recipe].
  Future<Either<Failure, List<Recipe>>> list();

  /// Creates or updates [recipe] (upsert by [Recipe.id]).
  Future<Either<Failure, void>> save(Recipe recipe);
}
