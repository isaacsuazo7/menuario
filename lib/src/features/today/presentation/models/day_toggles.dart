import 'package:menuario/src/features/today/domain/value_objects/cook_target.dart';
import 'package:menuario/src/shared/shared.dart';

/// The 3 per-day switches the schedule editor exposes for one source
/// `DateTime.weekday` (1..7): "Cena de hoy", "Des/Alm/Mer de mañana" and
/// "Des/Alm/Mer de hoy".
///
/// Not every combination is reachable in the UI: [toTargets] silently
/// drops any toggle whose mapped day would be Domingo (never a valid
/// [DayOfWeek]) — see [_eatingDaysFor].
typedef DayToggles = ({bool cenaHoy, bool damManana, bool damHoy});

/// The 3 batch-cook meal slots covered by a single "de mañana"/"de hoy"
/// toggle, in render order.
const _damSlots = [MealSlot.desayuno, MealSlot.almuerzo, MealSlot.merienda];

/// Resolves the plannable [DayOfWeek] this source weekday cooks *for*
/// today (`thisDay`) and *for* tomorrow (`nextDay`), or `null` when that
/// side has no valid [DayOfWeek] target.
///
/// Domingo (7) is never itself a valid target: it has no `thisDay` (it
/// isn't plannable) and its `nextDay` is Lunes. Sábado (6) has a `thisDay`
/// (Sábado) but no `nextDay` (Domingo isn't plannable either).
({DayOfWeek? thisDay, DayOfWeek? nextDay}) _eatingDaysFor(int weekday) {
  return switch (weekday) {
    DateTime.monday => (thisDay: DayOfWeek.lun, nextDay: DayOfWeek.mar),
    DateTime.tuesday => (thisDay: DayOfWeek.mar, nextDay: DayOfWeek.mie),
    DateTime.wednesday => (thisDay: DayOfWeek.mie, nextDay: DayOfWeek.jue),
    DateTime.thursday => (thisDay: DayOfWeek.jue, nextDay: DayOfWeek.vie),
    DateTime.friday => (thisDay: DayOfWeek.vie, nextDay: DayOfWeek.sab),
    DateTime.saturday => (thisDay: DayOfWeek.sab, nextDay: null),
    DateTime.sunday => (thisDay: null, nextDay: DayOfWeek.lun),
    _ => throw ArgumentError.value(weekday, 'weekday', 'must be 1..7'),
  };
}

/// Maps [toggles] for source [weekday] into the [CookTarget]s they
/// produce, per the fixed rule: `cenaHoy` -> 1 target (cena, today's
/// eating day); `damHoy` -> 3 targets (desayuno/almuerzo/merienda,
/// today's eating day); `damManana` -> 3 targets (desayuno/almuerzo/
/// merienda, tomorrow's eating day). Any toggle whose side has no valid
/// eating day (Sábado's `damManana`, Domingo's `cenaHoy`/`damHoy`) is
/// silently dropped.
List<CookTarget> toTargets(int weekday, DayToggles toggles) {
  final eating = _eatingDaysFor(weekday);
  final targets = <CookTarget>[];

  final thisDay = eating.thisDay;
  if (toggles.cenaHoy && thisDay != null) {
    targets.add((
      targetDay: thisDay,
      slot: MealSlot.cena,
      group: CookGroup.hoy,
    ));
  }
  if (toggles.damHoy && thisDay != null) {
    for (final slot in _damSlots) {
      targets.add((targetDay: thisDay, slot: slot, group: CookGroup.hoy));
    }
  }

  final nextDay = eating.nextDay;
  if (toggles.damManana && nextDay != null) {
    for (final slot in _damSlots) {
      targets.add((targetDay: nextDay, slot: slot, group: CookGroup.manana));
    }
  }

  return targets;
}

/// Reconstructs the [DayToggles] that produced [targets] for source
/// [weekday] — the inverse of [toTargets]. Always returns all-`false` for
/// a side with no valid eating day, so a schedule containing a target
/// that could not have come from this weekday's [toTargets] (e.g. stale
/// or hand-edited data) never surfaces a phantom toggle.
DayToggles fromTargets(int weekday, List<CookTarget> targets) {
  final eating = _eatingDaysFor(weekday);

  bool has(DayOfWeek? day, MealSlot slot, CookGroup group) {
    if (day == null) return false;
    return targets.any(
      (target) =>
          target.targetDay == day &&
          target.slot == slot &&
          target.group == group,
    );
  }

  return (
    cenaHoy: has(eating.thisDay, MealSlot.cena, CookGroup.hoy),
    damManana: has(eating.nextDay, MealSlot.desayuno, CookGroup.manana),
    damHoy: has(eating.thisDay, MealSlot.desayuno, CookGroup.hoy),
  );
}
