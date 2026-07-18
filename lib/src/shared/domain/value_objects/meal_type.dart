/// The recipe category a [Recipe] is tagged with.
///
/// Unlike [MealSlot] (a daily plan slot), [MealType] is a recipe-level
/// classification: it does not imply the recipe is plannable into a given
/// day slot (e.g. `aderezo` has no daily-slot equivalent).
///
/// Declaration order mirrors [MealSlot]'s real daily order (merienda BEFORE
/// almuerzo) so the Recetario filter chips read the same as Semana and Hoy;
/// `aderezo` trails because it has no daily-slot equivalent. Nothing
/// persists or compares a [MealType] by ordinal — the wire format is [name]
/// and [fromWire] matches by name — so this order is display-only.
enum MealType {
  pregym,
  desayuno,
  merienda,
  almuerzo,
  cena,
  aderezo;

  /// The Spanish label used across the UI.
  String get label => switch (this) {
    MealType.pregym => 'Pre-gym',
    MealType.desayuno => 'Desayuno',
    MealType.merienda => 'Merienda',
    MealType.almuerzo => 'Almuerzo',
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
