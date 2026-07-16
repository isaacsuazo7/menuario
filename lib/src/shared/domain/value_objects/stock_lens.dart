import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_lens.freezed.dart';

/// A linear input/display scale for a stock value.
///
/// [label] is what the user sees (e.g. `'lb'`, `'bolsa'`); [canonicalPerUnit]
/// is the single factor that converts one unit of this lens into the
/// ingredient's canonical stock unit (e.g. 453.59237 g per lb, or a
/// package's `yieldQty` per pack). [allowsDecimal] gates fractional entry
/// — false only for count mode's whole-unit lens. Every real conversion in
/// this domain is a single linear factor, so lenses stay const and
/// trivially testable — no closures.
@freezed
abstract class StockLens with _$StockLens {
  const StockLens._();

  const factory StockLens({
    required String label,
    required num canonicalPerUnit,
    required bool allowsDecimal,
  }) = _StockLens;

  /// Converts [naturalValue] — a value expressed in this lens's unit —
  /// into the ingredient's canonical stock unit.
  num toCanonical(num naturalValue) => naturalValue * canonicalPerUnit;

  /// The inverse of [toCanonical]: converts [canonicalValue] — the
  /// ingredient's stored canonical value — into this lens's natural unit.
  num fromCanonical(num canonicalValue) => canonicalValue / canonicalPerUnit;
}
