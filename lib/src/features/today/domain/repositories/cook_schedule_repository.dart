import 'package:dartz/dartz.dart' hide Unit;
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/today/domain/entities/cook_schedule.dart';

/// Persistence port for the single active, account-scoped [CookSchedule].
///
/// Mirrors `WeekPlanRepository`: single-active semantics — [getActive]
/// returns `Right(null)` when no schedule has been saved yet (callers
/// fall back to [CookSchedule.seed]), and [save] always fully
/// **overwrites** whatever schedule was previously active.
abstract class CookScheduleRepository {
  /// Returns the currently active [CookSchedule], or `Right(null)` when
  /// no schedule has been saved yet.
  Future<Either<Failure, CookSchedule?>> getActive();

  /// Persists [schedule] as the active schedule, overwriting whatever
  /// schedule was previously active.
  Future<Either<Failure, void>> save(CookSchedule schedule);
}
