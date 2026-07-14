import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/entities/plan_entry.dart';
import 'package:menuario/src/shared/domain/entities/week_plan.dart';
import 'package:menuario/src/shared/domain/value_objects/day_of_week.dart';
import 'package:menuario/src/shared/domain/value_objects/meal_slot.dart';

void main() {
  group('WeekPlan', () {
    const monday = PlanEntry(
      day: DayOfWeek.lun,
      mealSlot: MealSlot.desayuno,
      recipeId: 'recipe-avena',
      cooked: false,
    );
    const tuesday = PlanEntry(
      day: DayOfWeek.mar,
      mealSlot: MealSlot.almuerzo,
      recipeId: 'recipe-pollo',
      cooked: false,
    );

    test('should carry the active list of PlanEntries', () {
      // Arrange & Act
      const plan = WeekPlan(entries: [monday]);

      // Assert
      expect(plan.entries, [monday]);
    });

    test('saving/overwriting should fully replace the prior entries, '
        'leaving no history (single active plan semantics)', () {
      // Arrange
      const original = WeekPlan(entries: [monday]);

      // Act
      final overwritten = original.overwriteWith([tuesday]);

      // Assert — the new plan has only the new entries...
      expect(overwritten.entries, [tuesday]);
      // ...and the prior plan's entries are gone, not merged/kept.
      expect(overwritten.entries, isNot(contains(monday)));
      // ...while the original instance itself remains untouched, since
      // "overwrite" always produces a fresh replacement, never a mutation.
      expect(original.entries, [monday]);
    });
  });
}
