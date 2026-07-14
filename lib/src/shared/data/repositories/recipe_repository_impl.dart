import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/data/datasources/recipe_data_source.dart';
import 'package:menuario/src/shared/data/models/recipe_dto.dart';
import 'package:menuario/src/shared/domain/entities/recipe.dart';
import 'package:menuario/src/shared/domain/repositories/recipe_repository.dart';

/// [RecipeRepository] port implementation backed by [RecipeDataSource].
///
/// Pure DTO<->Entity mapping: `Either` values are propagated from the
/// datasource unchanged.
class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeDataSource _dataSource;

  RecipeRepositoryImpl({required RecipeDataSource dataSource})
    : _dataSource = dataSource; // ignore: prefer_initializing_formals

  @override
  Future<Either<Failure, Recipe>> getById(String id) async {
    final result = await _dataSource.getById(id);
    try {
      return result.map((dto) => dto.toEntity(id: id));
    } on Object catch (exception, stackTrace) {
      return Left(Failure.malformedData(exception, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> list() async {
    final result = await _dataSource.list();
    try {
      return result.map(
        (items) =>
            items.map((item) => item.$2.toEntity(id: item.$1)).toList(),
      );
    } on Object catch (exception, stackTrace) {
      return Left(Failure.malformedData(exception, stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> save(Recipe recipe) {
    return _dataSource.save(recipe.id, RecipeDTO.fromEntity(recipe));
  }
}

/// The [RecipeRepository] port, satisfied by [RecipeRepositoryImpl].
final recipeRepositoryProvider = Provider<RecipeRepository>(
  (ref) =>
      RecipeRepositoryImpl(dataSource: ref.watch(recipeDataSourceProvider)),
  dependencies: [recipeDataSourceProvider],
);
