import 'package:flutter/material.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/shared/shared.dart';

/// The fixed BOM unit vocabulary a recipe line may use — NOT free text.
///
/// An off-canon symbol would silently break `MeasurementConverter`/budget
/// math, so recipe BOM lines are restricted to this curated set: `taza`
/// and `cda` are recipe-only volume units with no canonical [Unit]
/// constant; `g`/`u`/`L` reuse the app's existing canonical stock units.
const recipeUnitOptions = <Unit>[
  Unit(symbol: 'taza', dimension: UnitDimension.volume),
  Unit.gram,
  Unit.count,
  Unit(symbol: 'cda', dimension: UnitDimension.volume),
  Unit.liter,
];

String _unitLabel(Unit unit) => switch (unit.symbol) {
  'taza' => 'Taza',
  'g' => 'Gramos (g)',
  'u' => 'Unidades (u)',
  'cda' => 'Cucharada (cda)',
  'L' => 'Litros (L)',
  _ => unit.symbol,
};

/// Trims trailing fractional zeros (and a bare trailing `.`), mirroring
/// `_SetStockSheetState._formatNatural`.
String _formatQuantity(num value) {
  var fixed = value.toStringAsFixed(2);
  while (fixed.contains('.') && fixed.endsWith('0')) {
    fixed = fixed.substring(0, fixed.length - 1);
  }
  if (fixed.endsWith('.')) {
    fixed = fixed.substring(0, fixed.length - 1);
  }
  return fixed;
}

/// A single BOM row's editable draft state: the picked ingredient id (or
/// `null` until chosen via the ingredient picker sheet), the quantity
/// [TextEditingController], and the curated [Unit].
///
/// Public (despite the leading-underscore filename convention marking this
/// file as a private implementation detail) so `recipe_form_screen.dart`,
/// which owns the `List<BomDraft>` state, can reference the type.
class BomDraft {
  BomDraft({this.ingredientId, num? quantity, Unit? unit})
    : unit = unit ?? recipeUnitOptions.first,
      quantityController = TextEditingController(
        text: quantity == null ? '' : _formatQuantity(quantity),
      );

  /// The selected [Ingredient.id], or `null` until picked.
  String? ingredientId;

  /// The curated [Unit] this line's quantity is expressed in.
  Unit unit;

  /// The typed quantity value, in [unit].
  final TextEditingController quantityController;

  void dispose() => quantityController.dispose();
}

/// The recipe form's "Ingredientes" (BOM) section: renders [lines], each as
/// an ingredient-select button + quantity field + curated unit dropdown +
/// remove button, plus an "Agregar ingrediente" action that appends a new
/// empty line (mirrors `recipe_form_screen.dart`'s video-row idiom — the
/// row is added first, then filled in place).
class BomEditorSection extends StatelessWidget {
  const BomEditorSection({
    super.key,
    required this.lines,
    required this.ingredientsById,
    required this.onAddLine,
    required this.onRemoveLine,
    required this.onPickIngredient,
    required this.onUnitChanged,
  });

  final List<BomDraft> lines;
  final Map<String, Ingredient> ingredientsById;
  final VoidCallback onAddLine;
  final void Function(int index) onRemoveLine;
  final void Function(int index) onPickIngredient;
  final void Function(int index, Unit unit) onUnitChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ingredientes', style: MenuarioTypography.h5),
        MenuarioSpacing.gapV8,
        for (var i = 0; i < lines.length; i++)
          _BomLineRow(
            index: i,
            draft: lines[i],
            ingredient: lines[i].ingredientId == null
                ? null
                : ingredientsById[lines[i].ingredientId],
            onRemove: () => onRemoveLine(i),
            onPickIngredient: () => onPickIngredient(i),
            onUnitChanged: (unit) => onUnitChanged(i, unit),
          ),
        TextButton.icon(
          onPressed: onAddLine,
          icon: const Icon(Icons.add),
          label: const Text('Agregar ingrediente'),
        ),
      ],
    );
  }
}

class _BomLineRow extends StatelessWidget {
  const _BomLineRow({
    required this.index,
    required this.draft,
    required this.ingredient,
    required this.onRemove,
    required this.onPickIngredient,
    required this.onUnitChanged,
  });

  final int index;
  final BomDraft draft;
  final Ingredient? ingredient;
  final VoidCallback onRemove;
  final VoidCallback onPickIngredient;
  final ValueChanged<Unit> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    final ingredient = this.ingredient;
    return Padding(
      padding: const EdgeInsets.only(bottom: MenuarioSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: OutlinedButton(
              key: Key('recipe-bom-ingredient-field-$index'),
              onPressed: onPickIngredient,
              child: Text(
                ingredient == null
                    ? 'Seleccionar ingrediente'
                    : '${ingredient.emoji ?? '🥄'} ${ingredient.name}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          MenuarioSpacing.gapH8,
          Expanded(
            flex: 2,
            child: TextField(
              key: Key('recipe-bom-quantity-field-$index'),
              controller: draft.quantityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Cantidad'),
            ),
          ),
          MenuarioSpacing.gapH8,
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<Unit>(
              key: Key('recipe-bom-unit-field-$index'),
              initialValue: draft.unit,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Unidad'),
              items: [
                for (final unit in recipeUnitOptions)
                  DropdownMenuItem(value: unit, child: Text(_unitLabel(unit))),
              ],
              onChanged: (value) {
                if (value != null) onUnitChanged(value);
              },
            ),
          ),
          IconButton(
            key: Key('recipe-bom-remove-$index'),
            icon: const Icon(Icons.delete_outline),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
