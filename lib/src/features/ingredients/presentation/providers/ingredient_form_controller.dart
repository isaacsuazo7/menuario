import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// The "¿Cómo lo medís?" top-level choice. `package` covers BOTH
/// [MeasurementMode.packageBase] and [MeasurementMode.packageAbstract] —
/// which one applies is resolved from whether the package fields carry a
/// complete yield + base-unit pair (see
/// [IngredientFormController.measurementMode]).
enum IngredientModeChoice { mass, count, package, boolean }

/// The base-unit dropdown's fixed option set for a `Por paquete` package
/// with a known yield (packageBase); `null` means "sin base"
/// (packageAbstract).
const List<Unit?> ingredientBaseUnitOptions = [
  null,
  Unit.gram,
  Unit.liter,
  Unit.count,
];

String ingredientBaseUnitLabel(Unit? unit) => switch (unit) {
  null => 'Sin base (abstracto)',
  Unit.gram => 'Gramos (g)',
  Unit.liter => 'Litros (L)',
  Unit.count => 'Unidades (u)',
  _ => unit.symbol,
};

/// Pure and dependency-free (see [StockLensService]'s "no DI needed"
/// design decision) — safe to hold as a single const instance.
const _stockLensService = StockLensService();

IngredientModeChoice _modeChoiceFor(MeasurementMode mode) => switch (mode) {
  MeasurementMode.mass => IngredientModeChoice.mass,
  MeasurementMode.count => IngredientModeChoice.count,
  MeasurementMode.packageBase => IngredientModeChoice.package,
  MeasurementMode.packageAbstract => IngredientModeChoice.package,
  MeasurementMode.boolean => IngredientModeChoice.boolean,
};

/// Trims trailing fractional zeros (and a bare trailing `.`).
String formatNumber(num value) {
  var fixed = value.toStringAsFixed(2);
  while (fixed.contains('.') && fixed.endsWith('0')) {
    fixed = fixed.substring(0, fixed.length - 1);
  }
  if (fixed.endsWith('.')) {
    fixed = fixed.substring(0, fixed.length - 1);
  }
  return fixed;
}

/// [formatNumber], rounding first for integer-only lenses (never carry a
/// decimal point).
String formatNatural(num value, StockLens lens) {
  if (!lens.allowsDecimal) return value.round().toString();
  return formatNumber(value);
}

/// Rejects the [FormGroup] (disables Confirm) unless every field required
/// by the current mode is filled in — mirrors the previous
/// `_IngredientFormScreenState._canConfirm` getter.
class _CanConfirmValidator extends Validator<dynamic> {
  const _CanConfirmValidator();

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    if (control is! FormGroup) return null;
    return IngredientFormController.canConfirm(control)
        ? null
        : {'incomplete': true};
  }
}

/// Owns the ingredient create/edit [FormGroup] — including the derived
/// "¿Cómo lo medís?" (mode), package and default-lens fields — plus the
/// [StockLensService]-driven derived-value helpers the screen renders from.
///
/// `dependencies: const []` — the controller reads/writes only its own
/// form state, no other provider.
final ingredientFormControllerProvider =
    NotifierProvider.autoDispose<IngredientFormController, FormGroup>(
      IngredientFormController.new,
      dependencies: const [],
    );

class IngredientFormController extends Notifier<FormGroup> {
  @override
  FormGroup build() {
    return FormGroup(
      {
        'name': FormControl<String>(validators: [Validators.required]),
        'emoji': FormControl<String>(value: ''),
        'category': FormControl<Category>(value: Category.otro),
        'modeChoice': FormControl<IngredientModeChoice>(
          value: IngredientModeChoice.mass,
        ),
        'needType': FormControl<NeedType>(value: NeedType.recipeDriven),
        'packageLabel': FormControl<String>(value: ''),
        'packageYield': FormControl<String>(value: ''),
        'packageBaseUnit': FormControl<Unit?>(),
        'packageInnerLabel': FormControl<String>(value: ''),
        'packageInnerQty': FormControl<String>(value: ''),
        'packageInnerCount': FormControl<String>(value: ''),
        'conversionFactor': FormControl<String>(value: ''),
        'stock': FormControl<String>(value: ''),
        'haveIt': FormControl<bool>(value: false),
        'lensOverrideLabel': FormControl<String?>(),
      },
      validators: [const _CanConfirmValidator()],
    );
  }

