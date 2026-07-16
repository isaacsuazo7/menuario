import 'package:menuario/src/shared/shared.dart';

/// Which section of the Cocinar view a [CookTarget]/[CookItem] belongs to.
enum CookGroup {
  /// "Para hoy" — cook it today.
  hoy,

  /// "Para mañana" — batch-cooked today, eaten tomorrow.
  manana,
}

/// One `(day, slot)` the default cook schedule points at for today's
/// batch-cook routine, tagged with the section it renders in.
typedef CookTarget = ({DayOfWeek targetDay, MealSlot slot, CookGroup group});

/// A resolved schedule target (Cocinar) or planned meal (Comer): the
/// planned [recipe] for [day]/[slot], carrying its source [entry] so the
/// caller can open `TodayMealDetailSheet` without a second lookup.
typedef CookItem = ({Recipe recipe, DayOfWeek day, MealSlot slot, PlanEntry entry});
