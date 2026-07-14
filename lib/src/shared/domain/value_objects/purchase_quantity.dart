import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_quantity.freezed.dart';

/// The final shopping-list quantity for an ingredient, in whatever shape
/// the shopper actually buys it in, produced by the measurement engine
/// from a stock-unit shortfall.
@freezed
sealed class PurchaseQuantity with _$PurchaseQuantity {
  const PurchaseQuantity._();

  /// Buy an exact integer number of loose units (e.g. plátano, kiwi).
  @Assert('units >= 0', 'units must be non-negative')
  const factory PurchaseQuantity.loosePurchase({required int units}) =
      LoosePurchase;

  /// Buy a whole number of fixed-yield packs (e.g. bolsas, cartones).
  @Assert('packs >= 0', 'packs must be non-negative')
  const factory PurchaseQuantity.packagePurchase({
    required int packs,
    required String label,
  }) = PackagePurchase;

  /// Buy weight at the counter, stored as the total number of quarter
  /// pounds so [display] can render an exact ¼ / ½ / ¾ / whole-lb
  /// fraction.
  @Assert('quarterPounds >= 0', 'quarterPounds must be non-negative')
  const factory PurchaseQuantity.counterPurchase({required int quarterPounds}) =
      CounterPurchase;

  /// A human-readable rendering of this purchase quantity, in Spanish.
  String get display => switch (this) {
    LoosePurchase(:final units) => '$units unidades',
    PackagePurchase(:final packs, :final label) => '$packs $label',
    CounterPurchase(:final quarterPounds) => _displayPounds(quarterPounds),
  };

  static String _displayPounds(int quarterPounds) {
    final wholePounds = quarterPounds ~/ 4;
    final remainderQuarters = quarterPounds % 4;
    final fraction = switch (remainderQuarters) {
      1 => '¼',
      2 => '½',
      3 => '¾',
      _ => '',
    };

    if (wholePounds == 0) {
      return fraction.isEmpty ? '0 lb' : '$fraction lb';
    }
    if (fraction.isEmpty) {
      return '$wholePounds lb';
    }
    return '$wholePounds $fraction lb';
  }
}
