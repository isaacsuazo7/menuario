import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/features/today/presentation/models/cook_item.dart';
import 'package:menuario/src/shared/shared.dart';

/// The default batch-cook routine, keyed by `DateTime.weekday` (1..7,
/// Sunday included as 7) so Cocinar can resolve Sunday → Monday even though
/// [DayOfWeek] itself has no Domingo. `targetDay` stays a plannable
/// [DayOfWeek] — only the lookup key spans all 7 days.
const _seed = <int, List<CookTarget>>{
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

/// The default batch-cook schedule, keyed by `DateTime.weekday`.
///
/// A pure `const` seed today; the return type stays stable so a future
/// editable-schedule feature can swap this provider's body for a
/// Firestore-backed read with zero rework in [cookListProvider] or the
/// Cocinar widgets.
final cookScheduleProvider = Provider<Map<int, List<CookTarget>>>(
  (ref) => _seed,
);
