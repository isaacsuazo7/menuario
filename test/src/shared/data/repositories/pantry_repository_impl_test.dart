import 'package:dartz/dartz.dart' hide Unit;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/data/datasources/pantry_data_source.dart';
import 'package:menuario/src/shared/data/models/pantry_item_dto.dart';
import 'package:menuario/src/shared/data/repositories/pantry_repository_impl.dart';
import 'package:menuario/src/shared/domain/entities/pantry_item.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  group('PantryRepositoryImpl', () {
    late FakeFirebaseFirestore firestore;
    late PantryDataSource dataSource;
    late PantryRepositoryImpl repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      dataSource = PantryDataSourceImpl(firestore: firestore, uid: 'uid-A');
      repository = PantryRepositoryImpl(dataSource: dataSource);
    });

    test('save then getById round-trips a quantity-tracked PantryItem, '
        'ingredientId preserved', () async {
      // Arrange
      const item = PantryItem.quantityTracked(
        ingredientId: 'ingredient-avena',
        category: Category.cereal,
        stock: Quantity(value: 340, unit: Unit.gram),
      );

      // Act
      final saveResult = await repository.save(item);
      final getResult = await repository.getById('ingredient-avena');

      // Assert
      expect(saveResult, const Right<Failure, void>(null));
      getResult.fold(
        (failure) => fail('expected Right, got Left($failure)'),
        (read) => expect(read, item),
      );
    });

    test('save then getById round-trips a boolean-tracked PantryItem, '
        'ingredientId preserved', () async {
      // Arrange
      const item = PantryItem.booleanTracked(
        ingredientId: 'ingredient-comino',
        category: Category.condimento,
        haveIt: true,
      );

      // Act
      final saveResult = await repository.save(item);
      final getResult = await repository.getById('ingredient-comino');

      // Assert
      expect(saveResult, const Right<Failure, void>(null));
      getResult.fold(
        (failure) => fail('expected Right, got Left($failure)'),
        (read) => expect(read, item),
      );
    });

    test('list returns every saved PantryItem as entities', () async {
      // Arrange
      const first = PantryItem.quantityTracked(
        ingredientId: 'ingredient-avena',
        category: Category.cereal,
        stock: Quantity(value: 340, unit: Unit.gram),
      );
      const second = PantryItem.booleanTracked(
        ingredientId: 'ingredient-comino',
        category: Category.condimento,
        haveIt: false,
      );
      await repository.save(first);
      await repository.save(second);

      // Act
      final result = await repository.list();

      // Assert
      result.fold(
        (failure) => fail('expected Right, got Left($failure)'),
        (items) => expect(items.toSet(), {first, second}),
      );
    });

    test('getById propagates Left(Failure) from the datasource without '
        'throwing', () async {
      // Act
      final result = await repository.getById('missing');

      // Assert
      expect(result, isA<Left<Failure, PantryItem>>());
    });

    test('getById returns Left(Failure) instead of throwing when the '
        'document carries an unrecognized category', () async {
      // Arrange
      const dto = PantryItemDTO.booleanTracked(
        category: 'unknownCategory',
        haveIt: true,
      );
      await dataSource.save('ingredient-x', dto);

      // Act
      final result = await repository.getById('ingredient-x');

      // Assert
      expect(result, isA<Left<Failure, PantryItem>>());
      result.fold(
        (failure) => expect(failure.code, 'malformedData'),
        (_) => fail('expected Left, got Right'),
      );
    });
  });
}
