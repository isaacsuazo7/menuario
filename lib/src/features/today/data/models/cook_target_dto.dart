import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/features/today/domain/value_objects/cook_target.dart';
import 'package:menuario/src/shared/shared.dart';

part 'cook_target_dto.freezed.dart';
part 'cook_target_dto.g.dart';

/// JSON representation of a single [CookTarget], tagged with the source
/// `DateTime.weekday` (1..7) it belongs to. Nested inside
/// `CookScheduleDTO.targets` as a flat list — mirrors `PlanEntryDTO`'s
/// `.name`/`.byName` enum-serialization convention.
@freezed
abstract class CookTargetDTO with _$CookTargetDTO {
  const factory CookTargetDTO({
    required int weekday,
    required String targetDay,
    required String slot,
    required String group,
  }) = _CookTargetDTO;

  const CookTargetDTO._();

  factory CookTargetDTO.fromJson(Map<String, dynamic> json) =>
      _$CookTargetDTOFromJson(json);

  /// Builds a [CookTargetDTO] from a [CookTarget] and the source [weekday]
  /// (`DateTime.weekday`, 1..7) it was resolved from.
  static CookTargetDTO fromEntity({
    required int weekday,
    required CookTarget target,
  }) {
    return CookTargetDTO(
      weekday: weekday,
      targetDay: target.targetDay.name,
      slot: target.slot.name,
      group: target.group.name,
    );
  }
}

/// Bidirectional mapper: [CookTargetDTO] -> [CookTarget].
extension CookTargetDTOX on CookTargetDTO {
  /// Rebuilds the [CookTarget] carried by this DTO (its [weekday] is used
  /// by the caller to group entries back into `CookSchedule.byWeekday`).
  CookTarget toEntity() {
    return (
      targetDay: DayOfWeek.values.byName(targetDay),
      slot: MealSlot.values.byName(slot),
      group: CookGroup.values.byName(group),
    );
  }
}
