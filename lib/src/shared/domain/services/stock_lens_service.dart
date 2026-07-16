import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/value_objects/mass.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_mode.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/stock_lens.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

/// The clean-fraction glyphs the smart formatter matches against, in
/// priority order. Each decimal is checked within [_fractionEpsilon] of a
/// stored value; the first match wins (checked in table order, so ties are
/// resolved by declaration order rather than distance). A list of records
/// (not a `Map<double, ...>`) because `double` keys lack primitive
/// equality and cannot be const-map keys.
const List<(double, String)> _fractionGlyphs = [
  (0.5, '½'),
  (0.25, '¼'),
  (1 / 3, '⅓'),
  (0.75, '¾'),
  (0.2, '⅕'),
];

/// Clean-fraction match tolerance, per the smart formatter requirement.
/// Tight enough that a real g→lb conversion landing near-but-not-on a
/// glyph (e.g. 800 g ≈ 1.76 lb, 1.4 pp off ¾) still falls through to the
/// 2dp decimal fallback, while genuine floating-point wobble around an
/// exact fraction (e.g. 1/3 = 0.3333...) still matches.
const double _fractionEpsilon = 0.005;

/// Generalizes the mode-driven canonical storage, input lenses, stepping,
/// display formatting and effective-zero status for every
/// [MeasurementMode]. Successor to `StockPresentationService`, which this
/// replaces once every consumer moves to [MeasurementMode]-based
/// ingredients.
///
/// Pure and dependency-free (no repositories, no Flutter). Storage always
/// stays in [canonicalUnitFor]'s unit (grams for mass, whole units for
/// count, the package's base dimension for packageBase, decimal packages
/// for packageAbstract); every lens is a linear scale on top of that one
/// stored value — see [StockLens].
class StockLensService {
  const StockLensService();

  /// The available input/display lenses for [ingredient], per its
  /// [Ingredient.measurementMode]:
  /// - `mass`: `g` (1:1) and `lb` (453.59237 g), both decimal.
  /// - `count`: a single integer-only `u` lens.
  /// - `packageBase`: the pack lens (`package.label`, factor
  ///   `package.yieldQty`) and the base-dimension lens (`baseDimension`'s
  ///   symbol, 1:1), both decimal.
  /// - `packageAbstract`: a single decimal pack lens (`package.label`,
  ///   1:1).
  /// - `boolean`: no lenses — never numerically tracked.
  List<StockLens> lensesFor(Ingredient ingredient) {
    return switch (ingredient.measurementMode) {
      MeasurementMode.mass => const [
        StockLens(label: 'g', canonicalPerUnit: 1, allowsDecimal: true),
        StockLens(
          label: 'lb',
          canonicalPerUnit: Mass.gramsPerPound,
          allowsDecimal: true,
        ),
      ],
      MeasurementMode.count => const [
        StockLens(label: 'u', canonicalPerUnit: 1, allowsDecimal: false),
      ],
      MeasurementMode.packageBase => [
        StockLens(
          label: ingredient.package!.label,
          canonicalPerUnit: ingredient.package!.yieldQty ?? 1,
          allowsDecimal: true,
        ),
        StockLens(
          label: ingredient.package!.baseDimension?.symbol ?? '',
          canonicalPerUnit: 1,
          allowsDecimal: true,
        ),
      ],
      MeasurementMode.packageAbstract => [
        StockLens(
          label: ingredient.package?.label ?? 'paquete',
          canonicalPerUnit: 1,
          allowsDecimal: true,
        ),
      ],
      MeasurementMode.boolean => const [],
    };
  }

  /// The default lens for [ingredient]: [Ingredient.defaultLensLabel] wins
  /// when it names one of [lensesFor]'s lenses; otherwise the per-mode
  /// heuristic applies — mass→lb, count→u, packageBase→the pack lens,
  /// packageAbstract→the pack lens.
  StockLens defaultLensFor(Ingredient ingredient) {
    final lenses = lensesFor(ingredient);
    final overrideLabel = ingredient.defaultLensLabel;
    if (overrideLabel != null) {
      for (final lens in lenses) {
        if (lens.label == overrideLabel) {
          return lens;
        }
      }
    }
    return switch (ingredient.measurementMode) {
      MeasurementMode.mass => lenses.last,
      MeasurementMode.count => lenses.first,
      MeasurementMode.packageBase => lenses.first,
      MeasurementMode.packageAbstract => lenses.first,
      MeasurementMode.boolean => throw StateError(
        'boolean-mode ingredients have no default lens: '
        '${ingredient.id}',
      ),
    };
  }

