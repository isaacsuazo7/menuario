import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/data/datasources/ingredient_catalog_data_source.dart';
import 'package:menuario/src/shared/data/models/ingredient_dto.dart';
import 'package:menuario/src/shared/data/models/pantry_item_dto.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/entities/pantry_item.dart';
import 'package:menuario/src/shared/domain/repositories/ingredient_catalog_repository.dart';

/// [IngredientCatalogRepository] port implementation backed by
/// [IngredientCatalogDataSource].
class IngredientCatalogRepositoryImpl implements IngredientCatalogRepository {
  final IngredientCatalogDataSource _dataSource;

  IngredientCatalogRepositoryImpl({
    required IngredientCatalogDataSource dataSource,
  }) : _dataSource = dataSource; // ignore: prefer_initializing_formals

  @override
  String newId() => _dataSource.newId();

  @override
  Future<Either<Failure, void>> saveWithPantry({
    required Ingredient ingredient,
    required PantryItem pantryItem,
  }) {
    return _dataSource.saveWithPantry(
      ingredient.id,
      IngredientDTO.fromEntity(ingredient),
      PantryItemDTO.fromEntity(pantryItem),
    );
  }
}

/// The [IngredientCatalogRepository] port, satisfied by
/// [IngredientCatalogRepositoryImpl].
final ingredientCatalogRepositoryProvider =
    Provider<IngredientCatalogRepository>(
      (ref) => IngredientCatalogRepositoryImpl(
        dataSource: ref.watch(ingredientCatalogDataSourceProvider),
      ),
      dependencies: [ingredientCatalogDataSourceProvider],
    );
