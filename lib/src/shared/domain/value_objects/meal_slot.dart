/// A daily meal slot a [Recipe] can be planned into via a [PlanEntry].
enum MealSlot {
  desayuno,
  almuerzo,
  merienda,
  cena;

  /// The Spanish label used across the UI and persistence layers.
  String get label => switch (this) {
    MealSlot.desayuno => 'Desayuno',
    MealSlot.almuerzo => 'Almuerzo',
    MealSlot.merienda => 'Merienda',
    MealSlot.cena => 'Cena',
  };
}
