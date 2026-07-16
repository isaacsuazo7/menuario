import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredient_edit_provider.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredient_pantry_edit_provider.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredients_list_provider.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/features/recipes/presentation/providers/ingredients_by_id_provider.dart';
import 'package:menuario/src/shared/shared.dart';

/// The "¿Cómo lo medís?" top-level choice. `package` covers BOTH
/// [MeasurementMode.packageBase] and [MeasurementMode.packageAbstract] —
/// which one applies is resolved from whether the package fields carry a
/// complete yield + base-unit pair (see [_IngredientFormScreenState._package]).
enum _ModeChoice { mass, count, package, boolean }

/// The base-unit dropdown's fixed option set for a `Por paquete` package
/// with a known yield (packageBase); `null` means "sin base"
/// (packageAbstract).
const List<Unit?> _baseUnitOptions = [null, Unit.gram, Unit.liter, Unit.count];

String _baseUnitLabel(Unit? unit) => switch (unit) {
  null => 'Sin base (abstracto)',
  Unit.gram => 'Gramos (g)',
  Unit.liter => 'Litros (L)',
  Unit.count => 'Unidades (u)',
  _ => unit.symbol,
};

/// Pure and dependency-free (see [StockLensService]'s "no DI needed"
/// design decision) — safe to hold as a single const instance.
const _stockLensService = StockLensService();

/// Full-screen create/edit form for the ingredient catalog.
///
/// Replaces the old `measurementKind` SegmentedButton + `_PresentationKind`
/// SegmentedButton + `booleanTracked` switch with a single "¿Cómo lo
/// medís?" selector driving [MeasurementMode], with per-mode conditional
/// fields (package name/yield/base-unit for `Por paquete`, a
/// [StockLens]-driven default-lens selector doubling as the initial-stock
/// entry lens, and `Factor de conversión` relocated behind a collapsed
/// "Avanzado" section). Confirm still wires atomically to
/// [IngredientCatalogRepository.saveWithPantry].
class IngredientFormScreen extends ConsumerStatefulWidget {
  const IngredientFormScreen({super.key, this.ingredientId});

  /// The [Ingredient.id] being edited, or `null` when creating.
  final String? ingredientId;

  @override
  ConsumerState<IngredientFormScreen> createState() =>
      _IngredientFormScreenState();
}

class _IngredientFormScreenState extends ConsumerState<IngredientFormScreen> {
  final _nameController = TextEditingController();
  final _emojiController = TextEditingController();
  final _conversionFactorController = TextEditingController();
  final _stockController = TextEditingController();
  final _packageLabelController = TextEditingController();
  final _packageYieldController = TextEditingController();

  Category _category = Category.otro;
  _ModeChoice _modeChoice = _ModeChoice.mass;
  Unit? _packageBaseUnit;
  bool _haveIt = false;

  /// The current entry/default lens, as a label. `null` means "use the
  /// mode's heuristic default" ([StockLensService.defaultLensFor]);
  /// non-null is a user override, persisted as [Ingredient.defaultLensLabel]
  /// — switching the selector sets this AND re-scales [_stockController]
  /// to the same canonical quantity, mirroring `_SetStockSheetState`.
  String? _lensOverrideLabel;

  bool _prefilled = false;
  bool _pantryPrefilled = false;

