import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/data/datasources/ingredient_data_source.dart';
import 'package:menuario/src/shared/data/models/ingredient_dto.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/repositories/ingredient_repository.dart';

/// [IngredientRepository] port implementation backed by
/// [IngredientDataSource].
class IngredientRepositoryImpl implements IngredientRepository {
  final IngredientDataSource _dataSource;

  IngredientRepositoryImpl({required IngredientDataSource dataSource})
    : _dataSource = dataSource; // ignore: prefer_initializing_formals

  @override
  Future<Either<Failure, Ingredient>> getById(String id) async {
    final result = await _dataSource.getById(id);
    try {
      return result.map((dto) => dto.toEntity(id: id));
    } on Object catch (exception, stackTrace) {
      return Left(Failure.malformedData(exception, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<Ingredient>>> list() async {
    final result = await _dataSource.list();
    try {
      return result.map(
        (items) => items.map((item) => item.$2.toEntity(id: item.$1)).toList(),
      );
    } on Object catch (exception, stackTrace) {
      return Left(Failure.malformedData(exception, stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> save(Ingredient ingredient) {
    return _dataSource.save(
      ingredient.id,
      IngredientDTO.fromEntity(ingredient),
    );
  }
}

/// The [IngredientRepository] port, satisfied by [IngredientRepositoryImpl].
final ingredientRepositoryProvider = Provider<IngredientRepository>(
  (ref) => IngredientRepositoryImpl(
    dataSource: ref.watch(ingredientDataSourceProvider),
  ),
  dependencies: [ingredientDataSourceProvider],
);
