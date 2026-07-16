/// How a tracked [Ingredient]'s stock is measured, entered and displayed.
///
/// Replaces the old `measurementKind` + `Presentation` + `booleanTracked`
/// triad with a single intrinsic classifier: each mode determines the
/// canonical stock unit, the available input lenses, and the smart
/// formatter's rendering rules.
enum MeasurementMode {
  /// Continuous weight, stored in grams (e.g. carne molida, arroz).
  mass,

  /// Discrete whole units, stored as an integer count (e.g. huevo, kiwi).
  count,

  /// Fixed-yield packages with a known base-unit dimension (e.g. leche
  /// bolsa=1 L, huevo cartón=15 u).
  packageBase,

  /// Decimal package counts with no known base-unit yield (e.g. lechuga
  /// bolsa, requesón pana).
  packageAbstract,

  /// Simple have/don't-have flag, never a numeric stock (e.g. sal).
  boolean,
}