  bool get _isEdit => widget.ingredientId != null;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_handleFieldChanged);
    _conversionFactorController.addListener(_handleFieldChanged);
    _stockController.addListener(_handleFieldChanged);
    _packageLabelController.addListener(_handleFieldChanged);
    _packageYieldController.addListener(_handleFieldChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    _conversionFactorController.dispose();
    _stockController.dispose();
    _packageLabelController.dispose();
    _packageYieldController.dispose();
    super.dispose();
  }

  void _handleFieldChanged() => setState(() {});

  /// Copies [ingredient]'s fields into local state, once. Controller
  /// listeners are detached first so the text assignment doesn't trigger a
  /// `setState` while this runs inside the `build` call.
  void _prefill(Ingredient ingredient) {
    _prefilled = true;
    _nameController.removeListener(_handleFieldChanged);
    _conversionFactorController.removeListener(_handleFieldChanged);
    _packageLabelController.removeListener(_handleFieldChanged);
    _packageYieldController.removeListener(_handleFieldChanged);

    _nameController.text = ingredient.name;
    _emojiController.text = ingredient.emoji ?? '';
    _category = ingredient.category;
    _modeChoice = _modeChoiceFor(ingredient.measurementMode);
    _lensOverrideLabel = ingredient.defaultLensLabel;
    if (ingredient.conversionFactor != null) {
      _conversionFactorController.text = ingredient.conversionFactor.toString();
    }
    final package = ingredient.package;
    if (package != null) {
      _packageLabelController.text = package.label;
      if (package.yieldQty != null) {
        _packageYieldController.text = _formatNumber(package.yieldQty!);
      }
      _packageBaseUnit = package.baseDimension;
    }

    _nameController.addListener(_handleFieldChanged);
    _conversionFactorController.addListener(_handleFieldChanged);
    _packageLabelController.addListener(_handleFieldChanged);
    _packageYieldController.addListener(_handleFieldChanged);
  }

  _ModeChoice _modeChoiceFor(MeasurementMode mode) => switch (mode) {
    MeasurementMode.mass => _ModeChoice.mass,
    MeasurementMode.count => _ModeChoice.count,
    MeasurementMode.packageBase => _ModeChoice.package,
    MeasurementMode.packageAbstract => _ModeChoice.package,
    MeasurementMode.boolean => _ModeChoice.boolean,
  };

  /// Copies [pantryItem]'s stock (or have-flag) into local state, once. Same
  /// detach-listener-before-mutate guard as [_prefill]. Runs AFTER
  /// [_prefill], so [_selectedLens] already reflects the prefilled mode,
  /// package and lens override.
  void _prefillPantry(PantryItem pantryItem) {
    _pantryPrefilled = true;
    _stockController.removeListener(_handleFieldChanged);

    switch (pantryItem) {
      case QuantityTrackedPantryItem(:final stock):
        final lens = _selectedLens;
        if (lens != null) {
          final naturalValue = lens.fromCanonical(stock.value);
          _stockController.text = _formatNatural(naturalValue, lens);
        }
      case BooleanTrackedPantryItem(:final haveIt):
        _haveIt = haveIt;
    }

    _stockController.addListener(_handleFieldChanged);
  }

  /// Trims trailing fractional zeros (and a bare trailing `.`), mirroring
  /// `_SetStockSheetState._formatNatural`. Integer-only lenses round first,
  /// since their field never carries a decimal point.
  String _formatNatural(num value, StockLens lens) {
    if (!lens.allowsDecimal) return value.round().toString();
    return _formatNumber(value);
  }

  String _formatNumber(num value) {
    var fixed = value.toStringAsFixed(2);
    while (fixed.contains('.') && fixed.endsWith('0')) {
      fixed = fixed.substring(0, fixed.length - 1);
    }
    if (fixed.endsWith('.')) {
      fixed = fixed.substring(0, fixed.length - 1);
    }
    return fixed;
  }

  /// The [PackageSpec] built from the current package fields, or `null`
  /// when not in `Por paquete` mode or the name is still empty.
  /// [PackageSpec.yieldQty]/[PackageSpec.baseDimension] are populated ONLY
  /// when BOTH the yield and base-unit fields are filled — otherwise the
  /// package is treated as abstract (no known base yield), matching the
  /// "yield + base unit given -> packageBase; left empty -> packageAbstract"
  /// rule.
  PackageSpec? get _package {
    if (_modeChoice != _ModeChoice.package) return null;
    final label = _packageLabelController.text.trim();
    if (label.isEmpty) return null;

    final yieldQty = num.tryParse(_packageYieldController.text.trim());
    final hasBase =
        yieldQty != null && yieldQty > 0 && _packageBaseUnit != null;
    return PackageSpec(
      label: label,
      yieldQty: hasBase ? yieldQty : null,
      baseDimension: hasBase ? _packageBaseUnit : null,
    );
  }

  MeasurementMode get _measurementMode => switch (_modeChoice) {
    _ModeChoice.mass => MeasurementMode.mass,
    _ModeChoice.count => MeasurementMode.count,
    _ModeChoice.package =>
      _package?.yieldQty != null && _package?.baseDimension != null
          ? MeasurementMode.packageBase
          : MeasurementMode.packageAbstract,
    _ModeChoice.boolean => MeasurementMode.boolean,
  };

  /// Whether recipe-BOM math needs [Ingredient.conversionFactor] — mirrors
  /// the old `MeasurementKind.bulk` gate, now derived from the mode: `Por
  /// peso`/`Por paquete` (continuous, needs a stock-unit factor), NOT `Por
  /// unidad`/`Sí-No` (exact or untracked).
  bool get _requiresConversionFactor =>
      _modeChoice == _ModeChoice.mass || _modeChoice == _ModeChoice.package;

  /// The legacy [MeasurementKind] persisted alongside [measurementMode] for
  /// back-compat readers (`MeasurementConverter.toStockUnit`) — `unit` for
  /// exact/untracked modes, `bulk` for the continuous ones.
  MeasurementKind get _legacyMeasurementKind => switch (_modeChoice) {
    _ModeChoice.count || _ModeChoice.boolean => MeasurementKind.unit,
    _ModeChoice.mass || _ModeChoice.package => MeasurementKind.bulk,
  };

  /// A throwaway [Ingredient] carrying just enough (`measurementMode`,
  /// `package`, `defaultLensLabel`) for [StockLensService] to compute
  /// lenses off the CURRENT form state — never persisted itself.
  Ingredient get _draftIngredient => Ingredient(
    id: '',
    name: '',
    category: _category,
    measurementKind: _legacyMeasurementKind,
    booleanTracked: _measurementMode == MeasurementMode.boolean,
    measurementMode: _measurementMode,
    package: _package,
    defaultLensLabel: _lensOverrideLabel,
  );

  List<StockLens> get _lenses => _measurementMode == MeasurementMode.boolean
      ? const []
      : _stockLensService.lensesFor(_draftIngredient);

  /// The active lens for BOTH the default-lens selector and the
  /// initial-stock entry field — `null` only for `Sí-No` mode (no numeric
  /// stock at all).
  StockLens? get _selectedLens {
    if (_lenses.isEmpty) return null;
    return _stockLensService.defaultLensFor(_draftIngredient);
  }

  /// The typed stock, in [_selectedLens]'s unit, or `null` when empty/
  /// invalid.
  num? get _parsedStockValue {
    final text = _stockController.text.trim();
    if (text.isEmpty) return null;
    return num.tryParse(text);
  }

  /// [_parsedStockValue] converted to the ingredient's canonical stock
  /// unit via [_selectedLens], or `null` when there's nothing valid yet.
  num? get _canonicalStockValue {
    final lens = _selectedLens;
    final parsed = _parsedStockValue;
    if (lens == null || parsed == null) return null;
    return lens.toCanonical(parsed);
  }

  /// Switches the active lens, re-scaling [_stockController] to the same
  /// canonical value expressed in the new lens's unit, and persists the
  /// choice as [_lensOverrideLabel] (-> [Ingredient.defaultLensLabel]).
  /// Mirrors `_SetStockSheetState._handleLensChanged`.
  void _handleLensChanged(StockLens newLens) {
    final oldLens = _selectedLens;
    final parsed = _parsedStockValue;
    final canonical = (oldLens != null && parsed != null)
        ? oldLens.toCanonical(parsed)
        : null;

    setState(() => _lensOverrideLabel = newLens.label);

    if (canonical != null) {
      _stockController.text = _formatNatural(
        newLens.fromCanonical(canonical),
        newLens,
      );
    }
  }

  void _handleModeChanged(_ModeChoice mode) {
    setState(() {
      _modeChoice = mode;
      _lensOverrideLabel = null;
    });
  }

  bool get _canConfirm {
    if (_nameController.text.trim().isEmpty) return false;

    if (_requiresConversionFactor) {
      final factor = num.tryParse(_conversionFactorController.text.trim());
      if (factor == null) return false;
    }

    if (_modeChoice == _ModeChoice.boolean) {
      return true;
    }

    if (_modeChoice == _ModeChoice.package) {
      if (_packageLabelController.text.trim().isEmpty) return false;
      final yieldText = _packageYieldController.text.trim();
      final hasYieldText = yieldText.isNotEmpty;
      final hasBaseUnit = _packageBaseUnit != null;
      if (hasYieldText != hasBaseUnit) return false;
      if (hasYieldText) {
        final yieldQty = num.tryParse(yieldText);
        if (yieldQty == null || yieldQty <= 0) return false;
      }
    }

    final canonical = _canonicalStockValue;
    return canonical != null && canonical >= 0;
  }

  /// The legacy purchase [Presentation] mirrored from
  /// `shopping_list_builder.dart`'s `presentationForPurchase` adapter,
  /// duplicated locally (rather than imported cross-feature) since
  /// `PantryItem.presentation` is only a back-compat field here — it is
  /// no longer read by anything mode-aware.
  Presentation _legacyPresentation() {
    return switch (_measurementMode) {
      MeasurementMode.mass => const Presentation.counter(),
      MeasurementMode.count => const Presentation.loose(),
      MeasurementMode.packageBase => Presentation.package(
        yieldQty: _package?.yieldQty ?? 1,
        label: _package?.label ?? 'paquete',
      ),
      MeasurementMode.packageAbstract => Presentation.package(
        yieldQty: 1,
        label: _package?.label ?? 'paquete',
      ),
      MeasurementMode.boolean => const Presentation.loose(),
    };
  }

  /// Builds the [Ingredient] + matching [PantryItem] under one shared id
  /// (minted once on create, reused on edit) and commits both atomically
  /// via [IngredientCatalogRepository.saveWithPantry]. On success, pops
  /// the form and invalidates the read surfaces that must reflect it; on
  /// `Left(Failure)`, shows a `SnackBar` and stays on the form.
  Future<void> _handleConfirm() async {
    final catalogRepository = ref.read(ingredientCatalogRepositoryProvider);
    final id = widget.ingredientId ?? catalogRepository.newId();

    final ingredient = Ingredient(
      id: id,
      name: _nameController.text.trim(),
      emoji: _emojiController.text.trim().isEmpty
          ? null
          : _emojiController.text.trim(),
      category: _category,
      measurementKind: _legacyMeasurementKind,
      booleanTracked: _measurementMode == MeasurementMode.boolean,
      conversionFactor: _requiresConversionFactor
          ? num.tryParse(_conversionFactorController.text.trim())
          : null,
      measurementMode: _measurementMode,
      package: _package,
      defaultLensLabel: _lensOverrideLabel,
    );

    final pantryItem = _modeChoice == _ModeChoice.boolean
        ? PantryItem.booleanTracked(
            ingredientId: id,
            category: _category,
            presentation: _legacyPresentation(),
            haveIt: _haveIt,
          )
        : PantryItem.quantityTracked(
            ingredientId: id,
            category: _category,
            presentation: _legacyPresentation(),
            stock: Quantity(
              value: _canonicalStockValue!,
              unit: _stockLensService.canonicalUnitFor(_draftIngredient),
            ),
          );

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final result = await catalogRepository.saveWithPantry(
      ingredient: ingredient,
      pantryItem: pantryItem,
    );

    if (!mounted) return;

    result.fold(
      (failure) =>
          messenger.showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ref.invalidate(ingredientsListProvider);
        ref.invalidate(ingredientRepositoryProvider);
        ref.invalidate(ingredientsByIdProvider);
        ref.invalidate(pantryControllerProvider);
        navigator.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final editValue = widget.ingredientId == null
        ? const AsyncValue<Ingredient?>.data(null)
        : ref.watch(ingredientEditProvider(widget.ingredientId));
    final pantryEditValue = widget.ingredientId == null
        ? const AsyncValue<PantryItem?>.data(null)
        : ref.watch(ingredientPantryEditProvider(widget.ingredientId));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar ingrediente' : 'Nuevo ingrediente'),
      ),
      body: AppAsyncValueWidget<Ingredient?>(
        value: editValue,
        onRetry: () =>
            ref.invalidate(ingredientEditProvider(widget.ingredientId)),
        builder: (context, ingredient) {
          if (ingredient != null && !_prefilled) {
            _prefill(ingredient);
          }
          return AppAsyncValueWidget<PantryItem?>(
            value: pantryEditValue,
            onRetry: () => ref.invalidate(
              ingredientPantryEditProvider(widget.ingredientId),
            ),
            builder: (context, pantryItem) {
              if (pantryItem != null && !_pantryPrefilled) {
                _prefillPantry(pantryItem);
              }
              return _buildForm(context);
            },
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: MenuarioSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('ingredient-name-field'),
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          MenuarioSpacing.gapV16,
          TextField(
            key: const Key('ingredient-emoji-field'),
            controller: _emojiController,
            decoration: const InputDecoration(labelText: 'Emoji (opcional)'),
          ),
          MenuarioSpacing.gapV16,
          DropdownButtonFormField<Category>(
            key: const Key('ingredient-category-field'),
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Categoría'),
            items: [
              for (final category in Category.values)
                DropdownMenuItem(value: category, child: Text(category.label)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _category = value);
            },
          ),
          MenuarioSpacing.gapV16,
          Text('¿Cómo lo medís?', style: MenuarioTypography.body),
          MenuarioSpacing.gapV8,
          SegmentedButton<_ModeChoice>(
            key: const Key('ingredient-mode-field'),
            segments: const [
              ButtonSegment(value: _ModeChoice.mass, label: Text('Por peso')),
              ButtonSegment(
                value: _ModeChoice.count,
                label: Text('Por unidad'),
              ),
              ButtonSegment(
                value: _ModeChoice.package,
                label: Text('Por paquete'),
              ),
              ButtonSegment(value: _ModeChoice.boolean, label: Text('Sí-No')),
            ],
            selected: {_modeChoice},
            onSelectionChanged: (selection) =>
                _handleModeChanged(selection.first),
          ),
          if (_modeChoice == _ModeChoice.package) ...[
            MenuarioSpacing.gapV16,
            TextField(
              key: const Key('ingredient-package-label-field'),
              controller: _packageLabelController,
              decoration: const InputDecoration(
                labelText: 'Nombre del paquete (ej. bolsa, caja, pana)',
              ),
            ),
            MenuarioSpacing.gapV16,
            TextField(
              key: const Key('ingredient-package-yield-field'),
              controller: _packageYieldController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: '¿Cuánto trae?'),
            ),
            MenuarioSpacing.gapV16,
            DropdownButtonFormField<Unit?>(
              key: const Key('ingredient-package-base-unit-field'),
              initialValue: _packageBaseUnit,
              decoration: const InputDecoration(labelText: 'Unidad base'),
              items: [
                for (final unit in _baseUnitOptions)
                  DropdownMenuItem(
                    value: unit,
                    child: Text(_baseUnitLabel(unit)),
                  ),
              ],
              onChanged: (value) => setState(() => _packageBaseUnit = value),
            ),
          ],
          if (_requiresConversionFactor) ...[
            MenuarioSpacing.gapV16,
            ExpansionTile(
              key: const Key('ingredient-advanced-section'),
              title: const Text('Avanzado'),
              tilePadding: EdgeInsets.zero,
              children: [
                TextField(
                  key: const Key('ingredient-conversion-factor-field'),
                  controller: _conversionFactorController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Factor de conversión',
                  ),
                ),
              ],
            ),
          ],
          MenuarioSpacing.gapV16,
          _buildPantrySection(),
          MenuarioSpacing.gapV24,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              MenuarioSpacing.gapH8,
              FilledButton(
                onPressed: _canConfirm ? _handleConfirm : null,
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// The adaptive pantry section: a have/don't-have flag for `Sí-No`, or a
  /// default-lens selector + initial-stock entry otherwise. See design's
  /// "Adaptive form fields".
  Widget _buildPantrySection() {
    return _modeChoice == _ModeChoice.boolean
        ? _buildHaveFlagSection()
        : _buildQuantitySection();
  }

  Widget _buildHaveFlagSection() {
    return SegmentedButton<bool>(
      key: const Key('ingredient-have-it-field'),
      segments: const [
        ButtonSegment(value: true, label: Text('Tengo')),
        ButtonSegment(value: false, label: Text('No tengo')),
      ],
      selected: {_haveIt},
      onSelectionChanged: (selection) =>
          setState(() => _haveIt = selection.first),
    );
  }

  Widget _buildQuantitySection() {
    final lenses = _lenses;
    final selectedLens = _selectedLens;
    final canonical = _canonicalStockValue;
    final otherLenses = lenses.where((lens) => lens != selectedLens);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lenses.length > 1) ...[
          Text('Unidad por defecto', style: MenuarioTypography.body),
          MenuarioSpacing.gapV8,
          SegmentedButton<StockLens>(
            key: const Key('ingredient-default-lens-field'),
            segments: [
              for (final lens in lenses)
                ButtonSegment(value: lens, label: Text(lens.label)),
            ],
            selected: {selectedLens!},
            showSelectedIcon: false,
            onSelectionChanged: (selection) =>
                _handleLensChanged(selection.first),
          ),
          MenuarioSpacing.gapV16,
        ],
        TextField(
          key: const Key('ingredient-stock-field'),
          controller: _stockController,
          keyboardType: TextInputType.numberWithOptions(
            decimal: selectedLens?.allowsDecimal ?? true,
          ),
          inputFormatters: [
            if (selectedLens?.allowsDecimal ?? true)
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
            else
              FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            labelText: 'Existencia inicial',
            suffixText: selectedLens?.label,
          ),
        ),
        MenuarioSpacing.gapV8,
        if (canonical == null)
          Text('Ingresa una existencia válida', style: MenuarioTypography.body)
        else
          for (final lens in otherLenses)
            Text(
              '= ${_formatNatural(lens.fromCanonical(canonical), lens)} '
              '${lens.label}',
              style: MenuarioTypography.body,
            ),
      ],
    );
  }
}
