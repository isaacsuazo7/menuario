import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/entities/plan_entry.dart';

part 'week_plan.freezed.dart';

/// The single active week plan.
///
/// There is no notion of multiple stored week plans or plan history: a
/// [WeekPlan] carries no identity of its own, only its current
/// [entries]. Saving a new plan always overwrites the prior one — modeled
/// here via [overwriteWith], which fully replaces the entry list rather
/// than merging into it. The actual persistence-level overwrite (e.g. a
/// single Firestore document) is a `WeekPlanRepository` concern.
@freezed
abstract class WeekPlan with _$WeekPlan {
  const WeekPlan._();

  const factory WeekPlan({required List<PlanEntry> entries}) = _WeekPlan;

  /// Returns the [WeekPlan] that results from overwriting this one with
  /// [newEntries] — a full replacement, never a merge, and never a
  /// mutation of this instance.
  WeekPlan overwriteWith(List<PlanEntry> newEntries) {
    return WeekPlan(entries: newEntries);
  }
}
