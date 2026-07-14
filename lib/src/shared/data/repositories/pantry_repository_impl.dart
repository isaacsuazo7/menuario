import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/data/datasources/pantry_data_source.dart';
import 'package:menuario/src/shared/data/models/pantry_item_dto.dart';
import 'package:menuario/src/shared/domain/entities/pantry_item.dart';
import 'package:menuario/src/shared/domain/repositories/pantry_repository.dart';

/// [PantryRepository] port implementation backed by [PantryDataSource].
class PantryRepositoryImpl implements PantryRepository {
  final PantryDataSource _dataSource;

  PantryRepositoryImpl({required PantryDataSource dataSource})
    : _dataSource = dataSource; // ignore: prefer_initializing_formals

  @override
  Future<Either<Failure, PantryItem>> getById(String ingredientId) async {
    final result = await _dataSource.getById(ingredientId);
    return result.map((dto) => dto.toEntity(ingredientId: ingredientId));
  }

  @override
  Future<Either<Failure, List<PantryItem>>> list() async {
    final result = await _dataSource.list();
    return result.map(
      (items) => items
          .map((item) => item.$2.toEntity(ingredientId: item.$1))
          .toList(),
    );
  }

  @override
  Future<Either<Failure, void>> save(PantryItem pantryItem) {
    return _dataSource.save(
      pantryItem.ingredientId,
      PantryItemDTO.fromEntity(pantryItem),
    );
  }
}

/// The [PantryRepository] port, satisfied by [PantryRepositoryImpl].
final pantryRepositoryProvider = Provider<PantryRepository>(
  (ref) =>
      PantryRepositoryImpl(dataSource: ref.watch(pantryDataSourceProvider)),
  dependencies: [pantryDataSourceProvider],
);
