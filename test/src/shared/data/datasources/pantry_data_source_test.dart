import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' hide Unit;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/data/datasources/pantry_data_source.dart';
import 'package:menuario/src/shared/data/models/pantry_item_dto.dart';
import 'package:menuario/src/shared/data/models/quantity_dto.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  group('PantryDataSourceImpl', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    PantryDataSourceImpl makeDataSource({String? uid = 'uid-A'}) {
      return PantryDataSourceImpl(firestore: firestore, uid: uid);
    }

    test('a saved quantity-tracked pantry item round-trips back with the '
        'same fields', () async {
      // Arrange
      final dataSource = makeDataSource();
      const dto = PantryItemDTO.quantityTracked(
        category: 'cereal',
        stock: QuantityDTO(value: 340, unitSymbol: 'g', unitDimension: 'mass'),
      );

      // Act
      final saveResult = await dataSource.save('ingredient-avena', dto);
      final getResult = await dataSource.getById('ingredient-avena');

      // Assert
      expect(saveResult, const Right<Failure, void>(null));
      getResult.fold(
        (failure) => fail('expected Right, got Left($failure)'),
        (readDto) => expect(readDto, dto),
      );
    });

    test('a saved boolean-tracked pantry item round-trips back with the '
        'same fields', () async {
      // Arrange
      final dataSource = makeDataSource();
      const dto = PantryItemDTO.booleanTracked(
        category: 'condimento',
        haveIt: true,
      );

      // Act
      final saveResult = await dataSource.save('ingredient-comino', dto);
      final getResult = await dataSource.getById('ingredient-comino');

      // Assert
      expect(saveResult, const Right<Failure, void>(null));
      getResult.fold(
        (failure) => fail('expected Right, got Left($failure)'),
        (readDto) => expect(readDto, dto),
      );
    });

    test('list returns every saved pantry item with its doc id', () async {
      // Arrange
      final dataSource = makeDataSource();
      await dataSource.save(
        'ingredient-comino',
        const PantryItemDTO.booleanTracked(
          category: 'condimento',
          haveIt: false,
        ),
      );

      // Act
      final result = await dataSource.list();

      // Assert
      result.fold((failure) => fail('expected Right, got Left($failure)'), (
        items,
      ) {
        expect(items, hasLength(1));
        expect(items.first.$1, 'ingredient-comino');
      });
    });

    test('a pantry item written under uid A is not returned when scoped to '
        'uid B', () async {
      // Arrange
      final dataSourceA = makeDataSource(uid: 'uid-A');
      final dataSourceB = makeDataSource(uid: 'uid-B');
      await dataSourceA.save(
        'ingredient-comino',
        const PantryItemDTO.booleanTracked(
          category: 'condimento',
          haveIt: true,
        ),
      );

      // Act
      final listB = await dataSourceB.list();

      // Assert
      listB.fold(
        (failure) => fail('expected Right, got Left($failure)'),
        (items) => expect(items, isEmpty),
      );
    });

    test('save returns Left(Failure) when Firestore throws a '
        'FirebaseException', () async {
      // Arrange
      final dataSource = makeDataSource();
      final doc = firestore.collection('users/uid-A/pantry').doc('x');
      whenCalling(Invocation.method(#set, null))
          .on(doc)
          .thenThrow(
            FirebaseException(plugin: 'firestore', code: 'unavailable'),
          );

      // Act
      final result = await dataSource.save(
        'x',
        const PantryItemDTO.booleanTracked(category: 'otro', haveIt: false),
      );

      // Assert
      result.fold(
        (failure) => expect(failure.code, 'unavailable'),
        (_) => fail('expected Left, got Right'),
      );
    });

    test('getById returns Left(Failure) instead of throwing when the '
        'document has an unrecognized union "type" discriminator', () async {
      // Arrange
      final dataSource = makeDataSource();
      await firestore.collection('users/uid-A/pantry').doc('broken').set({
        'type': 'unknownVariant',
        'category': 'cereal',
        'presentation': {'type': 'loose'},
      });

      // Act
      final result = await dataSource.getById('broken');

      // Assert
      expect(result, isA<Left<Failure, PantryItemDTO>>());
      result.fold(
        (failure) => expect(failure.code, 'malformedData'),
        (_) => fail('expected Left, got Right'),
      );
    });

    test(
      'save returns Left(Failure.unauthenticated) when no uid is signed in',
      () async {
        // Arrange
        final dataSource = makeDataSource(uid: null);

        // Act
        final result = await dataSource.save(
          'x',
          const PantryItemDTO.booleanTracked(category: 'otro', haveIt: false),
        );

        // Assert
        result.fold(
          (failure) => expect(failure.code, 'unauthenticated'),
          (_) => fail('expected Left, got Right'),
        );
      },
    );
  });
}
