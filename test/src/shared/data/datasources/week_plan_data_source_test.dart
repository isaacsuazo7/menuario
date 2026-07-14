import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' hide Unit;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/data/datasources/week_plan_data_source.dart';
import 'package:menuario/src/shared/data/models/plan_entry_dto.dart';
import 'package:menuario/src/shared/data/models/week_plan_dto.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  group('WeekPlanDataSourceImpl', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    WeekPlanDataSourceImpl makeDataSource({String? uid = 'uid-A'}) {
      return WeekPlanDataSourceImpl(firestore: firestore, uid: uid);
    }

    test(
      'getActive returns Right(null) when no plan has been saved yet',
      () async {
        // Arrange
        final dataSource = makeDataSource();

        // Act
        final result = await dataSource.getActive();

        // Assert
        expect(result, const Right<Failure, WeekPlanDTO?>(null));
      },
    );

    test('save then getActive round-trips the saved WeekPlanDTO', () async {
      // Arrange
      final dataSource = makeDataSource();
      const dto = WeekPlanDTO(
        entries: [
          PlanEntryDTO(
            day: 'lun',
            mealSlot: 'desayuno',
            recipeId: 'recipe-1',
            cooked: false,
          ),
        ],
      );

      // Act
      final saveResult = await dataSource.save(dto);
      final getResult = await dataSource.getActive();

      // Assert
      expect(saveResult, const Right<Failure, void>(null));
      getResult.fold(
        (failure) => fail('expected Right, got Left($failure)'),
        (readDto) => expect(readDto, dto),
      );
    });

    test(
      'saving a second plan overwrites the first: getActive returns only '
      'the latest plan, single doc, no history',
      () async {
        // Arrange
        final dataSource = makeDataSource();
        const firstPlan = WeekPlanDTO(entries: []);
        const secondPlan = WeekPlanDTO(
          entries: [
            PlanEntryDTO(
              day: 'mar',
              mealSlot: 'cena',
              recipeId: 'recipe-2',
              cooked: true,
            ),
          ],
        );

        // Act
        await dataSource.save(firstPlan);
        await dataSource.save(secondPlan);
        final result = await dataSource.getActive();
        final collectionSnapshot = await firestore
            .collection('users/uid-A/weekPlan')
            .get();

        // Assert
        result.fold(
          (failure) => fail('expected Right, got Left($failure)'),
          (readDto) => expect(readDto, secondPlan),
        );
        expect(collectionSnapshot.docs, hasLength(1));
      },
    );

    test(
      'a plan written under uid A is not returned when scoped to uid B',
      () async {
        // Arrange
        final dataSourceA = makeDataSource(uid: 'uid-A');
        final dataSourceB = makeDataSource(uid: 'uid-B');
        await dataSourceA.save(const WeekPlanDTO(entries: []));

        // Act
        final resultB = await dataSourceB.getActive();

        // Assert
        expect(resultB, const Right<Failure, WeekPlanDTO?>(null));
      },
    );

    test(
      'save returns Left(Failure) when Firestore throws a '
      'FirebaseException',
      () async {
        // Arrange
        final dataSource = makeDataSource();
        final doc = firestore.doc('users/uid-A/weekPlan/current');
        whenCalling(Invocation.method(#set, null))
            .on(doc)
            .thenThrow(
              FirebaseException(plugin: 'firestore', code: 'unavailable'),
            );

        // Act
        final result = await dataSource.save(const WeekPlanDTO(entries: []));

        // Assert
        result.fold(
          (failure) => expect(failure.code, 'unavailable'),
          (_) => fail('expected Left, got Right'),
        );
      },
    );

    test(
      'save returns Left(Failure.unauthenticated) when no uid is signed in',
      () async {
        // Arrange
        final dataSource = makeDataSource(uid: null);

        // Act
        final result = await dataSource.save(const WeekPlanDTO(entries: []));

        // Assert
        result.fold(
          (failure) => expect(failure.code, 'unauthenticated'),
          (_) => fail('expected Left, got Right'),
        );
      },
    );
  });
}
