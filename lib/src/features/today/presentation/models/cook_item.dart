import 'package:menuario/src/shared/shared.dart';

export 'package:menuario/src/features/today/domain/value_objects/cook_target.dart';

/// A resolved schedule target (Cocinar) or planned meal (Comer): the
/// planned [recipe] for [day]/[slot], carrying its source [entry] so the
/// caller can open `TodayMealDetailSheet` without a second lookup.
typedef CookItem = ({
  Recipe recipe,
  DayOfWeek day,
  MealSlot slot,
  PlanEntry entry,
});
