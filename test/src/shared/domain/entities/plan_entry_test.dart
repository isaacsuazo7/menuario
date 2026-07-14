import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/entities/plan_entry.dart';
import 'package:menuario/src/shared/domain/value_objects/day_of_week.dart';
import 'package:menuario/src/shared/domain/value_objects/meal_slot.dart';

void main() {
  group('PlanEntry', () {
    test('should carry a day, meal slot, recipe ref and cooked flag', () {
      // Arrange & Act
      const entry = PlanEntry(
        day: DayOfWeek.lun,
        mealSlot: MealSlot.desayuno,
        recipeId: 'recipe-avena',
        cooked: false,
      );

      // Assert
      expect(entry.day, DayOfWeek.lun);
      expect(entry.mealSlot, MealSlot.desayuno);
      expect(entry.recipeId, 'recipe-avena');
      expect(entry.cooked, isFalse);
    });

    test('Domingo cannot be used to build a PlanEntry: the day type only '
        'admits Lun-Sáb, and parsing "Dom" is rejected upstream', () {
      // Act — the only supported way to obtain a DayOfWeek from a raw
      // label already rejects Domingo before a PlanEntry can be built.
      final parsed = DayOfWeek.fromLabel('Dom');

      // Assert
      expect(
        parsed,
        isA<Left<Failure, DayOfWeek>>().having(
          (left) => left.value.code,
          'code',
          'invalidDay',
        ),
      );
      // And the DayOfWeek enum itself has no Domingo member to construct
      // a PlanEntry with in the first place.
      expect(DayOfWeek.values.map((d) => d.label), isNot(contains('Dom')));
    });
  });
}
