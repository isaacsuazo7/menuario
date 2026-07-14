import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/data/models/plan_entry_dto.dart';
import 'package:menuario/src/shared/domain/entities/plan_entry.dart';
import 'package:menuario/src/shared/domain/value_objects/day_of_week.dart';
import 'package:menuario/src/shared/domain/value_objects/meal_slot.dart';

void main() {
  group('PlanEntryDTO round-trip', () {
    test('an uncooked entry survives '
        'fromEntity->toJson->fromJson->toEntity', () {
      // Arrange
      const entity = PlanEntry(
        day: DayOfWeek.lun,
        mealSlot: MealSlot.desayuno,
        recipeId: 'recipe-1',
        cooked: false,
      );

      // Act
      final json = PlanEntryDTO.fromEntity(entity).toJson();
      final result = PlanEntryDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
      expect(json['day'], 'lun');
      expect(json['mealSlot'], 'desayuno');
    });

    test('a cooked entry on a different day/slot round-trips exactly', () {
      // Arrange
      const entity = PlanEntry(
        day: DayOfWeek.sab,
        mealSlot: MealSlot.cena,
        recipeId: 'recipe-7',
        cooked: true,
      );

      // Act
      final json = PlanEntryDTO.fromEntity(entity).toJson();
      final result = PlanEntryDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
      expect(json['day'], 'sab');
      expect(json['mealSlot'], 'cena');
    });
  });
}
