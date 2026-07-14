import 'package:dartz/dartz.dart' hide Unit;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/data/datasources/ingredient_data_source.dart';
import 'package:menuario/src/shared/data/repositories/ingredient_repository_impl.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_kind.dart';

void main() {
  group('IngredientRepositoryImpl', () {
    late FakeFirebaseFirestore firestore;
    late IngredientDataSource dataSource;
    late IngredientRepositoryImpl repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      dataSource = IngredientDataSourceImpl(
        firestore: firestore,
        uid: 'uid-A',
      );
      repository = IngredientRepositoryImpl(dataSource: dataSource);
    });

    test(
      'save then getById round-trips the Ingredient entity, id preserved',
      () async {
        // Arrange
        const ingredient = Ingredient(
          id: 'ingredient-avena',
          name: 'Avena',
          category: Category.cereal,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          conversionFactor: 85,
        );

        // Act
        final saveResult = await repository.save(ingredient);
        final getResult = await repository.getById('ingredient-avena');

        // Assert
        expect(saveResult, const Right<Failure, void>(null));
        getResult.fold(
          (failure) => fail('expected Right, got Left($failure)'),
          (read) => expect(read, ingredient),
        );
      },
    );

    test('list returns every saved Ingredient as entities', () async {
      // Arrange
      const first = Ingredient(
        id: 'ingredient-avena',
        name: 'Avena',
        category: Category.cereal,
        measurementKind: MeasurementKind.bulk,
        booleanTracked: false,
        conversionFactor: 85,
      );
      const second = Ingredient(
        id: 'ingredient-huevo',
        name: 'Huevo',
        category: Category.proteina,
        measurementKind: MeasurementKind.unit,
        booleanTracked: false,
      );
      await repository.save(first);
      await repository.save(second);

      // Act
      final result = await repository.list();

      // Assert
      result.fold(
        (failure) => fail('expected Right, got Left($failure)'),
        (ingredients) => expect(ingredients.toSet(), {first, second}),
      );
    });

    test(
      'getById propagates Left(Failure) from the datasource without '
      'throwing',
      () async {
        // Act
        final result = await repository.getById('missing');

        // Assert
        expect(result, isA<Left<Failure, Ingredient>>());
      },
    );
  });
}
