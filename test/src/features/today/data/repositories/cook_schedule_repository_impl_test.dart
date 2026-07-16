import 'package:dartz/dartz.dart' hide Unit;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/today/data/datasources/cook_schedule_data_source.dart';
import 'package:menuario/src/features/today/data/models/cook_schedule_dto.dart';
import 'package:menuario/src/features/today/data/models/cook_target_dto.dart';
import 'package:menuario/src/features/today/data/repositories/cook_schedule_repository_impl.dart';
import 'package:menuario/src/features/today/domain/entities/cook_schedule.dart';
import 'package:menuario/src/features/today/domain/value_objects/cook_target.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  group('CookScheduleRepositoryImpl', () {
    late FakeFirebaseFirestore firestore;
    late CookScheduleDataSource dataSource;
    late CookScheduleRepositoryImpl repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      dataSource = CookScheduleDataSourceImpl(
        firestore: firestore,
        uid: 'uid-A',
      );
      repository = CookScheduleRepositoryImpl(dataSource: dataSource);
    });

    test(
      'getActive returns Right(null) when no schedule has been saved yet',
      () async {
        // Act
        final result = await repository.getActive();

        // Assert
        expect(result, const Right<Failure, CookSchedule?>(null));
      },
    );

    test('save then getActive round-trips the saved CookSchedule', () async {
      // Arrange
      const schedule = CookSchedule(
        byWeekday: {
          DateTime.monday: [
            (
              targetDay: DayOfWeek.lun,
              slot: MealSlot.cena,
              group: CookGroup.hoy,
            ),
          ],
        },
      );

      // Act
      final saveResult = await repository.save(schedule);
      final getResult = await repository.getActive();

      // Assert
      expect(saveResult, const Right<Failure, void>(null));
      getResult.fold(
        (failure) => fail('expected Right, got Left($failure)'),
        (readSchedule) => expect(readSchedule, schedule),
      );
    });

    test(
      'save overwrites the previously active schedule: getActive returns '
      'only the latest, no history',
      () async {
        // Arrange
        const firstSchedule = CookSchedule(byWeekday: {});
        const secondSchedule = CookSchedule(
          byWeekday: {
            DateTime.friday: [
              (
                targetDay: DayOfWeek.vie,
                slot: MealSlot.cena,
                group: CookGroup.hoy,
              ),
            ],
          },
        );

        // Act
        await repository.save(firstSchedule);
        await repository.save(secondSchedule);
        final result = await repository.getActive();

        // Assert
        result.fold(
          (failure) => fail('expected Right, got Left($failure)'),
          (readSchedule) => expect(readSchedule, secondSchedule),
        );
      },
    );

    test(
      'getActive returns Left(Failure) instead of throwing when an entry '
      'carries an unrecognized day',
      () async {
        // Arrange
        const dto = CookScheduleDTO(
          targets: [
            CookTargetDTO(
              weekday: DateTime.monday,
              targetDay: 'unknownDay',
              slot: 'cena',
              group: 'hoy',
            ),
          ],
        );
        await dataSource.save(dto);

        // Act
        final result = await repository.getActive();

        // Assert
        expect(result, isA<Left<Failure, CookSchedule?>>());
        result.fold(
          (failure) => expect(failure.code, 'malformedData'),
          (_) => fail('expected Left, got Right'),
        );
      },
    );
  });
}
