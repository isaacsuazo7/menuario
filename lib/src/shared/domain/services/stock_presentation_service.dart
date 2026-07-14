import 'package:menuario/src/shared/domain/entities/pantry_item.dart';
import 'package:menuario/src/shared/domain/value_objects/mass.dart';
import 'package:menuario/src/shared/domain/value_objects/presentation.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

/// The purchase-unit rendering of a quantity-tracked stock value: a numeric
/// [value] alongside its [unit] symbol/label, per [Presentation]. Widgets
/// control typography — this VO only owns the string content.
class StockDisplay {
  const StockDisplay({required this.value, required this.unit});

  /// The formatted numeric portion (e.g. `'1.75'`, `'1'`, `'7'`).
  final String value;

  /// The unit symbol or presentation label (e.g. `'lb'`, `'bolsa'`, `'u'`).
  final String unit;

  /// The full display string, e.g. `'1.75 lb'`, `'1 bolsa'`, `'7 u'`.
  String get label => '$value $unit';
}

/// Presentation-aware stock editing: computes the stepper's delta and the
/// on-screen display for quantity-tracked pantry stock, per
/// [PantryItem.presentation]. Sibling of `MeasurementConverter`, but never
/// ceils — a stock edit must land on the value the user chose, not a
/// shortfall rounded up to the next purchasable pack.
///
/// Pure and dependency-free (no repositories, no Flutter). Storage always
/// stays in the item's stock [Unit] (grams for mass, whole units for
/// count); this service only shapes how that value is stepped and shown.
class StockPresentationService {
  const StockPresentationService();

  /// The stepper delta for [item], expressed in the stock's OWN unit
  /// (grams for a mass-tracked item, count for a count-tracked item).
  ///
  /// - `loose`: +1 unit.
  /// - `package`: +1 pack, i.e. `presentation.yieldQty` in the stock's own
  ///   unit (grams for a bulk-yield pack, count for a unit-yield pack).
  /// - `counter`: +¼ lb, i.e. [Mass.gramsPerPound] / 4 grams.
  num stockStep(QuantityTrackedPantryItem item) {
    return switch (item.presentation) {
      PresentationLoose() => 1,
      PresentationPackage(:final yieldQty) => yieldQty,
      PresentationCounter() => Mass.gramsPerPound / 4,
    };
  }

  /// The purchase-unit rendering of [stock] under [presentation]. Storage
  /// (`stock.value`) is never mutated — this is presentation only.
  ///
  /// - `counter`: decimal pounds at 2dp, e.g. `'1.75 lb'`.
  /// - `package`: packs (`stock.value / yieldQty`), at most 2dp with
  ///   trailing zeros trimmed, plus `presentation.label`, e.g. `'1 bolsa'`.
  /// - `loose`: whole units, e.g. `'7 u'`.
  StockDisplay display(Quantity stock, Presentation presentation) {
    return switch (presentation) {
      PresentationCounter() => StockDisplay(
        value: (stock.value / Mass.gramsPerPound).toStringAsFixed(2),
        unit: 'lb',
      ),
      PresentationPackage(:final yieldQty, :final label) => StockDisplay(
        value: _trimTrailingZeros((stock.value / yieldQty).toStringAsFixed(2)),
        unit: label,
      ),
      PresentationLoose() => StockDisplay(
        value: stock.value.toInt().toString(),
        unit: 'u',
      ),
    };
  }

  /// Converts [naturalValue] — a value in the modal's natural unit (lb for
  /// `counter`, packs for `package`, whole units for `loose`) — into the
  /// stock's OWN unit for [presentation]. [stockUnit] tags the item's stock
  /// [Unit] (grams for mass, count for count) so callers can build the
  /// resulting `Quantity` directly; it does not change the conversion math,
  /// since [presentation] alone determines it.
  ///
  /// - `counter`: lb -> g, i.e. `naturalValue * Mass.gramsPerPound`.
  /// - `package`: packs -> stock unit, i.e. `naturalValue * yieldQty`.
  /// - `loose`: units -> stock unit, unchanged.
  num toStockValue({
    required num naturalValue,
    required Presentation presentation,
    required Unit stockUnit,
  }) {
    return switch (presentation) {
      PresentationCounter() => naturalValue * Mass.gramsPerPound,
      PresentationPackage(:final yieldQty) => naturalValue * yieldQty,
      PresentationLoose() => naturalValue,
    };
  }

  /// The inverse of [toStockValue]: converts [stockValue] (the item's
  /// stock-unit value) into the modal's natural unit for [presentation].
  ///
  /// - `counter`: g -> lb, i.e. `stockValue / Mass.gramsPerPound`.
  /// - `package`: stock unit -> packs, i.e. `stockValue / yieldQty`.
  /// - `loose`: unchanged.
  num toNaturalValue({
    required num stockValue,
    required Presentation presentation,
  }) {
    return switch (presentation) {
      PresentationCounter() => stockValue / Mass.gramsPerPound,
      PresentationPackage(:final yieldQty) => stockValue / yieldQty,
      PresentationLoose() => stockValue,
    };
  }

  /// Removes trailing fractional zeros (and a bare trailing `.`) left by
  /// `toStringAsFixed`, so `'1.00'` displays as `'1'` and `'0.50'` as
  /// `'0.5'`, without touching non-trimmable digits like `'1.32'`.
  String _trimTrailingZeros(String fixed) {
    if (!fixed.contains('.')) {
      return fixed;
    }
    var trimmed = fixed;
    while (trimmed.endsWith('0')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (trimmed.endsWith('.')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
