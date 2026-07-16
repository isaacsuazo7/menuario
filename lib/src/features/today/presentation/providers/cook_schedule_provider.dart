import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/features/today/data/repositories/cook_schedule_repository_impl.dart';
import 'package:menuario/src/features/today/domain/entities/cook_schedule.dart';

/// Owns the single active, account-scoped [CookSchedule] and its
/// optimistic whole-schedule [save]/[reset].
///
/// A single `AsyncNotifier` (not a plain `FutureProvider`) because [save]
/// needs MUTABLE state to apply the edited schedule optimistically before
/// persistence resolves — mirrors `PlanController`.
final cookScheduleProvider =
    AsyncNotifierProvider<CookScheduleController, CookSchedule>(
      CookScheduleController.new,
      dependencies: [cookScheduleRepositoryProvider],
      // Disables Riverpod's default automatic-retry-with-backoff so a load
      // failure surfaces as `AsyncError` immediately — see the matching
      // note on `planControllerProvider`/`pantryControllerProvider`.
      retry: (retryCount, error) => null,
    );

/// Loads the active [CookSchedule] — falling back to [CookSchedule.seed]
/// when no schedule has been saved yet for the current user — and exposes
/// an optimistic whole-schedule [save] with functional rollback on
/// failure, plus [reset] to restore the seed.
class CookScheduleController extends AsyncNotifier<CookSchedule> {
  @override
  Future<CookSchedule> build() async {
    final repository = ref.watch(cookScheduleRepositoryProvider);
    final result = await repository.getActive();

    return result.fold(
      (failure) => throw FailureException(failure),
      (schedule) => schedule ?? CookSchedule.seed,
    );
  }

  /// Persists [schedule] as the whole active schedule, applying it to
  /// [state] optimistically first. On failure, reverts to the pre-edit
  /// snapshot and returns the [Failure]; on success, returns `null`.
  Future<Failure?> save(CookSchedule schedule) async {
    final snapshot = state.value;
    state = AsyncData(schedule);

    final repository = ref.read(cookScheduleRepositoryProvider);
    final result = await repository.save(schedule);

    if (!ref.mounted) return null;

    return result.fold((failure) {
      if (snapshot != null) {
        state = AsyncData(snapshot);
      }
      return failure;
    }, (_) => null);
  }

  /// Restores and persists [CookSchedule.seed] as the active schedule.
  Future<Failure?> reset() => save(CookSchedule.seed);
}
