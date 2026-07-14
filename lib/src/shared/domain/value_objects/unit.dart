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
}
