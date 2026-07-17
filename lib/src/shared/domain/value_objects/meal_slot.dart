/// A daily meal slot a [Recipe] can be planned into via a [PlanEntry].
enum MealSlot {
  pregym,
  desayuno,
  almuerzo,
  merienda,
  cena;

  /// The Spanish label used across the UI and persistence layers.
  String get label => switch (this) {
    MealSlot.pregym => 'Pre-gym',
    MealSlot.desayuno => 'Desayuno',
    MealSlot.almuerzo => 'Almuerzo',
    MealSlot.merienda => 'Merienda',
    MealSlot.cena => 'Cena',
  };
}