  /// Copies [ingredient]'s fields into the form, once — mirrors the
  /// previous `_IngredientFormScreenState._prefill` (edit-mode prefill
  /// guard lives in the screen, which calls this only the first time the
  /// ingredient loads).
  void prefillIngredient(Ingredient ingredient) {
    state.control('name').value = ingredient.name;
    state.control('emoji').value = ingredient.emoji ?? '';
    state.control('category').value = ingredient.category;
    state.control('modeChoice').value = _modeChoiceFor(
      ingredient.measurementMode,
    );
    state.control('lensOverrideLabel').value = ingredient.defaultLensLabel;
    state.control('needType').value = ingredient.needType;
    if (ingredient.conversionFactor != null) {
      state.control('conversionFactor').value = ingredient.conversionFactor
          .toString();
    }
    final package = ingredient.package;
    if (package != null) {
      state.control('packageLabel').value = package.label;
      if (package.yieldQty != null) {
        state.control('packageYield').value = formatNumber(package.yieldQty!);
      }
      state.control('packageBaseUnit').value = package.baseDimension;
      state.control('packageInnerLabel').value = package.innerLabel ?? '';
      if (package.innerQty != null) {
        state.control('packageInnerQty').value = formatNumber(
          package.innerQty!,
        );
      }
      if (package.innerCount != null) {
        state.control('packageInnerCount').value = formatNumber(
          package.innerCount!,
        );
      }
    }
  }

  /// Copies [pantryItem]'s stock (or have-flag) into the form, once. Must
  /// run AFTER [prefillIngredient], so [selectedLens] already reflects the
  /// prefilled mode, package and lens override.
  void prefillPantry(PantryItem pantryItem) {
    switch (pantryItem) {
      case QuantityTrackedPantryItem(:final stock):
        final lens = selectedLens(state);
        if (lens != null) {
          final naturalValue = lens.fromCanonical(stock.value);
          state.control('stock').value = formatNatural(naturalValue, lens);
        }
      case BooleanTrackedPantryItem(:final haveIt):
        state.control('haveIt').value = haveIt;
    }
  }

  /// Switches the active lens, re-scaling the stock field to the same
  /// canonical value expressed in the new lens's unit, and persists the
  /// choice as `lensOverrideLabel` (-> [Ingredient.defaultLensLabel]).
  void handleLensChanged(StockLens newLens) {
    final oldLens = selectedLens(state);
    final parsed = parsedStockValue(state);
    final canonical = (oldLens != null && parsed != null)
        ? oldLens.toCanonical(parsed)
        : null;

    state.control('lensOverrideLabel').value = newLens.label;

    if (canonical != null) {
      state.control('stock').value = formatNatural(
        newLens.fromCanonical(canonical),
        newLens,
      );
    }
  }

  void handleModeChanged(IngredientModeChoice mode) {
    state.control('modeChoice').value = mode;
    state.control('lensOverrideLabel').value = null;
  }

  /// The trimmed text of [form]'s [name] control.
  static String _text(FormGroup form, String name) =>
      (form.control(name).value as String? ?? '').trim();

  /// The positive [num] typed into [form]'s [name] control, or `null` when
  /// it is empty, unparseable or non-positive.
  static num? _positiveField(FormGroup form, String name) {
    final value = num.tryParse(_text(form, name));
    return (value == null || value <= 0) ? null : value;
  }

  /// Whether the package block is coherent enough to persist.
  ///
  /// `Por paquete` REQUIRES a package name. `Por unidad` leaves the whole
  /// block optional, but once any detail is typed the name becomes required
  /// too — otherwise [packageSpec] would drop those numbers on save. The
  /// yield pairs with the base unit only where that unit is shown, and the
  /// inner level persists only as a COMPLETE pair: a lone innerQty or
  /// innerCount would likewise be silently dropped.
  static bool _packageFieldsValid(FormGroup form) {
    final label = _text(form, 'packageLabel');
    final yieldText = _text(form, 'packageYield');
    final innerQtyText = _text(form, 'packageInnerQty');
    final innerCountText = _text(form, 'packageInnerCount');

    if (label.isEmpty) {
      final hasDetail =
          yieldText.isNotEmpty ||
          innerQtyText.isNotEmpty ||
          innerCountText.isNotEmpty ||
          _text(form, 'packageInnerLabel').isNotEmpty;
      return !usesPackageAsStockUnit(form) && !hasDetail;
    }

    if (yieldText.isNotEmpty && _positiveField(form, 'packageYield') == null) {
      return false;
    }
    if (usesPackageAsStockUnit(form)) {
      final hasBaseUnit = form.control('packageBaseUnit').value != null;
      if (yieldText.isNotEmpty != hasBaseUnit) return false;
    }

    if (innerQtyText.isEmpty != innerCountText.isEmpty) return false;
    if (innerQtyText.isNotEmpty) {
      if (_positiveField(form, 'packageInnerQty') == null) return false;
      if (_positiveField(form, 'packageInnerCount') == null) return false;
    }
    return true;
  }

