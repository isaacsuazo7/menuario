import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/today/data/models/cook_schedule_dto.dart';
import 'package:menuario/src/features/today/data/models/cook_target_dto.dart';
import 'package:menuario/src/features/today/domain/entities/cook_schedule.dart';
import 'package:menuario/src/features/today/domain/value_objects/cook_target.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  group('CookScheduleDTO round-trip', () {
    test('a schedule with multiple weekdays survives '
        'fromEntity->toJson->fromJson->toEntity', () {
      // Arrange
      const entity = CookSchedule(
        byWeekday: {
          DateTime.monday: [
            (
              targetDay: DayOfWeek.lun,
              slot: MealSlot.cena,
              group: CookGroup.hoy,
            ),
            (
              targetDay: DayOfWeek.mar,
              slot: MealSlot.desayuno,
              group: CookGroup.manana,
            ),
          ],
          DateTime.saturday: [
            (
              targetDay: DayOfWeek.sab,
              slot: MealSlot.cena,
              group: CookGroup.hoy,
            ),
          ],
        },
      );

      // Act
      final json = CookScheduleDTO.fromEntity(entity).toJson();
      final result = CookScheduleDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
      expect(result.targetsFor(DateTime.monday), hasLength(2));
      expect(result.targetsFor(DateTime.saturday), hasLength(1));
    });

    test('a schedule with no targets round-trips to an empty map', () {
      // Arrange
      const entity = CookSchedule(byWeekday: {});

      // Act
      final json = CookScheduleDTO.fromEntity(entity).toJson();
      final result = CookScheduleDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
      expect(result.byWeekday, isEmpty);
    });

    test('the seed schedule round-trips losslessly', () {
      // Arrange
      const entity = CookSchedule.seed;

      // Act
      final json = CookScheduleDTO.fromEntity(entity).toJson();
      final result = CookScheduleDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
    });

    test('fromEntity flattens each weekday into its own DTO entries', () {
      const entity = CookSchedule(
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

      final dto = CookScheduleDTO.fromEntity(entity);

      expect(dto.targets, [
        const CookTargetDTO(
          weekday: DateTime.friday,
          targetDay: 'vie',
          slot: 'cena',
          group: 'hoy',
        ),
      ]);
    });
  });
}
