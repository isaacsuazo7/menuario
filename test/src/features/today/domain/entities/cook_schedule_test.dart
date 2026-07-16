import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/today/domain/entities/cook_schedule.dart';
import 'package:menuario/src/features/today/domain/value_objects/cook_target.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  group('CookSchedule', () {
    test('targetsFor returns the targets for a known weekday', () {
      const schedule = CookSchedule(
        byWeekday: {
          DateTime.monday: [
            (targetDay: DayOfWeek.lun, slot: MealSlot.cena, group: CookGroup.hoy),
          ],
        },
      );

      expect(schedule.targetsFor(DateTime.monday), [
        (targetDay: DayOfWeek.lun, slot: MealSlot.cena, group: CookGroup.hoy),
      ]);
    });

    test('targetsFor returns an empty list for an unmapped weekday', () {
      const schedule = CookSchedule(byWeekday: {});

      expect(schedule.targetsFor(DateTime.tuesday), isEmpty);
    });

    test('seed content matches the batch-cook routine', () {
      const seed = CookSchedule.seed;

      expect(seed.targetsFor(DateTime.monday), [
        (targetDay: DayOfWeek.lun, slot: MealSlot.cena, group: CookGroup.hoy),
        (
          targetDay: DayOfWeek.mar,
          slot: MealSlot.desayuno,
          group: CookGroup.manana,
        ),
        (
          targetDay: DayOfWeek.mar,
          slot: MealSlot.almuerzo,
          group: CookGroup.manana,
        ),
        (
          targetDay: DayOfWeek.mar,
          slot: MealSlot.merienda,
          group: CookGroup.manana,
        ),
      ]);

      expect(seed.targetsFor(DateTime.friday), [
        (targetDay: DayOfWeek.vie, slot: MealSlot.cena, group: CookGroup.hoy),
      ]);

      expect(seed.targetsFor(DateTime.saturday), [
        (targetDay: DayOfWeek.sab, slot: MealSlot.desayuno, group: CookGroup.hoy),
        (targetDay: DayOfWeek.sab, slot: MealSlot.almuerzo, group: CookGroup.hoy),
        (targetDay: DayOfWeek.sab, slot: MealSlot.merienda, group: CookGroup.hoy),
        (targetDay: DayOfWeek.sab, slot: MealSlot.cena, group: CookGroup.hoy),
      ]);

      expect(seed.targetsFor(DateTime.sunday), [
        (
          targetDay: DayOfWeek.lun,
          slot: MealSlot.desayuno,
          group: CookGroup.manana,
        ),
        (
          targetDay: DayOfWeek.lun,
          slot: MealSlot.almuerzo,
          group: CookGroup.manana,
        ),
        (
          targetDay: DayOfWeek.lun,
          slot: MealSlot.merienda,
          group: CookGroup.manana,
        ),
      ]);
    });

    test('two CookSchedules with equal byWeekday maps are equal', () {
      const scheduleA = CookSchedule(
        byWeekday: {
          DateTime.friday: [
            (targetDay: DayOfWeek.vie, slot: MealSlot.cena, group: CookGroup.hoy),
          ],
        },
      );
      const scheduleB = CookSchedule(
        byWeekday: {
          DateTime.friday: [
            (targetDay: DayOfWeek.vie, slot: MealSlot.cena, group: CookGroup.hoy),
          ],
        },
      );

      expect(scheduleA, scheduleB);
    });
  });
}