  /// Whether [form]'s mode can carry a [PackageSpec] at all.
  ///
  /// `Por paquete` is measured BY the package; `Por unidad` is measured in
  /// units but may still be BOUGHT by the package (salmas: stock in `u`,
  /// purchased by whole cajas). Both therefore render and persist the
  /// package block — for `Por unidad` it is entirely optional.
  static bool allowsPackage(FormGroup form) {
    final mode = form.control('modeChoice').value as IngredientModeChoice;
    return mode == IngredientModeChoice.package ||
        mode == IngredientModeChoice.count;
  }

  /// Whether [form]'s mode uses the package as its STOCK unit, which is the
  /// only case where a base dimension (`Unidad base`) is meaningful.
  static bool usesPackageAsStockUnit(FormGroup form) =>
      form.control('modeChoice').value == IngredientModeChoice.package;

  /// The [PackageSpec] built from [form]'s current package fields, or
  /// `null` when the mode carries no package ([allowsPackage]) or the name
  /// is still empty.
  ///
  /// [PackageSpec.yieldQty] is the DIRECT total one outer pack holds. In
  /// `Por paquete` it pairs with [PackageSpec.baseDimension] and is
  /// populated only when BOTH are filled (an unpaired yield has no unit to
  /// live in). In `Por unidad` the total is already in whole units, so the
  /// yield stands alone and the base dimension stays null.
  ///
  /// The inner level ([PackageSpec.innerQty]/[PackageSpec.innerCount]) is
  /// likewise populated only as a complete PAIR — a half-filled inner level
  /// would silently change [PackageSpec.effectiveYieldQty]'s fallback.
  static PackageSpec? packageSpec(FormGroup form) {
    if (!allowsPackage(form)) return null;

    final label = (form.control('packageLabel').value as String? ?? '').trim();
    if (label.isEmpty) return null;

    final yieldQty = _positiveField(form, 'packageYield');
    final baseUnit = form.control('packageBaseUnit').value as Unit?;
    final needsBaseUnit = usesPackageAsStockUnit(form);
    final hasYield =
        yieldQty != null && (!needsBaseUnit || baseUnit != null);

    final innerQty = _positiveField(form, 'packageInnerQty');
    final innerCount = _positiveField(form, 'packageInnerCount');
    final hasInner = innerQty != null && innerCount != null;
    final innerLabel =
        (form.control('packageInnerLabel').value as String? ?? '').trim();

    return PackageSpec(
      label: label,
      yieldQty: hasYield ? yieldQty : null,
      baseDimension: hasYield && needsBaseUnit ? baseUnit : null,
      innerLabel: hasInner && innerLabel.isNotEmpty ? innerLabel : null,
      innerQty: hasInner ? innerQty : null,
      innerCount: hasInner ? innerCount : null,
    );
  }

  /// The "8 bolsas × 3 u = 24 u por caja" helper line, or `null` while the
  /// inner level is still incomplete — so the user reads the total instead
  /// of multiplying it by hand.
  static String? innerPackHelperText(FormGroup form) {
    final spec = packageSpec(form);
    final breakdown = spec?.innerBreakdown;
    final total = spec?.effectiveYieldQty;
    if (spec == null || breakdown == null || total == null) return null;
    return '$breakdown = ${formatNumber(total)} u por ${spec.label}';
  }

  /// The [MeasurementMode] the form currently describes.
  ///
  /// Only `Por paquete` resolves between packageBase/packageAbstract. `Por
  /// unidad` stays [MeasurementMode.count] even once a package is attached
  /// — a count ingredient bought by the caja is still STOCKED and consumed
  /// in units; promoting it to a package mode would re-scale its pantry.
  static MeasurementMode measurementMode(FormGroup form) {
    final mode = form.control('modeChoice').value as IngredientModeChoice;
    return switch (mode) {
      IngredientModeChoice.mass => MeasurementMode.mass,
      IngredientModeChoice.count => MeasurementMode.count,
      IngredientModeChoice.package =>
        packageSpec(form)?.yieldQty != null &&
                packageSpec(form)?.baseDimension != null
            ? MeasurementMode.packageBase
            : MeasurementMode.packageAbstract,
      IngredientModeChoice.boolean => MeasurementMode.boolean,
    };
  }

  /// Whether recipe-BOM math needs `conversionFactor` — `Por peso`/`Por
  /// paquete` (continuous, needs a stock-unit factor), NOT `Por
  /// unidad`/`Sí-No` (exact or untracked).
  static bool requiresConversionFactor(FormGroup form) {
    final mode = form.control('modeChoice').value as IngredientModeChoice;
    return mode == IngredientModeChoice.mass ||
        mode == IngredientModeChoice.package;
  }

