import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/features/today/data/models/cook_target_dto.dart';
import 'package:menuario/src/features/today/domain/entities/cook_schedule.dart';
import 'package:menuario/src/features/today/domain/value_objects/cook_target.dart';

part 'cook_schedule_dto.freezed.dart';
part 'cook_schedule_dto.g.dart';

/// JSON representation of the single active [CookSchedule].
///
/// [CookSchedule] carries no identity of its own — it always lives at the
/// fixed `users/{uid}/cookSchedule/current` document — so no id is
/// injected on [CookScheduleDTOX.toEntity]. Mirrors `WeekPlanDTO`'s flat
/// list shape.
@freezed
abstract class CookScheduleDTO with _$CookScheduleDTO {
  const factory CookScheduleDTO({required List<CookTargetDTO> targets}) =
      _CookScheduleDTO;

  const CookScheduleDTO._();

  factory CookScheduleDTO.fromJson(Map<String, dynamic> json) =>
      _$CookScheduleDTOFromJson(json);

  /// Builds a [CookScheduleDTO] from a [CookSchedule] entity, flattening
  /// every weekday's target list into a single [targets] list.
  static CookScheduleDTO fromEntity(CookSchedule entity) {
    final targets = <CookTargetDTO>[
      for (final entry in entity.byWeekday.entries)
        for (final target in entry.value)
          CookTargetDTO.fromEntity(weekday: entry.key, target: target),
    ];
    return CookScheduleDTO(targets: targets);
  }
}

/// Bidirectional mapper: [CookScheduleDTO] -> [CookSchedule].
extension CookScheduleDTOX on CookScheduleDTO {
  /// Rebuilds the [CookSchedule] entity carried by this DTO, regrouping
  /// the flat [targets] list back by their source weekday.
  CookSchedule toEntity() {
    final byWeekday = <int, List<CookTarget>>{};
    for (final dto in targets) {
      (byWeekday[dto.weekday] ??= []).add(dto.toEntity());
    }
    return CookSchedule(byWeekday: byWeekday);
  }
}