  /// The stepper delta for [ingredient], expressed in its canonical stock
  /// unit — a quarter of the default lens's unit for continuous modes
  /// (mass, packageBase), exactly 1 whole unit for count, a
  /// percent-granular 0.01 for packageAbstract, and 0 (n/a) for boolean.
  num stockStep(Ingredient ingredient) {
    return switch (ingredient.measurementMode) {
      MeasurementMode.mass => defaultLensFor(ingredient).canonicalPerUnit / 4,
      MeasurementMode.count => 1,
      MeasurementMode.packageBase =>
        defaultLensFor(ingredient).canonicalPerUnit / 4,
      MeasurementMode.packageAbstract => 0.01,
      MeasurementMode.boolean => 0,
    };
  }

  /// The single authority for [ingredient]'s canonical stock [Unit]:
  /// grams for mass, count for count, the package's base dimension for
  /// packageBase (falling back to count if unset), the abstract package
  /// unit for packageAbstract, and count for boolean (never actually
  /// stored numerically).
  Unit canonicalUnitFor(Ingredient ingredient) {
    return switch (ingredient.measurementMode) {
      MeasurementMode.mass => Unit.gram,
      MeasurementMode.count => Unit.count,
      MeasurementMode.packageBase =>
        ingredient.package?.baseDimension ?? Unit.count,
      MeasurementMode.packageAbstract => Unit.package,
      MeasurementMode.boolean => Unit.count,
    };
  }

  /// Renders [stock] through [ingredient]'s default lens using the smart
  /// fraction/percent formatter: (1) if the lens value's fractional part
  /// is within [_fractionEpsilon] of a clean fraction (½ ¼ ⅓ ¾ ⅕), render
  /// the glyph (with a leading whole-part digit for mixed numbers); (2)
  /// else, for packageAbstract, render a percent; (3) else render a
  /// trimmed 2-decimal-place number. Always suffixed with the lens label.
  String formatStock(Ingredient ingredient, Quantity stock) {
    final lens = defaultLensFor(ingredient);
    final natural = lens.fromCanonical(stock.value);
    final whole = natural.truncate();
    final fraction = (natural - whole).abs();
    final glyph = _matchFractionGlyph(fraction);

    if (glyph != null) {
      final wholePart = whole == 0 ? '' : '$whole';
      return '$wholePart$glyph ${lens.label}';
    }

    if (ingredient.measurementMode == MeasurementMode.packageAbstract) {
      final percent = (natural * 100).round();
      return '$percent% ${lens.label}';
    }

    return '${_trimTrailingZeros(natural.toStringAsFixed(2))} ${lens.label}';
  }

  /// Whether [stock] should read as "no tengo" despite a possibly
  /// nonzero raw canonical value: true when the canonical value is
  /// exactly zero, or when it rounds to zero at [ingredient]'s default-
  /// lens display precision (2dp).
  bool isEffectivelyZero(Ingredient ingredient, Quantity stock) {
    if (stock.value == 0) {
      return true;
    }
    final lens = defaultLensFor(ingredient);
    final natural = lens.fromCanonical(stock.value);
    return natural.abs().toStringAsFixed(2) == '0.00';
  }

  String? _matchFractionGlyph(num fraction) {
    for (final (value, glyph) in _fractionGlyphs) {
      if ((fraction - value).abs() <= _fractionEpsilon) {
        return glyph;
      }
    }
    return null;
  }

  /// Removes trailing fractional zeros (and a bare trailing `.`) left by
  /// `toStringAsFixed`, so `'1.00'` displays as `'1'` and `'1.50'` as
  /// `'1.5'`, without touching non-trimmable digits like `'1.76'`.
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
