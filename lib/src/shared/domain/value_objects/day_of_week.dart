import 'package:dartz/dartz.dart';
import 'package:menuario/src/core/error/failure.dart';

/// The six plannable days of the active `WeekPlan`.
///
/// Domingo is intentionally absent: [fromLabel] rejects it (and any other
/// unrecognized label) with a `Failure.invalidDay`.
enum DayOfWeek {
  lun,
  mar,
  mie,
  jue,
  vie,
  sab;

  /// The Spanish short label used across the UI and persistence layers.
  String get label => switch (this) {
    DayOfWeek.lun => 'Lun',
    DayOfWeek.mar => 'Mar',
    DayOfWeek.mie => 'Mié',
    DayOfWeek.jue => 'Jue',
    DayOfWeek.vie => 'Vie',
    DayOfWeek.sab => 'Sáb',
  };

  /// Parses a Spanish short [label] into a [DayOfWeek].
  ///
  /// Returns `Left(Failure.invalidDay(label))` for 'Dom' or any label that
  /// does not match Lun-Sáb.
  static Either<Failure, DayOfWeek> fromLabel(String label) {
    for (final day in DayOfWeek.values) {
      if (day.label == label) {
        return Right(day);
      }
    }
    return Left(Failure.invalidDay(label));
  }
}
