import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/value_objects/day_of_week.dart';
import 'package:menuario/src/shared/domain/value_objects/meal_slot.dart';

part 'plan_entry.freezed.dart';

/// One planned meal slot within a [WeekPlan]: which recipe is planned for a
/// given [day] and [mealSlot], and whether it has been [cooked] yet.
///
/// [day] is a [DayOfWeek], so Domingo can never be represented — the type
/// itself only admits Lun-Sáb.
@freezed
abstract class PlanEntry with _$PlanEntry {
  const factory PlanEntry({
    required DayOfWeek day,
    required MealSlot mealSlot,
    required String recipeId,
    required bool cooked,
  }) = _PlanEntry;
}
