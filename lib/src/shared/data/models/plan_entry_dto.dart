import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/entities/plan_entry.dart';
import 'package:menuario/src/shared/domain/value_objects/day_of_week.dart';
import 'package:menuario/src/shared/domain/value_objects/meal_slot.dart';

part 'plan_entry_dto.freezed.dart';
part 'plan_entry_dto.g.dart';

/// JSON representation of a [PlanEntry], nested inside
/// `WeekPlanDTO.entries`.
@freezed
abstract class PlanEntryDTO with _$PlanEntryDTO {
  const factory PlanEntryDTO({
    required String day,
    required String mealSlot,
    required String recipeId,
    required bool cooked,
  }) = _PlanEntryDTO;

  const PlanEntryDTO._();

  factory PlanEntryDTO.fromJson(Map<String, dynamic> json) =>
      _$PlanEntryDTOFromJson(json);

  /// Builds a [PlanEntryDTO] from a [PlanEntry] entity.
  static PlanEntryDTO fromEntity(PlanEntry entity) {
    return PlanEntryDTO(
      day: entity.day.name,
      mealSlot: entity.mealSlot.name,
      recipeId: entity.recipeId,
      cooked: entity.cooked,
    );
  }
}

/// Bidirectional mapper: [PlanEntryDTO] -> [PlanEntry].
extension PlanEntryDTOX on PlanEntryDTO {
  /// Rebuilds the [PlanEntry] entity carried by this DTO.
  PlanEntry toEntity() {
    return PlanEntry(
      day: DayOfWeek.values.byName(day),
      mealSlot: MealSlot.values.byName(mealSlot),
      recipeId: recipeId,
      cooked: cooked,
    );
  }
}
