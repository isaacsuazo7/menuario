import 'package:freezed_annotation/freezed_annotation.dart';

part 'presentation.freezed.dart';

/// How an [Ingredient] is purchased, driving the measurement engine's
/// stock-unit → purchase-quantity conversion.
@freezed
sealed class Presentation with _$Presentation {
  /// Bought as exact integer units (e.g. plátano, kiwi, manzana).
  const factory Presentation.loose() = PresentationLoose;

  /// Bought in fixed-yield packs, ceiled to whole packs. Covers both bulk
  /// packs (e.g. avena bolsa=454 g) and unit packs (e.g. huevo cartón,
  /// yield=15 u).
  const factory Presentation.package({
    required num yieldQty,
    required String label,
  }) = PresentationPackage;

  /// Weight sold by the pound at a counter, rounded up to the next
  /// quarter-pound and displayed as a fraction.
  const factory Presentation.counter() = PresentationCounter;
}
