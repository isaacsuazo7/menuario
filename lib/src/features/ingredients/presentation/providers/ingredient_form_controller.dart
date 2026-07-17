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

  /// The [PackageSpec] built from [form]'s current package fields, or
  /// `null` when not in `Por paquete` mode or the name is still empty.
  /// [PackageSpec.yieldQty]/[PackageSpec.baseDimension] are populated ONLY
  /// when BOTH the yield and base-unit fields are filled.
  static PackageSpec? packageSpec(FormGroup form) {
    if (form.control('modeChoice').value != IngredientModeChoice.package) {
      return null;
    }
    final label = (form.control('packageLabel').value as String? ?? '')
        .trim();
    if (label.isEmpty) return null;

    final yieldQty = num.tryParse(
      (form.control('packageYield').value as String? ?? '').trim(),
    );
    final baseUnit = form.control('packageBaseUnit').value as Unit?;
    final hasBase = yieldQty != null && yieldQty > 0 && baseUnit != null;
    return PackageSpec(
      label: label,
      yieldQty: hasBase ? yieldQty : null,
      baseDimension: hasBase ? baseUnit : null,
    );
  }

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

  /// The legacy [MeasurementKind] persisted alongside `measurementMode` for
  /// back-compat readers (`MeasurementConverter.toStockUnit`).
  static MeasurementKind legacyMeasurementKind(FormGroup form) {
    final mode = form.control('modeChoice').value as IngredientModeChoice;
    return switch (mode) {
      IngredientModeChoice.count ||
      IngredientModeChoice.boolean => MeasurementKind.unit,
      IngredientModeChoice.mass ||
      IngredientModeChoice.package => MeasurementKind.bulk,
    };
  }

  /// A throwaway [Ingredient] carrying just enough (`measurementMode`,
  /// `package`, `defaultLensLabel`) for [StockLensService] to compute
  /// lenses off the CURRENT form state — never persisted itself.
  static Ingredient draftIngredient(FormGroup form) => Ingredient(
    id: '',
    name: '',
    category: form.control('category').value as Category,
    measurementKind: legacyMeasurementKind(form),
    booleanTracked: measurementMode(form) == MeasurementMode.boolean,
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

    if (mode == IngredientModeChoice.package) {
      final label = (form.control('packageLabel').value as String? ?? '')
          .trim();
      if (label.isEmpty) return false;
      final yieldText = (form.control('packageYield').value as String? ?? '')
          .trim();
      final hasYieldText = yieldText.isNotEmpty;
      final hasBaseUnit = form.control('packageBaseUnit').value != null;
      if (hasYieldText != hasBaseUnit) return false;
      if (hasYieldText) {
        final yieldQty = num.tryParse(yieldText);
        if (yieldQty == null || yieldQty <= 0) return false;
      }
    }

    final canonical = canonicalStockValue(form);
    return canonical != null && canonical >= 0;
  }

  /// The legacy purchase [Presentation] mirrored from
  /// `shopping_list_builder.dart`'s `presentationForPurchase` adapter — a
  /// back-compat field no longer read by anything mode-aware.
  static Presentation legacyPresentation(FormGroup form) {
    final package = packageSpec(form);
    return switch (measurementMode(form)) {
      MeasurementMode.mass => const Presentation.counter(),
      MeasurementMode.count => const Presentation.loose(),
      MeasurementMode.packageBase => Presentation.package(
        yieldQty: package?.yieldQty ?? 1,
        label: package?.label ?? 'paquete',
      ),
      MeasurementMode.packageAbstract => Presentation.package(
        yieldQty: 1,
        label: package?.label ?? 'paquete',
      ),
      MeasurementMode.boolean => const Presentation.loose(),
    };
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
      measurementKind: legacyMeasurementKind(form),
      booleanTracked: measurementMode(form) == MeasurementMode.boolean,
      conversionFactor: requiresConversionFactor(form)
          ? num.tryParse(
              (form.control('conversionFactor').value as String? ?? '')
                  .trim(),
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
    final presentation = legacyPresentation(form);

    return mode == IngredientModeChoice.boolean
        ? PantryItem.booleanTracked(
            ingredientId: id,
            category: category,
            presentation: presentation,
            haveIt: form.control('haveIt').value as bool? ?? false,
          )
        : PantryItem.quantityTracked(
            ingredientId: id,
            category: category,
            presentation: presentation,
            stock: Quantity(
              value: canonicalStockValue(form)!,
              unit: _stockLensService.canonicalUnitFor(draftIngredient(form)),
            ),
          );
  }
}
