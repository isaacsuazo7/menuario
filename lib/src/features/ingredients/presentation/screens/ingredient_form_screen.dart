import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredient_edit_provider.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredient_pantry_edit_provider.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredients_list_provider.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/features/recipes/presentation/providers/ingredients_by_id_provider.dart';
import 'package:menuario/src/shared/shared.dart';

/// The pantry section's presentation choice. Mirrors [Presentation]'s 3
/// variants as a plain enum so the selector can hold a choice before
/// `package`'s extra `yieldQty`/`label` fields are filled in.
enum _PresentationKind { loose, package, counter }

/// Pure and dependency-free (see [StockPresentationService]'s "no DI
/// needed" design decision) — safe to hold as a single const instance.
const _stockPresentation = StockPresentationService();

/// Full-screen create/edit form for the ingredient catalog.
///
/// PR3a added the 6 ingredient-side fields (name, emoji, category,
/// measurementKind, booleanTracked, conversionFactor). PR3b (this) adds the
/// pantry-adaptive section — presentation + initial stock (with inline
/// `yieldQty`/`label` for `package`) when `booleanTracked == false`, or a
/// have/don't-have flag when `booleanTracked == true` — and wires Confirm
/// to the atomic `IngredientCatalogRepository.saveWithPantry`.
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
  final _yieldQtyController = TextEditingController();
  final _labelController = TextEditingController();

  Category _category = Category.otro;
  MeasurementKind _measurementKind = MeasurementKind.unit;
  bool _booleanTracked = false;
  bool _haveIt = false;
  _PresentationKind _presentationKind = _PresentationKind.loose;

  bool _prefilled = false;
  bool _pantryPrefilled = false;

  bool get _isEdit => widget.ingredientId != null;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_handleFieldChanged);
    _conversionFactorController.addListener(_handleFieldChanged);
    _stockController.addListener(_handleFieldChanged);
    _yieldQtyController.addListener(_handleFieldChanged);
    _labelController.addListener(_handleFieldChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    _conversionFactorController.dispose();
    _stockController.dispose();
    _yieldQtyController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _handleFieldChanged() => setState(() {});

  /// Copies [ingredient]'s 6 fields into local state, once. Controller
  /// listeners are detached first so the text assignment doesn't trigger a
  /// `setState` while this runs inside the `build` call.
  void _prefill(Ingredient ingredient) {
    _prefilled = true;
    _nameController.removeListener(_handleFieldChanged);
    _conversionFactorController.removeListener(_handleFieldChanged);

    _nameController.text = ingredient.name;
    _emojiController.text = ingredient.emoji ?? '';
    _category = ingredient.category;
    _measurementKind = ingredient.measurementKind;
    _booleanTracked = ingredient.booleanTracked;
    if (ingredient.conversionFactor != null) {
      _conversionFactorController.text = ingredient.conversionFactor
          .toString();
    }

    _nameController.addListener(_handleFieldChanged);
    _conversionFactorController.addListener(_handleFieldChanged);
  }

  /// Copies [pantryItem]'s presentation/stock (or have-flag) into local
  /// state, once. Same detach-listener-before-mutate guard as [_prefill].
  void _prefillPantry(PantryItem pantryItem) {
    _pantryPrefilled = true;
    _stockController.removeListener(_handleFieldChanged);
    _yieldQtyController.removeListener(_handleFieldChanged);
    _labelController.removeListener(_handleFieldChanged);

    switch (pantryItem) {
      case QuantityTrackedPantryItem(:final presentation, :final stock):
        _presentationKind = _kindOf(presentation);
        if (presentation case PresentationPackage(
          :final yieldQty,
          :final label,
        )) {
          _yieldQtyController.text = _formatNumber(yieldQty);
          _labelController.text = label;
        }
        final naturalValue = _stockPresentation.toNaturalValue(
          stockValue: stock.value,
          presentation: presentation,
        );
        _stockController.text = _formatNumber(naturalValue);
      case BooleanTrackedPantryItem(:final haveIt):
        _haveIt = haveIt;
    }

    _stockController.addListener(_handleFieldChanged);
    _yieldQtyController.addListener(_handleFieldChanged);
    _labelController.addListener(_handleFieldChanged);
  }

  _PresentationKind _kindOf(Presentation presentation) =>
      switch (presentation) {
        PresentationLoose() => _PresentationKind.loose,
        PresentationPackage() => _PresentationKind.package,
        PresentationCounter() => _PresentationKind.counter,
      };

  /// Trims trailing fractional zeros (and a bare trailing `.`), mirroring
  /// `_SetStockSheetState._formatNatural`.
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

  /// The stock's own [Unit]: grams for a bulk (mass) ingredient, whole
  /// units for a unit (count) ingredient. No liter-based ingredient is
  /// reachable from this form in v1 (see design's open question).
  Unit get _stockUnit =>
      _measurementKind == MeasurementKind.bulk ? Unit.gram : Unit.count;

  /// Builds the [Presentation] value object from the current selector +
  /// (when `package`) the inline `yieldQty`/`label` fields.
  Presentation _buildPresentation() {
    return switch (_presentationKind) {
      _PresentationKind.loose => const Presentation.loose(),
      _PresentationKind.counter => const Presentation.counter(),
      _PresentationKind.package => Presentation.package(
        yieldQty: num.tryParse(_yieldQtyController.text.trim()) ?? 0,
        label: _labelController.text.trim(),
      ),
    };
  }

  /// The typed stock, converted to the stock's own unit for live preview,
  /// or `null` when there's nothing valid to preview yet.
  num? get _previewStockValue {
    final parsed = num.tryParse(_stockController.text.trim());
    if (parsed == null) return null;
    if (_presentationKind == _PresentationKind.package &&
        num.tryParse(_yieldQtyController.text.trim()) == null) {
      return null;
    }
    return _stockPresentation.toStockValue(
      naturalValue: parsed,
      presentation: _buildPresentation(),
      stockUnit: _stockUnit,
    );
  }

  bool get _canConfirm {
    if (_nameController.text.trim().isEmpty) return false;
    if (_measurementKind == MeasurementKind.bulk) {
      final factor = num.tryParse(_conversionFactorController.text.trim());
      if (factor == null) return false;
    }
    if (!_booleanTracked) {
      final stock = num.tryParse(_stockController.text.trim());
      if (stock == null || stock < 0) return false;
      if (_presentationKind == _PresentationKind.package) {
        final yieldQty = num.tryParse(_yieldQtyController.text.trim());
        if (yieldQty == null || yieldQty <= 0) return false;
        if (_labelController.text.trim().isEmpty) return false;
      }
    }
    return true;
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
      measurementKind: _measurementKind,
      booleanTracked: _booleanTracked,
      conversionFactor: _measurementKind == MeasurementKind.bulk
          ? num.tryParse(_conversionFactorController.text.trim())
          : null,
    );

    final pantryItem = _booleanTracked
        ? PantryItem.booleanTracked(
            ingredientId: id,
            category: _category,
            presentation: const Presentation.loose(),
            haveIt: _haveIt,
          )
        : PantryItem.quantityTracked(
            ingredientId: id,
            category: _category,
            presentation: _buildPresentation(),
            stock: Quantity(
              value: num.parse(_stockController.text.trim()),
              unit: _stockUnit,
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
          SegmentedButton<MeasurementKind>(
            key: const Key('ingredient-measurement-kind-field'),
            segments: const [
              ButtonSegment(
                value: MeasurementKind.unit,
                label: Text('Unidad'),
              ),
              ButtonSegment(
                value: MeasurementKind.bulk,
                label: Text('Granel'),
              ),
            ],
            selected: {_measurementKind},
            onSelectionChanged: (selection) =>
                setState(() => _measurementKind = selection.first),
          ),
          if (_measurementKind == MeasurementKind.bulk) ...[
            MenuarioSpacing.gapV16,
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
          MenuarioSpacing.gapV16,
          SwitchListTile(
            key: const Key('ingredient-boolean-tracked-field'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Seguimiento booleano (tengo / no tengo)'),
            value: _booleanTracked,
            onChanged: (value) => setState(() => _booleanTracked = value),
          ),
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

  /// The adaptive pantry section: a have/don't-have flag when
  /// `booleanTracked`, or a presentation + stock entry otherwise. See
  /// design's "Adaptive form fields".
  Widget _buildPantrySection() {
    return _booleanTracked
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
    final preview = _previewStockValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<_PresentationKind>(
          key: const Key('ingredient-presentation-field'),
          segments: const [
            ButtonSegment(
              value: _PresentationKind.loose,
              label: Text('Suelto'),
            ),
            ButtonSegment(
              value: _PresentationKind.package,
              label: Text('Paquete'),
            ),
            ButtonSegment(
              value: _PresentationKind.counter,
              label: Text('Mostrador'),
            ),
          ],
          selected: {_presentationKind},
          onSelectionChanged: (selection) =>
              setState(() => _presentationKind = selection.first),
        ),
        if (_presentationKind == _PresentationKind.package) ...[
          MenuarioSpacing.gapV16,
          TextField(
            key: const Key('ingredient-yield-qty-field'),
            controller: _yieldQtyController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(labelText: 'Rinde (cantidad)'),
          ),
          MenuarioSpacing.gapV16,
          TextField(
            key: const Key('ingredient-label-field'),
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'Etiqueta (ej. bolsa)',
            ),
          ),
        ],
        MenuarioSpacing.gapV16,
        TextField(
          key: const Key('ingredient-stock-field'),
          controller: _stockController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Existencia inicial'),
        ),
        MenuarioSpacing.gapV8,
        Text(
          preview == null
              ? 'Ingresa una existencia válida'
              : '≈ ${preview.round()} ${_stockUnit.symbol}',
          style: MenuarioTypography.body,
        ),
      ],
    );
  }
}
