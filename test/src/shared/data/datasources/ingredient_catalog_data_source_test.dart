import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' hide Unit;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/data/datasources/ingredient_catalog_data_source.dart';
import 'package:menuario/src/shared/data/models/ingredient_dto.dart';
import 'package:menuario/src/shared/data/models/pantry_item_dto.dart';
import 'package:menuario/src/shared/data/models/quantity_dto.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  group('IngredientCatalogDataSourceImpl', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    IngredientCatalogDataSourceImpl makeDataSource({String? uid = 'uid-A'}) {
      return IngredientCatalogDataSourceImpl(firestore: firestore, uid: uid);
    }

    const ingredientDto = IngredientDTO(
      name: 'Avena',
      category: 'cereal',
      measurementKind: 'bulk',
      booleanTracked: false,
      conversionFactor: 85,
    );
    const pantryDto = PantryItemDTO.quantityTracked(
      category: 'cereal',
      stock: QuantityDTO(value: 2, unitSymbol: 'g', unitDimension: 'mass'),
    );

    test('saveWithPantry writes both the ingredient and the pantry doc under '
        'the same id', () async {
      // Arrange
      final dataSource = makeDataSource();

      // Act
      final result = await dataSource.saveWithPantry(
        'ingredient-avena',
        ingredientDto,
        pantryDto,
      );

      // Assert
      expect(result, const Right<Failure, void>(null));
      final ingredientSnapshot = await firestore
          .collection('users/uid-A/ingredients')
          .doc('ingredient-avena')
          .get();
      final pantrySnapshot = await firestore
          .collection('users/uid-A/pantry')
          .doc('ingredient-avena')
          .get();
      expect(IngredientDTO.fromJson(ingredientSnapshot.data()!), ingredientDto);
      expect(PantryItemDTO.fromJson(pantrySnapshot.data()!), pantryDto);
    });

    test('newId returns a non-empty id that round-trips a saved doc', () async {
      // Arrange
      final dataSource = makeDataSource();

      // Act
      final id = dataSource.newId();
      final result = await dataSource.saveWithPantry(
        id,
        ingredientDto,
        pantryDto,
      );

      // Assert
      expect(id, isNotEmpty);
      expect(result, const Right<Failure, void>(null));
      final ingredientSnapshot = await firestore
          .collection('users/uid-A/ingredients')
          .doc(id)
          .get();
      expect(ingredientSnapshot.exists, isTrue);
    });

    test('saveWithPantry returns Left(Failure.unauthenticated) when no uid is '
        'signed in', () async {
      // Arrange
      final dataSource = makeDataSource(uid: null);

      // Act
      final result = await dataSource.saveWithPantry(
        'x',
        ingredientDto,
        pantryDto,
      );

      // Assert
      result.fold(
        (failure) => expect(failure.code, 'unauthenticated'),
        (_) => fail('expected Left, got Right'),
      );
    });

    test('saveWithPantry maps a FirebaseException thrown while the batch '
        'commits to a Failure, and neither doc ends up written', () async {
      // Arrange
      final dataSource = makeDataSource();
      final ingredientDoc = firestore
          .collection('users/uid-A/ingredients')
          .doc('ingredient-avena');
      whenCalling(Invocation.method(#set, null))
          .on(ingredientDoc)
          .thenThrow(
            FirebaseException(plugin: 'firestore', code: 'unavailable'),
          );

      // Act
      final result = await dataSource.saveWithPantry(
        'ingredient-avena',
        ingredientDto,
        pantryDto,
      );

      // Assert
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (failure) => expect(failure.code, 'unavailable'),
        (_) => fail('expected Left, got Right'),
      );
      final pantrySnapshot = await firestore
          .collection('users/uid-A/pantry')
          .doc('ingredient-avena')
          .get();
      expect(
        pantrySnapshot.exists,
        isFalse,
        reason:
            'the ingredient set task fails before the pantry set task '
            'runs, so the pantry doc must never be written either',
      );
    });
  });
}
