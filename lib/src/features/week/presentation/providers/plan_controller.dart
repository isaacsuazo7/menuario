import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/shared/shared.dart';

/// Owns the single active [WeekPlan] and its optimistic per-slot
/// assign/clear mutations.
///
/// A single `AsyncNotifier` (not a plain `FutureProvider`) because
/// [assign]/[clear] need MUTABLE state to patch optimistically before
/// `save()` resolves — mirrors `PantryController`, except every mutation
/// here is a whole-`WeekPlan` read-modify-write (there is no per-entry
/// document, only one active plan document).
final planControllerProvider = AsyncNotifierProvider<PlanController, WeekPlan>(
  PlanController.new,
  dependencies: [weekPlanRepositoryProvider],
  // Disables Riverpod's default automatic-retry-with-backoff so a load
  // failure surfaces as `AsyncError` immediately — see the matching note
  // on `pantryControllerProvider`/`recipeListProvider`.
  retry: (retryCount, error) => null,
);

/// Loads the active [WeekPlan] and exposes optimistic assign/clear edits
/// for a given `(day, mealSlot)` slot, with functional rollback on
/// `save()` failure.
class PlanController extends AsyncNotifier<WeekPlan> {
  @override
  Future<WeekPlan> build() async {
    final repository = ref.watch(weekPlanRepositoryProvider);
    final result = await repository.getActive();

    return result.fold(
      (failure) => throw FailureException(failure),
      (plan) => plan ?? const WeekPlan(entries: []),
    );
  }

  /// Assigns [recipeId] to the `(day, mealSlot)` slot, creating a new
  /// [PlanEntry] on an empty slot or replacing (never duplicating) the
  /// existing one on an occupied slot.
  ///
  /// The replaced/created entry carries the existing entry's `cooked` flag
  /// (or `false` for a brand-new entry) — assigning a recipe never resets
  /// or toggles `cooked`. Every other entry, and its own `cooked`, survives
  /// unchanged by construction (only the matching key is filtered out and
  /// re-appended).
  Future<Failure?> assign({
    required DayOfWeek day,
    required MealSlot mealSlot,
    required String recipeId,
  }) {
    return _upsert(day: day, mealSlot: mealSlot, recipeId: recipeId);
  }

  /// Removes the [PlanEntry] for the `(day, mealSlot)` slot, if any. A
  /// no-op slot still applies the (unchanged) plan optimistically and
  /// calls `save()`, matching [assign]'s optimistic/revert shape.
  Future<Failure?> clear({required DayOfWeek day, required MealSlot mealSlot}) {
    return _upsert(day: day, mealSlot: mealSlot, recipeId: null);
  }

  /// Shared assign/clear algorithm: filters out any existing entry for
  /// `(day, mealSlot)`, optionally re-appends a replacement (when
  /// [recipeId] is non-null) carrying the removed entry's `cooked` flag,
  /// applies the result optimistically, then persists the whole plan.
  ///
  /// On `save()` failure, reverts [state] to the pre-edit snapshot and
  /// returns the [Failure]; on success, returns `null`.
  Future<Failure?> _upsert({
    required DayOfWeek day,
    required MealSlot mealSlot,
    required String? recipeId,
  }) async {
    final snapshot = state.value;
    if (snapshot == null) return null;

    PlanEntry? existing;
    final remaining = <PlanEntry>[];
    for (final entry in snapshot.entries) {
      if (entry.day == day && entry.mealSlot == mealSlot) {
        existing = entry;
      } else {
        remaining.add(entry);
      }
    }

    final newEntries = [
      ...remaining,
      if (recipeId != null)
        PlanEntry(
          day: day,
          mealSlot: mealSlot,
          recipeId: recipeId,
          cooked: existing?.cooked ?? false,
        ),
    ];

    final newPlan = snapshot.overwriteWith(newEntries);
    state = AsyncData(newPlan);

    final repository = ref.read(weekPlanRepositoryProvider);
    final result = await repository.save(newPlan);

    if (!ref.mounted) return null;

    return result.fold((failure) {
      state = AsyncData(snapshot);
      return failure;
    }, (_) => null);
  }
}
