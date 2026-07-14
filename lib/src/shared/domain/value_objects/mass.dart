/// Shared mass conversion constants used across domain services.
///
/// Not tied to any single service so callers (e.g. [MeasurementConverter],
/// `StockPresentationService`) can depend on one source of truth without
/// importing each other just for a number.
abstract final class Mass {
  /// The standard avoirdupois pound, in grams.
  static const gramsPerPound = 453.59237;
}
