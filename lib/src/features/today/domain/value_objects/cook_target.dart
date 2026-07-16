import 'package:menuario/src/shared/shared.dart';

/// Which section of the Cocinar view a [CookTarget]/`CookItem` belongs to.
enum CookGroup {
  /// "Para hoy" — cook it today.
  hoy,

  /// "Para mañana" — batch-cooked today, eaten tomorrow.
  manana,
}

/// One `(day, slot)` the active cook schedule points at for today's
/// batch-cook routine, tagged with the section it renders in.
typedef CookTarget = ({DayOfWeek targetDay, MealSlot slot, CookGroup group});
