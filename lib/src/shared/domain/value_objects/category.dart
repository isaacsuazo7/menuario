/// The pantry/shopping category an [Ingredient] belongs to.
enum Category {
  proteina,
  vegetal,
  fruta,
  cereal,
  lacteo,
  condimento,
  semilla,
  otro;

  /// The Spanish label used across the UI and persistence layers.
  String get label => switch (this) {
    Category.proteina => 'Proteína',
    Category.vegetal => 'Vegetal',
    Category.fruta => 'Fruta',
    Category.cereal => 'Cereal',
    Category.lacteo => 'Lácteo',
    Category.condimento => 'Condimento',
    Category.semilla => 'Semilla',
    Category.otro => 'Otro',
  };
}
