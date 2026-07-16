import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' hide Unit;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/data/datasources/ingredient_data_source.dart';
import 'package:menuario/src/shared/data/models/ingredient_dto.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  group('IngredientDataSourceImpl', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    IngredientDataSourceImpl makeDataSource({String? uid = 'uid-A'}) {
      return IngredientDataSourceImpl(firestore: firestore, uid: uid);
    }

    test('a saved ingredient round-trips back with the same fields', () async {
      // Arrange
      final dataSource = makeDataSource();
      const dto = IngredientDTO(
        name: 'Avena',
        category: 'cereal',
        measurementKind: 'bulk',
        booleanTracked: false,
        conversionFactor: 85,
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

    test('list returns every saved ingredient with its doc id', () async {
      // Arrange
      final dataSource = makeDataSource();
      await dataSource.save(
        'ingredient-avena',
        const IngredientDTO(
          name: 'Avena',
          category: 'cereal',
          measurementKind: 'bulk',
          booleanTracked: false,
          conversionFactor: 85,
        ),
      );

      // Act
      final result = await dataSource.list();

      // Assert
      result.fold((failure) => fail('expected Right, got Left($failure)'), (
        items,
      ) {
        expect(items, hasLength(1));
        expect(items.first.$1, 'ingredient-avena');
      });
    });

    test(
      'an ingredient written under uid A is not returned when scoped to '
      'uid B',
      () async {
        // Arrange
        final dataSourceA = makeDataSource(uid: 'uid-A');
        final dataSourceB = makeDataSource(uid: 'uid-B');
        await dataSourceA.save(
          'ingredient-avena',
          const IngredientDTO(
            name: 'Avena',
            category: 'cereal',
            measurementKind: 'bulk',
            booleanTracked: false,
          ),
        );

        // Act
        final listB = await dataSourceB.list();

        // Assert
        listB.fold(
          (failure) => fail('expected Right, got Left($failure)'),
          (items) => expect(items, isEmpty),
        );
      },
    );

    test(
      'save returns Left(Failure) when Firestore throws a '
      'FirebaseException',
      () async {
        // Arrange
        final dataSource = makeDataSource();
        final doc = firestore.collection('users/uid-A/ingredients').doc('x');
        whenCalling(Invocation.method(#set, null))
            .on(doc)
            .thenThrow(
              FirebaseException(plugin: 'firestore', code: 'unavailable'),
            );

        // Act
        final result = await dataSource.save(
          'x',
          const IngredientDTO(
            name: 'x',
            category: 'otro',
            measurementKind: 'unit',
            booleanTracked: false,
          ),
        );

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure.code, 'unavailable'),
          (_) => fail('expected Left, got Right'),
        );
      },
    );

    test(
      'getById returns Left(Failure) instead of throwing when the '
      'document is missing a required field',
      () async {
        // Arrange — `category` remains required even after the
        // flexible-units back-compat change (which only relaxed
        // `measurementKind`/`booleanTracked` to nullable so an old-shape
        // document lacking `measurementMode` still loads); a doc missing
        // `category` is still genuinely malformed.
        final dataSource = makeDataSource();
        await firestore
            .collection('users/uid-A/ingredients')
            .doc('broken')
            .set({'name': 'Avena'});

        // Act
        final result = await dataSource.getById('broken');

        // Assert
        expect(result, isA<Left<Failure, IngredientDTO>>());
        result.fold(
          (failure) => expect(failure.code, 'malformedData'),
          (_) => fail('expected Left, got Right'),
        );
      },
    );

    test(
      'getById loads an old-shape document (no measurementMode) without '
      'throwing, deriving a mode from its legacy fields',
      () async {
        // Arrange — a pre-flexible-units document: `measurementKind` +
        // `booleanTracked` present, no `measurementMode`/`package`/
        // `defaultLensLabel` keys at all.
        final dataSource = makeDataSource();
        await firestore
            .collection('users/uid-A/ingredients')
            .doc('old-shape')
            .set({
              'name': 'Arroz',
              'category': 'cereal',
              'measurementKind': 'bulk',
              'booleanTracked': false,
              'conversionFactor': 50,
            });

        // Act
        final result = await dataSource.getById('old-shape');

        // Assert
        expect(result, isA<Right<Failure, IngredientDTO>>());
        result.fold((_) => fail('expected Right, got Left'), (dto) {
          expect(dto.measurementKind, 'bulk');
          expect(dto.measurementMode, isNull);
        });
      },
    );

    test(
      'save returns Left(Failure.unauthenticated) when no uid is signed in',
      () async {
        // Arrange
        final dataSource = makeDataSource(uid: null);

        // Act
        final result = await dataSource.save(
          'x',
          const IngredientDTO(
            name: 'x',
            category: 'otro',
            measurementKind: 'unit',
            booleanTracked: false,
          ),
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
