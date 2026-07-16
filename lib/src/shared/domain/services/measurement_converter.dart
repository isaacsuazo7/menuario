import 'package:dartz/dartz.dart' hide Unit;
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/services/stock_lens_service.dart';
import 'package:menuario/src/shared/domain/value_objects/mass.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_mode.dart';
import 'package:menuario/src/shared/domain/value_objects/presentation.dart';
import 'package:menuario/src/shared/domain/value_objects/purchase_quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

/// The deterministic measurement engine: converts a quantity across
/// recipe unit -> stock unit -> purchase presentation, per ingredient.
///
/// Pure and dependency-free (no repositories, no Flutter — [StockLensService]
/// is itself pure/Flutter-free, so injecting it here preserves that
/// contract). Every method returns `Either<Failure, T>` because both
/// conversions can legitimately fail: an [Ingredient] may be missing its
/// conversion factor, or a recipe quantity may carry a unit that does not
/// make sense for how the ingredient is tracked.
class MeasurementConverter {
  const MeasurementConverter({
    StockLensService lensService = const StockLensService(),
  }) : _lens = lensService;

  final StockLensService _lens;

  /// Converts [recipeQuantity] (as written on a `BomLine`) into its
  /// stock-unit equivalent for [ingredient], per
  /// [Ingredient.measurementMode]. The output [Quantity.unit] is always
  /// resolved via [StockLensService.canonicalUnitFor] — the single
  /// authority for an ingredient's stock unit.
  ///
  /// - [MeasurementMode.mass]: multiplies by [Ingredient.conversionFactor],
  ///   producing a quantity in [Unit.gram].
  /// - [MeasurementMode.count]: recipe unit already equals stock unit
  ///   ([Unit.count]), so the quantity passes through unchanged. Returns
  ///   `Left(Failure.unknownUnit)` when [recipeQuantity] is not in
  ///   [Unit.count].
  /// - [MeasurementMode.packageBase]: multiplies by
  ///   [Ingredient.conversionFactor] into the package's base-dimension unit
  ///   (e.g. liters for leche, not always grams).
  /// - [MeasurementMode.packageAbstract]: multiplies by
  ///   [Ingredient.conversionFactor] into a decimal package fraction
  ///   ([Unit.package]).
  /// - [MeasurementMode.boolean]: never reached in practice — boolean
  ///   items are gathered via
  ///   `ProvisioningCalculator.shouldSurfaceBooleanItem` instead. Defensive
  ///   `Left(Failure.unknownUnit)`.
  ///
  /// `mass`, `packageBase` and `packageAbstract` all return
  /// `Left(Failure.missingConversionFactor)` when the ingredient has no
  /// [Ingredient.conversionFactor].
  Either<Failure, Quantity> toStockUnit({
    required Quantity recipeQuantity,
    required Ingredient ingredient,
  }) {
    final stockUnit = _lens.canonicalUnitFor(ingredient);
    switch (ingredient.measurementMode) {
      case MeasurementMode.count:
        if (recipeQuantity.unit != Unit.count) {
          return Left(Failure.unknownUnit(recipeQuantity.unit.symbol));
        }
        return Right(recipeQuantity);
      case MeasurementMode.mass:
      case MeasurementMode.packageBase:
      case MeasurementMode.packageAbstract:
        final factor = ingredient.conversionFactor;
        if (factor == null) {
          return Left(Failure.missingConversionFactor(ingredient.name));
        }
        return Right(
          Quantity(value: recipeQuantity.value * factor, unit: stockUnit),
        );
      case MeasurementMode.boolean:
        return Left(Failure.unknownUnit(recipeQuantity.unit.symbol));
    }
  }

  /// Converts a stock-unit [stockShortfall] into the [PurchaseQuantity]
  /// shape dictated by [presentation]. Rounding always goes up — a
  /// shortfall must never be left unmet.
  ///
  /// - `loose`: ceils to the next integer unit.
  /// - `package`: ceils to the next whole pack of `presentation.yieldQty`.
  /// - `counter`: converts grams to pounds and ceils to the next
  ///   quarter-pound.
  Either<Failure, PurchaseQuantity> toPurchaseQuantity({
    required Quantity stockShortfall,
    required Presentation presentation,
  }) {
    return switch (presentation) {
      PresentationLoose() => Right(
        PurchaseQuantity.loosePurchase(units: stockShortfall.value.ceil()),
      ),
      PresentationPackage(:final yieldQty, :final label) => Right(
        PurchaseQuantity.packagePurchase(
          packs: (stockShortfall.value / yieldQty).ceil(),
          label: label,
        ),
      ),
      PresentationCounter() => Right(
        PurchaseQuantity.counterPurchase(
          quarterPounds: _gramsToQuarterPounds(stockShortfall.value),
        ),
      ),
    };
  }

  /// Floating-point noise (e.g. from a chain of prior arithmetic) can push
  /// a shortfall that is mathematically exactly on a ¼-lb boundary a few
  /// ULPs above it, which would make a bare `.ceil()` over-round to the
  /// next quarter. Rounding the pre-ceil quotient to microgram precision
  /// (1e-6) absorbs that noise without under-rounding any genuine
  /// just-above-boundary value, since real shortfalls never carry
  /// meaningful precision below a whole gram.
  int _gramsToQuarterPounds(num grams) {
    final quarters = (grams / Mass.gramsPerPound) * 4;
    final roundedQuarters = double.parse(quarters.toStringAsFixed(6));
    return roundedQuarters.ceil();
  }
}
