import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/data/models/plan_entry_dto.dart';
import 'package:menuario/src/shared/domain/entities/week_plan.dart';

part 'week_plan_dto.freezed.dart';
part 'week_plan_dto.g.dart';

/// JSON representation of the single active [WeekPlan].
///
/// [WeekPlan] carries no identity of its own — it always lives at the
/// fixed `users/{uid}/weekPlan/current` document — so no id is injected on
/// [WeekPlanDTOX.toEntity].
@freezed
abstract class WeekPlanDTO with _$WeekPlanDTO {
  const factory WeekPlanDTO({required List<PlanEntryDTO> entries}) =
      _WeekPlanDTO;

  const WeekPlanDTO._();

  factory WeekPlanDTO.fromJson(Map<String, dynamic> json) =>
      _$WeekPlanDTOFromJson(json);

  /// Builds a [WeekPlanDTO] from a [WeekPlan] entity.
  static WeekPlanDTO fromEntity(WeekPlan entity) {
    return WeekPlanDTO(
      entries: entity.entries.map(PlanEntryDTO.fromEntity).toList(),
    );
  }
}

/// Bidirectional mapper: [WeekPlanDTO] -> [WeekPlan].
extension WeekPlanDTOX on WeekPlanDTO {
  /// Rebuilds the [WeekPlan] entity carried by this DTO.
  WeekPlan toEntity() {
    return WeekPlan(entries: entries.map((dto) => dto.toEntity()).toList());
  }
}
