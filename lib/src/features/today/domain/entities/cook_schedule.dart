import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/features/today/domain/value_objects/cook_target.dart';
import 'package:menuario/src/shared/shared.dart';

part 'cook_schedule.freezed.dart';

/// The account's batch-cook routine: for each source `DateTime.weekday`
/// (1..7 — Sunday included as 7 so Cocinar can resolve Sunday -> Monday
/// even though [DayOfWeek] itself has no Domingo), the [CookTarget]s the
/// Cocinar view resolves against the active `WeekPlan`.
///
/// Account-scoped and editable (`users/{uid}/cookSchedule/current`); see
/// [seed] for the default routine used when no schedule has been saved
/// yet.
@freezed
abstract class CookSchedule with _$CookSchedule {
  const CookSchedule._();

  const factory CookSchedule({required Map<int, List<CookTarget>> byWeekday}) =
      _CookSchedule;

  /// The default batch-cook routine, used as a fallback whenever no
  /// schedule document exists for the current user.
  static const CookSchedule seed = CookSchedule(byWeekday: _seedByWeekday);

  /// The [CookTarget]s for source [weekday] (`DateTime.weekday`, 1..7), or
  /// an empty list when [weekday] has no mapped targets.
  List<CookTarget> targetsFor(int weekday) => byWeekday[weekday] ?? const [];
}

/// Isaac's default batch-cook routine.
const _seedByWeekday = <int, List<CookTarget>>{
  DateTime.monday: [
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
  ],
  DateTime.tuesday: [
    (targetDay: DayOfWeek.mar, slot: MealSlot.cena, group: CookGroup.hoy),
    (
      targetDay: DayOfWeek.mie,
      slot: MealSlot.desayuno,
      group: CookGroup.manana,
    ),
    (
      targetDay: DayOfWeek.mie,
      slot: MealSlot.almuerzo,
      group: CookGroup.manana,
    ),
    (
      targetDay: DayOfWeek.mie,
      slot: MealSlot.merienda,
      group: CookGroup.manana,
    ),
  ],
  DateTime.wednesday: [
    (targetDay: DayOfWeek.mie, slot: MealSlot.cena, group: CookGroup.hoy),
    (
      targetDay: DayOfWeek.jue,
      slot: MealSlot.desayuno,
      group: CookGroup.manana,
    ),
    (
      targetDay: DayOfWeek.jue,
      slot: MealSlot.almuerzo,
      group: CookGroup.manana,
    ),
    (
      targetDay: DayOfWeek.jue,
      slot: MealSlot.merienda,
      group: CookGroup.manana,
    ),
  ],
  DateTime.thursday: [
    (targetDay: DayOfWeek.jue, slot: MealSlot.cena, group: CookGroup.hoy),
    (
      targetDay: DayOfWeek.vie,
      slot: MealSlot.desayuno,
      group: CookGroup.manana,
    ),
    (
      targetDay: DayOfWeek.vie,
      slot: MealSlot.almuerzo,
      group: CookGroup.manana,
    ),
    (
      targetDay: DayOfWeek.vie,
      slot: MealSlot.merienda,
      group: CookGroup.manana,
    ),
  ],
  DateTime.friday: [
    (targetDay: DayOfWeek.vie, slot: MealSlot.cena, group: CookGroup.hoy),
  ],
  DateTime.saturday: [
    (targetDay: DayOfWeek.sab, slot: MealSlot.desayuno, group: CookGroup.hoy),
    (targetDay: DayOfWeek.sab, slot: MealSlot.almuerzo, group: CookGroup.hoy),
    (targetDay: DayOfWeek.sab, slot: MealSlot.merienda, group: CookGroup.hoy),
    (targetDay: DayOfWeek.sab, slot: MealSlot.cena, group: CookGroup.hoy),
  ],
  DateTime.sunday: [
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
  ],
};
