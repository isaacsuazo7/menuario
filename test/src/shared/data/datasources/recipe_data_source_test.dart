import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' hide Unit;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/data/datasources/recipe_data_source.dart';
import 'package:menuario/src/shared/data/models/recipe_dto.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  group('RecipeDataSourceImpl', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    RecipeDataSourceImpl makeDataSource({String? uid = 'uid-A'}) {
      return RecipeDataSourceImpl(firestore: firestore, uid: uid);
    }

    group('save + getById', () {
      test(
        'a saved recipe round-trips back with the same id and fields',
        () async {
          // Arrange
          final dataSource = makeDataSource();
          const dto = RecipeDTO(name: 'Avena con leche', bomLines: []);

          // Act
          final saveResult = await dataSource.save('recipe-1', dto);
          final getResult = await dataSource.getById('recipe-1');

          // Assert
          expect(saveResult, const Right<Failure, void>(null));
          expect(getResult, isA<Right<Failure, RecipeDTO>>());
          getResult.fold(
            (failure) => fail('expected Right, got Left($failure)'),
            (readDto) => expect(readDto, dto),
          );
        },
      );

      test(
        'getById returns Left(Failure) when the document does not exist',
        () async {
          // Arrange
          final dataSource = makeDataSource();

          // Act
          final result = await dataSource.getById('missing-recipe');

          // Assert
          expect(result, isA<Left<Failure, RecipeDTO>>());
        },
      );
    });

    group('list', () {
      test('list returns every saved recipe with its doc id', () async {
        // Arrange
        final dataSource = makeDataSource();
        await dataSource.save(
          'recipe-1',
          const RecipeDTO(name: 'Avena', bomLines: []),
        );
        await dataSource.save(
          'recipe-2',
          const RecipeDTO(name: 'Ensalada', bomLines: []),
        );

        // Act
        final result = await dataSource.list();

        // Assert
        expect(result, isA<Right<Failure, List<(String, RecipeDTO)>>>());
        result.fold((failure) => fail('expected Right, got Left($failure)'), (
          items,
        ) {
          expect(items, hasLength(2));
          expect(
            items.map((item) => item.$1).toSet(),
            {'recipe-1', 'recipe-2'},
          );
        });
      });

      test(
        'list returns an empty list for a uid with no recipes',
        () async {
          // Arrange
          final dataSource = makeDataSource();

          // Act
          final result = await dataSource.list();

          // Assert
          expect(result, isA<Right<Failure, List<(String, RecipeDTO)>>>());
          result.fold(
            (failure) => fail('expected Right, got Left($failure)'),
            (items) => expect(items, isEmpty),
          );
        },
      );
    });

    group('cross-user isolation', () {
      test(
        'a recipe written under uid A is not returned when scoped to uid B',
        () async {
          // Arrange
          final dataSourceA = makeDataSource(uid: 'uid-A');
          final dataSourceB = makeDataSource(uid: 'uid-B');
          await dataSourceA.save(
            'recipe-a',
            const RecipeDTO(name: 'Solo de A', bomLines: []),
          );

          // Act
          final listB = await dataSourceB.list();
          final getB = await dataSourceB.getById('recipe-a');

          // Assert
          expect(listB, isA<Right<Failure, List<(String, RecipeDTO)>>>());
          listB.fold(
            (failure) => fail('expected Right, got Left($failure)'),
            (items) => expect(items, isEmpty),
          );
          expect(getB, isA<Left<Failure, RecipeDTO>>());
        },
      );
    });

    group('Firestore error mapping', () {
      test(
        'save returns Left(Failure) when Firestore throws a '
        'FirebaseException',
        () async {
          // Arrange
          final dataSource = makeDataSource();
          final doc = firestore.collection('users/uid-A/recipes').doc('x');
          whenCalling(Invocation.method(#set, null))
              .on(doc)
              .thenThrow(
                FirebaseException(
                  plugin: 'firestore',
                  code: 'permission-denied',
                ),
              );

          // Act
          final result = await dataSource.save(
            'x',
            const RecipeDTO(name: 'x', bomLines: []),
          );

          // Assert
          expect(result, isA<Left<Failure, void>>());
          result.fold(
            (failure) => expect(failure.code, 'permission-denied'),
            (_) => fail('expected Left, got Right'),
          );
        },
      );
    });

    group('malformed document', () {
      test(
        'getById returns Left(Failure) instead of throwing when the '
        'document is missing a required field',
        () async {
          // Arrange
          final dataSource = makeDataSource();
          await firestore
              .collection('users/uid-A/recipes')
              .doc('broken')
              .set({'bomLines': <Map<String, dynamic>>[]});

          // Act
          final result = await dataSource.getById('broken');

          // Assert
          expect(result, isA<Left<Failure, RecipeDTO>>());
          result.fold(
            (failure) => expect(failure.code, 'malformedData'),
            (_) => fail('expected Left, got Right'),
          );
        },
      );
    });

    group('unauthenticated', () {
      test(
        'save returns Left(Failure.unauthenticated) and writes nothing '
        'when no uid is signed in',
        () async {
          // Arrange
          final dataSource = makeDataSource(uid: null);

          // Act
          final result = await dataSource.save(
            'recipe-x',
            const RecipeDTO(name: 'x', bomLines: []),
          );

          // Assert
          expect(result, isA<Left<Failure, void>>());
          result.fold(
            (failure) => expect(failure.code, 'unauthenticated'),
            (_) => fail('expected Left, got Right'),
          );
          final snapshot = await firestore
              .collection('users/uid-A/recipes')
              .get();
          expect(snapshot.docs, isEmpty);
        },
      );
    });
  });
}
