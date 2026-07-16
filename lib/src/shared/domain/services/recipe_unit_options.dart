import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/services/stock_lens_service.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_mode.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

/// The metric sibling for a continuous canonical [Unit]: grams pair with
/// kilograms, liters pair with milliliters. Discrete canonical units
/// ([Unit.count], [Unit.package]) have no metric sibling and are omitted.
final Map<Unit, Unit> _metricSiblingOf = {
  Unit.gram: Unit.kilogram,
  Unit.liter: Unit.milliliter,
};

/// The single authority for which recipe [Unit]s a BOM line may offer for
/// [ingredient]: every returned unit is guaranteed to convert cleanly via
/// `MeasurementConverter.toStockUnit` for THIS ingredient (never
/// `missingConversionFactor` or `unknownUnit`). Replaces the old flat,
/// global `recipeUnitOptions` list, which offered every ingredient the
/// exact same set regardless of its [Ingredient.measurementMode] or
/// whether it even has a [Ingredient.conversionFactor].
///
/// - [MeasurementMode.count]: strictly `{Unit.count}` — the converter
///   rejects any other unit outright.
/// - [MeasurementMode.mass]: `{Unit.gram, Unit.kilogram}` always (`kg`
///   normalizes to the canonical `g` via the converter's metric pre-pass,
///   needing no factor), plus `{Unit.cup, Unit.tablespoon}` only when
///   [Ingredient.conversionFactor] is set.
/// - [MeasurementMode.packageBase] / [MeasurementMode.packageAbstract]:
///   the canonical unit ([StockLensService.canonicalUnitFor]) plus its
///   metric sibling when one exists (`kg` for `g`, `ml` for `L`; none for
///   `u`/`paq`), plus `{Unit.cup, Unit.tablespoon}` only when a factor is
///   set.
/// - [MeasurementMode.boolean]: `{}` — never numerically tracked, so no
///   BOM unit makes sense (pre-existing `unknownUnit` behavior).
List<Unit> recipeUnitsFor(
  Ingredient ingredient, {
  StockLensService lensService = const StockLensService(),
}) {
  final hasFactor = ingredient.conversionFactor != null;
  switch (ingredient.measurementMode) {
    case MeasurementMode.count:
      return const [Unit.count];
    case MeasurementMode.mass:
      return [
        Unit.gram,
        Unit.kilogram,
        if (hasFactor) ...[Unit.cup, Unit.tablespoon],
      ];
    case MeasurementMode.packageBase:
    case MeasurementMode.packageAbstract:
      final canonical = lensService.canonicalUnitFor(ingredient);
      final sibling = _metricSiblingOf[canonical];
      return [
        canonical,
        ?sibling,
        if (hasFactor) ...[Unit.cup, Unit.tablespoon],
      ];
    case MeasurementMode.boolean:
      return const [];
  }
}
