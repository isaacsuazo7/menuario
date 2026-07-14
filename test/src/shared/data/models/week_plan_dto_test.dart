import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/data/models/week_plan_dto.dart';
import 'package:menuario/src/shared/domain/entities/plan_entry.dart';
import 'package:menuario/src/shared/domain/entities/week_plan.dart';
import 'package:menuario/src/shared/domain/value_objects/day_of_week.dart';
import 'package:menuario/src/shared/domain/value_objects/meal_slot.dart';

void main() {
  group('WeekPlanDTO round-trip', () {
    test('a plan with multiple entries survives '
        'fromEntity->toJson->fromJson->toEntity', () {
      // Arrange
      const entity = WeekPlan(
        entries: [
          PlanEntry(
            day: DayOfWeek.lun,
            mealSlot: MealSlot.desayuno,
            recipeId: 'recipe-1',
            cooked: false,
          ),
          PlanEntry(
            day: DayOfWeek.mar,
            mealSlot: MealSlot.almuerzo,
            recipeId: 'recipe-2',
            cooked: true,
          ),
        ],
      );

      // Act
      final json = WeekPlanDTO.fromEntity(entity).toJson();
      final result = WeekPlanDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
      expect(result.entries.map((e) => e.recipeId).toList(), [
        'recipe-1',
        'recipe-2',
      ]);
    });

    test('a plan with no entries round-trips to an empty list', () {
      // Arrange
      const entity = WeekPlan(entries: []);

      // Act
      final json = WeekPlanDTO.fromEntity(entity).toJson();
      final result = WeekPlanDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
      expect(result.entries, isEmpty);
    });
  });
}
