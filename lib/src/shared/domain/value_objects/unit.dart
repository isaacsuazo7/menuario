import 'package:freezed_annotation/freezed_annotation.dart';

part 'unit.freezed.dart';

/// The physical dimension a [Unit] measures.
///
/// `mass` and `volume` are continuous (bulk) dimensions that require a
/// per-ingredient conversion factor to reach a recipe unit (e.g. taza).
/// `count` is discrete and always exact (e.g. huevo, u).
enum UnitDimension { mass, volume, count }

/// A measurement unit symbol (e.g. `g`, `L`, `u`, `taza`) tagged with the
/// physical [UnitDimension] it belongs to.
@freezed
abstract class Unit with _$Unit {
  const Unit._();

  const factory Unit({
    required String symbol,
    required UnitDimension dimension,
  }) = _Unit;

  /// The canonical mass stock unit: grams.
  static const Unit gram = Unit(symbol: 'g', dimension: UnitDimension.mass);

  /// The canonical volume stock unit: liters.
  static const Unit liter = Unit(symbol: 'L', dimension: UnitDimension.volume);

  /// The canonical count stock unit: whole units.
  static const Unit count = Unit(symbol: 'u', dimension: UnitDimension.count);

  /// The canonical stock unit for packageAbstract-mode ingredients: a
  /// decimal package count with no known base-unit yield (e.g. lechuga
  /// bolsa, requesón pana).
  static const Unit package = Unit(
    symbol: 'paq',
    dimension: UnitDimension.count,
  );

  /// A recipe-only mass unit: 1000 [gram]. Never a stock unit — normalized
  /// to [gram] by `MeasurementConverter`'s metric pre-pass before any
  /// mode-driven conversion runs.
  static const Unit kilogram = Unit(
    symbol: 'kg',
    dimension: UnitDimension.mass,
  );

  /// A recipe-only volume unit: 0.001 [liter]. Never a stock unit —
  /// normalized to [liter] by `MeasurementConverter`'s metric pre-pass
  /// before any mode-driven conversion runs.
  static const Unit milliliter = Unit(
    symbol: 'ml',
    dimension: UnitDimension.volume,
  );

  /// A recipe-only volume unit requiring [Ingredient.conversionFactor]:
  /// taza (cup). Named consts for what were previously inline `Unit`
  /// literals in `_bom_editor.dart`'s now-superseded `recipeUnitOptions`.
  static const Unit cup = Unit(symbol: 'taza', dimension: UnitDimension.volume);

  /// A recipe-only volume unit requiring [Ingredient.conversionFactor]:
  /// cucharada (tablespoon). See [cup].
  static const Unit tablespoon = Unit(
    symbol: 'cda',
    dimension: UnitDimension.volume,
  );
}
