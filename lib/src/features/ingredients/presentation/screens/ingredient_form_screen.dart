import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredient_edit_provider.dart';
import 'package:menuario/src/shared/shared.dart';

/// Full-screen create/edit form for the ingredient catalog.
///
/// PR3a scope only: the 6 ingredient-side fields (name, emoji, category,
/// measurementKind, booleanTracked, conversionFactor) and their
/// validation. The pantry-adaptive section (presentation/stock/have-flag)
/// and the atomic `saveWithPantry` wiring are added in PR3b — Confirm is a
/// validation-gated stub until then.
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

  Category _category = Category.otro;
  MeasurementKind _measurementKind = MeasurementKind.unit;
  bool _booleanTracked = false;

  bool _prefilled = false;

  bool get _isEdit => widget.ingredientId != null;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_handleFieldChanged);
    _conversionFactorController.addListener(_handleFieldChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    _conversionFactorController.dispose();
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

  bool get _canConfirm {
    if (_nameController.text.trim().isEmpty) return false;
    if (_measurementKind == MeasurementKind.bulk) {
      final factor = num.tryParse(_conversionFactorController.text.trim());
      if (factor == null) return false;
    }
    return true;
  }

  // TODO(PR3b): collect pantry section + atomic saveWithPantry.
  void _handleConfirmStub() {}

  @override
  Widget build(BuildContext context) {
    final editValue = widget.ingredientId == null
        ? const AsyncValue<Ingredient?>.data(null)
        : ref.watch(ingredientEditProvider(widget.ingredientId));

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
          return _buildForm(context);
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
                onPressed: _canConfirm ? _handleConfirmStub : null,
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
