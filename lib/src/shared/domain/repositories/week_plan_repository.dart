import 'package:dartz/dartz.dart' hide Unit;
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/entities/week_plan.dart';

/// Persistence port for the single active [WeekPlan].
///
/// Pure abstract contract: no Flutter/Firebase dependency, no
/// implementation. A concrete `WeekPlanRepositoryImpl` (backed by
/// Firestore) is added in a later data-layer change.
///
/// Single-active-week semantics: there is no notion of week-plan history.
/// At most one [WeekPlan] is ever stored. [getActive] returns it (or
/// `Right(null)` when none has been saved yet), and [save] always fully
/// **overwrites** whatever plan was previously active — it is never an
/// append or a merge. Enforcing this is a concrete implementation's
/// responsibility (e.g. writing to a single well-known document); this
/// interface only documents and names the contract.
abstract class WeekPlanRepository {
  /// Returns the currently active [WeekPlan], or `Right(null)` when no
  /// plan has been saved yet.
  Future<Either<Failure, WeekPlan?>> getActive();

  /// Persists [weekPlan] as the active plan, overwriting whatever plan was
  /// previously active. No history is kept.
  Future<Either<Failure, void>> save(WeekPlan weekPlan);
}
