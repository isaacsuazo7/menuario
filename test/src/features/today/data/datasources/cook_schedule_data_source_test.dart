import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' hide Unit;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/today/data/datasources/cook_schedule_data_source.dart';
import 'package:menuario/src/features/today/data/models/cook_schedule_dto.dart';
import 'package:menuario/src/features/today/data/models/cook_target_dto.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  group('CookScheduleDataSourceImpl', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    CookScheduleDataSourceImpl makeDataSource({String? uid = 'uid-A'}) {
      return CookScheduleDataSourceImpl(firestore: firestore, uid: uid);
    }

    test(
      'getActive returns Right(null) when no schedule has been saved yet',
      () async {
        // Arrange
        final dataSource = makeDataSource();

        // Act
        final result = await dataSource.getActive();

        // Assert
        expect(result, const Right<Failure, CookScheduleDTO?>(null));
      },
    );

    test('save then getActive round-trips the saved CookScheduleDTO', () async {
      // Arrange
      final dataSource = makeDataSource();
      const dto = CookScheduleDTO(
        targets: [
          CookTargetDTO(
            weekday: DateTime.monday,
            targetDay: 'lun',
            slot: 'cena',
            group: 'hoy',
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

    test('saving a second schedule overwrites the first: getActive returns '
        'only the latest schedule, single doc, no history', () async {
      // Arrange
      final dataSource = makeDataSource();
      const firstSchedule = CookScheduleDTO(targets: []);
      const secondSchedule = CookScheduleDTO(
        targets: [
          CookTargetDTO(
            weekday: DateTime.friday,
            targetDay: 'vie',
            slot: 'cena',
            group: 'hoy',
          ),
        ],
      );

      // Act
      await dataSource.save(firstSchedule);
      await dataSource.save(secondSchedule);
      final result = await dataSource.getActive();
      final collectionSnapshot = await firestore
          .collection('users/uid-A/cookSchedule')
          .get();

      // Assert
      result.fold(
        (failure) => fail('expected Right, got Left($failure)'),
        (readDto) => expect(readDto, secondSchedule),
      );
      expect(collectionSnapshot.docs, hasLength(1));
    });

    test(
      'a schedule written under uid A is not returned when scoped to uid B',
      () async {
        // Arrange
        final dataSourceA = makeDataSource(uid: 'uid-A');
        final dataSourceB = makeDataSource(uid: 'uid-B');
        await dataSourceA.save(const CookScheduleDTO(targets: []));

        // Act
        final resultB = await dataSourceB.getActive();

        // Assert
        expect(resultB, const Right<Failure, CookScheduleDTO?>(null));
      },
    );

    test('save returns Left(Failure) when Firestore throws a '
        'FirebaseException', () async {
      // Arrange
      final dataSource = makeDataSource();
      final doc = firestore.doc('users/uid-A/cookSchedule/current');
      whenCalling(Invocation.method(#set, null))
          .on(doc)
          .thenThrow(
            FirebaseException(plugin: 'firestore', code: 'unavailable'),
          );

      // Act
      final result = await dataSource.save(const CookScheduleDTO(targets: []));

      // Assert
      result.fold(
        (failure) => expect(failure.code, 'unavailable'),
        (_) => fail('expected Left, got Right'),
      );
    });

    test(
      'getActive returns Left(Failure) instead of throwing when the '
      'active schedule document has an entry missing a required field',
      () async {
        // Arrange
        final dataSource = makeDataSource();
        await firestore.doc('users/uid-A/cookSchedule/current').set({
          'targets': [
            {'targetDay': 'lun', 'slot': 'cena', 'group': 'hoy'},
          ],
        });

        // Act
        final result = await dataSource.getActive();

        // Assert
        expect(result, isA<Left<Failure, CookScheduleDTO?>>());
        result.fold(
          (failure) => expect(failure.code, 'malformedData'),
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
        final result = await dataSource.save(
          const CookScheduleDTO(targets: []),
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
