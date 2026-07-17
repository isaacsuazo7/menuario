/// The recipe category a [Recipe] is tagged with.
///
/// Unlike [MealSlot] (a daily plan slot), [MealType] is a recipe-level
/// classification: it does not imply the recipe is plannable into a given
/// day slot (e.g. `aderezo` has no daily-slot equivalent).
enum MealType {
  pregym,
  desayuno,
  almuerzo,
  merienda,
  cena,
  aderezo;

  /// The Spanish label used across the UI.
  String get label => switch (this) {
    MealType.pregym => 'Pre-gym',
    MealType.desayuno => 'Desayuno',
    MealType.almuerzo => 'Almuerzo',
    MealType.merienda => 'Merienda',
    MealType.cena => 'Cena',
    MealType.aderezo => 'Aderezo',
  };

  /// The lowercase string persisted at the data layer.
  String get wire => name;

  /// Maps a persisted wire string back to a [MealType].
  ///
  /// Returns `null` for `null` or any unrecognized value, so legacy or
  /// un-tagged recipe documents degrade gracefully instead of throwing.
  static MealType? fromWire(String? wire) {
    for (final value in MealType.values) {
      if (value.wire == wire) return value;
    }
    return null;
  }
}