  /// Whether the form should show/persist `conversionFactor` at all —
  /// [requiresConversionFactor]'s modes plus `Por unidad`, where it's
  /// OPTIONAL (lets a count ingredient accept a volume/mass recipe unit,
  /// e.g. Zanahoria bought whole but used by `taza` in recipes).
  static bool allowsConversionFactor(FormGroup form) {
    final mode = form.control('modeChoice').value as IngredientModeChoice;
    return requiresConversionFactor(form) || mode == IngredientModeChoice.count;
  }

  /// A throwaway [Ingredient] carrying just enough (`measurementMode`,
  /// `package`, `defaultLensLabel`) for [StockLensService] to compute
  /// lenses off the CURRENT form state — never persisted itself.
  static Ingredient draftIngredient(FormGroup form) => Ingredient(
    id: '',
    name: '',
    category: form.control('category').value as Category,
    measurementMode: measurementMode(form),
    package: packageSpec(form),
    defaultLensLabel: form.control('lensOverrideLabel').value as String?,
  );

  static List<StockLens> lenses(FormGroup form) =>
      measurementMode(form) == MeasurementMode.boolean
      ? const []
      : _stockLensService.lensesFor(draftIngredient(form));

  /// The active lens for BOTH the default-lens selector and the
  /// initial-stock entry field — `null` only for `Sí-No` mode (no numeric
  /// stock at all).
  static StockLens? selectedLens(FormGroup form) {
    final available = lenses(form);
    if (available.isEmpty) return null;
    return _stockLensService.defaultLensFor(draftIngredient(form));
  }

  /// The typed stock, in [selectedLens]'s unit, or `null` when empty/
  /// invalid.
  static num? parsedStockValue(FormGroup form) {
    final text = (form.control('stock').value as String? ?? '').trim();
    if (text.isEmpty) return null;
    return num.tryParse(text);
  }

  /// [parsedStockValue] converted to the ingredient's canonical stock unit
  /// via [selectedLens], or `null` when there's nothing valid yet.
  static num? canonicalStockValue(FormGroup form) {
    final lens = selectedLens(form);
    final parsed = parsedStockValue(form);
    if (lens == null || parsed == null) return null;
    return lens.toCanonical(parsed);
  }

  static bool canConfirm(FormGroup form) {
    final name = (form.control('name').value as String? ?? '').trim();
    if (name.isEmpty) return false;

    if (requiresConversionFactor(form)) {
      final factor = num.tryParse(
        (form.control('conversionFactor').value as String? ?? '').trim(),
      );
      if (factor == null) return false;
    }

    final mode = form.control('modeChoice').value as IngredientModeChoice;
    if (mode == IngredientModeChoice.boolean) {
      return true;
    }

    if (allowsPackage(form) && !_packageFieldsValid(form)) return false;

    final canonical = canonicalStockValue(form);
    return canonical != null && canonical >= 0;
  }

  /// Builds the [Ingredient] for [id] from the form's current values.
  Ingredient toEntity(String id) {
    final form = state;
    final name = (form.control('name').value as String? ?? '').trim();
    final emoji = (form.control('emoji').value as String? ?? '').trim();
    return Ingredient(
      id: id,
      name: name,
      emoji: emoji.isEmpty ? null : emoji,
      category: form.control('category').value as Category,
      conversionFactor: allowsConversionFactor(form)
          ? num.tryParse(
              (form.control('conversionFactor').value as String? ?? '').trim(),
            )
          : null,
      measurementMode: measurementMode(form),
      package: packageSpec(form),
      defaultLensLabel: form.control('lensOverrideLabel').value as String?,
      needType: form.control('needType').value as NeedType,
    );
  }

  /// Builds the matching [PantryItem] for [id] from the form's current
  /// values — same shared id as [toEntity].
  PantryItem toPantryItem(String id) {
    final form = state;
    final category = form.control('category').value as Category;
    final mode = form.control('modeChoice').value as IngredientModeChoice;

    return mode == IngredientModeChoice.boolean
        ? PantryItem.booleanTracked(
            ingredientId: id,
            category: category,
            haveIt: form.control('haveIt').value as bool? ?? false,
          )
        : PantryItem.quantityTracked(
            ingredientId: id,
            category: category,
            stock: Quantity(
              value: canonicalStockValue(form)!,
              unit: _stockLensService.canonicalUnitFor(draftIngredient(form)),
            ),
          );
  }
}
