import 'package:flutter/material.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/shared/domain/services/recipe_unit_options.dart';
import 'package:menuario/src/shared/shared.dart';

String _unitLabel(Unit unit) => switch (unit.symbol) {
  'taza' => 'Taza',
  'g' => 'Gramos (g)',
  'kg' => 'Kilogramos (kg)',
  'u' => 'Unidades (u)',
  'cda' => 'Cucharada (cda)',
  'L' => 'Litros (L)',
  'ml' => 'Mililitros (ml)',
  'paq' => 'Paquetes (paq)',
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
/// [TextEditingController], and the [Unit] — restricted to the picked
/// ingredient's derived set (`recipeUnitsFor`), NOT a free global dropdown.
///
/// Public (despite the leading-underscore filename convention marking this
/// file as a private implementation detail) so `recipe_form_screen.dart`,
/// which owns the `List<BomDraft>` state, can reference the type.
class BomDraft {
  BomDraft({
    this.ingredientId,
    num? quantity,
    Unit? unit,
    this.quantityLess = false,
  }) : unit = unit ?? Unit.count,
       quantityController = TextEditingController(
         text: quantity == null ? '' : _formatQuantity(quantity),
       );

  /// The selected [Ingredient.id], or `null` until picked.
  String? ingredientId;

  /// Whether this line is "al gusto": the picked ingredient is
  /// boolean-tracked, so it carries no quantity and no unit.
  ///
  /// Held on the draft rather than re-derived from the ingredient because
  /// `_BomLinesValidator` sees only the draft list, never the ingredient
  /// catalog. Kept in sync by the form screen's ingredient-pick handler and
  /// by `RecipeFormController.prefill`.
  bool quantityLess;

  /// This line's quantity unit — one of `recipeUnitsFor(ingredient)` for
  /// the picked ingredient. [Unit.count] is only a placeholder default
  /// before any ingredient is picked (the row's unit dropdown stays
  /// disabled until then; `_BomLineRow` resets this to the picked
  /// ingredient's set-default the moment one is chosen).
  Unit unit;

  /// The typed quantity value, in [unit].
  final TextEditingController quantityController;

  void dispose() => quantityController.dispose();
}

/// The recipe form's "Ingredientes" (BOM) section: renders [lines], each as
/// a two-line ingredient-select button + quantity field + per-ingredient
/// unit dropdown + remove button, plus an "Agregar ingrediente" action that
/// appends a new empty line (mirrors `recipe_form_screen.dart`'s video-row
/// idiom — the row is added first, then filled in place).
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

/// A single BOM row: ingredient-select button, quantity field and a unit
/// dropdown restricted to `recipeUnitsFor(ingredient)` — disabled (no
/// items, `onChanged: null`) until an ingredient is picked.
///
/// When [BomDraft.quantityLess] is set (a boolean-tracked ingredient), the
/// quantity field and unit dropdown are replaced outright by a static
/// "Al gusto" label: `recipeUnitsFor` returns `{}` for those ingredients,
/// so there is no unit to offer and no number worth asking for. Renders in
/// two
/// lines (ingredient row, then quantity + unit + remove row) so the unit
/// dropdown has enough width for the widest labels (`Kilogramos (kg)`,
/// `Cucharada (cda)`), which the old single-line 3-field layout cramped.
class _BomLineRow extends StatefulWidget {
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
  State<_BomLineRow> createState() => _BomLineRowState();
}

class _BomLineRowState extends State<_BomLineRow> {
  /// Resets [BomDraft.unit] to the newly-picked ingredient's derived-set
  /// default the moment the ingredient changes and the current unit falls
  /// outside that new set.
  ///
  /// Deferred to a post-frame callback rather than called synchronously
  /// from [didUpdateWidget]: `onUnitChanged` ultimately mutates a
  /// `FormControl` and calls `updateValueAndValidity()`, which can trigger
  /// a rebuild — doing that synchronously while the framework is still
  /// mid-build is the same class of bug the old ingredient-picker's
  /// build-time provider invalidate had.
  @override
  void didUpdateWidget(covariant _BomLineRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ingredient?.id == oldWidget.ingredient?.id) return;

    final ingredient = widget.ingredient;
    if (ingredient == null) return;
    final allowed = recipeUnitsFor(ingredient);
    if (allowed.isEmpty || allowed.contains(widget.draft.unit)) return;

    final defaultUnit = allowed.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onUnitChanged(defaultUnit);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ingredient = widget.ingredient;
    final allowedUnits = ingredient == null
        ? const <Unit>[]
        : recipeUnitsFor(ingredient);
    final selectedUnit = allowedUnits.contains(widget.draft.unit)
        ? widget.draft.unit
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: MenuarioSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton(
            key: Key('recipe-bom-ingredient-field-${widget.index}'),
            onPressed: widget.onPickIngredient,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ingredient == null
                    ? 'Seleccionar ingrediente'
                    : '${ingredient.emoji ?? '🥄'} ${ingredient.name}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          MenuarioSpacing.gapV8,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.draft.quantityLess)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: MenuarioSpacing.md),
                    child: Text(
                      alGustoLabel,
                      style: MenuarioTypography.body.withColor(
                        Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else ...[
                Expanded(
                  flex: 2,
                  child: TextField(
                    key: Key('recipe-bom-quantity-field-${widget.index}'),
                    controller: widget.draft.quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                  ),
                ),
                MenuarioSpacing.gapH8,
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<Unit>(
                    key: Key('recipe-bom-unit-field-${widget.index}'),
                    initialValue: selectedUnit,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Unidad'),
                    items: [
                      for (final unit in allowedUnits)
                        DropdownMenuItem(
                          value: unit,
                          child: Text(_unitLabel(unit)),
                        ),
                    ],
                    onChanged: allowedUnits.isEmpty
                        ? null
                        : (value) {
                            if (value != null) widget.onUnitChanged(value);
                          },
                  ),
                ),
              ],
              IconButton(
                key: Key('recipe-bom-remove-${widget.index}'),
                icon: const Icon(Icons.delete_outline),
                onPressed: widget.onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
