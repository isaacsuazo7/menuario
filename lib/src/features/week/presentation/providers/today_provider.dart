import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/shared/shared.dart';

/// Maps a `DateTime.weekday` (Mon=1..Sun=7) to the plannable [DayOfWeek],
/// or `null` for Sunday — Domingo is excluded from the active `WeekPlan`,
/// so no section is ever highlighted on a Sunday.
DayOfWeek? dayOfWeekFromWeekday(int weekday) => switch (weekday) {
  DateTime.monday => DayOfWeek.lun,
  DateTime.tuesday => DayOfWeek.mar,
  DateTime.wednesday => DayOfWeek.mie,
  DateTime.thursday => DayOfWeek.jue,
  DateTime.friday => DayOfWeek.vie,
  DateTime.saturday => DayOfWeek.sab,
  _ => null,
};

/// Today as a plannable [DayOfWeek], or `null` on Sunday.
///
/// The single seam that touches the wall clock: [WeekScreen] reads it to
/// mark today's section, and tests override it with a fixed day (or `null`
/// for the Sunday case) instead of mocking `DateTime.now()`.
final todayProvider = Provider<DayOfWeek?>(
  (ref) => dayOfWeekFromWeekday(DateTime.now().weekday),
);
