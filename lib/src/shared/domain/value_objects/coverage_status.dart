/// A quantity-tracked ingredient's weekly-budget coverage, derived by
/// [CoverageCalculator] from its weekly need and current stock.
///
/// Boolean-tracked ingredients never carry this status — they keep the
/// existing have/don't-have pill (`StatePill`) instead.
enum CoverageStatus {
  /// Stock covers the whole weekly need (`stock >= need`).
  cubierto,

  /// Stock is nonzero but short of the weekly need, and not effectively
  /// zero (`0 < stock < need`).
  justo,

  /// Stock is effectively zero (rounds to zero at display precision) while
  /// there is a real weekly need — already on the Comprar list via the
  /// unchanged `shortfall`-driven path.
  falta,

  /// No trustworthy weekly-need signal: not planned this week, the
  /// calculation was skipped, or need/stock units don't line up. Renders
  /// with no coverage tint, distinct from — and never conflated with —
  /// [falta].
  neutral,
}
