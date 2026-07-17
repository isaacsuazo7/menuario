import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/shared/shared.dart';

/// Pure and dependency-free (see [StockLensService]'s "no DI needed"
/// design decision) — safe to hold as a single const instance.
const _stockLensService = StockLensService();

/// Direct-entry bottom sheet: sets a quantity-tracked item's stock to an
/// exact absolute value, typed in one of the ingredient's
/// [MeasurementMode]-driven input lenses (see [StockLensService.lensesFor])
/// and converted to the item's canonical stock unit via
/// [StockLens.toCanonical] on confirm.
///
/// This is the app's first real form surface — it establishes the
/// [MenuarioSpacing]/[MenuarioTypography] form idiom future sheets should
/// copy.
class SetStockSheet extends ConsumerStatefulWidget {
  const SetStockSheet({super.key, required this.row});

  /// The row whose stock is being set. `row.item` MUST be a
  /// [QuantityTrackedPantryItem].
  final PantryRow row;

  @override
  ConsumerState<SetStockSheet> createState() => _SetStockSheetState();
}

class _SetStockSheetState extends ConsumerState<SetStockSheet> {
  late final QuantityTrackedPantryItem _item;
  late final Ingredient _ingredient;
  late final List<StockLens> _lenses;
  late final TextEditingController _controller;
  late StockLens _selectedLens;

  @override
  void initState() {
    super.initState();
    _item = widget.row.item as QuantityTrackedPantryItem;
    _ingredient = widget.row.ingredient;
    _lenses = _stockLensService.lensesFor(_ingredient);
    _selectedLens = _stockLensService.defaultLensFor(_ingredient);

    final naturalValue = _selectedLens.fromCanonical(_item.stock.value);
    _controller = TextEditingController(
      text: _formatNatural(naturalValue, _selectedLens),
    );
    _controller.addListener(_handleFieldChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleFieldChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleFieldChanged() => setState(() {});

  /// Trims trailing fractional zeros (and a bare trailing `.`), so `1.00`
  /// displays as `1` and `0.50` as `0.5`. Integer-only lenses round first,
  /// since their field never carries a decimal point.
  String _formatNatural(num value, StockLens lens) {
    if (!lens.allowsDecimal) return value.round().toString();

    var fixed = value.toStringAsFixed(2);
    while (fixed.contains('.') && fixed.endsWith('0')) {
      fixed = fixed.substring(0, fixed.length - 1);
    }
    if (fixed.endsWith('.')) {
      fixed = fixed.substring(0, fixed.length - 1);
    }
    return fixed;
  }

  /// The typed value in [_selectedLens]'s unit, or `null` when the field is
  /// empty or not a valid number.
  num? get _parsedValue {
    final text = _controller.text.trim();
    if (text.isEmpty) return null;
    return num.tryParse(text);
  }

  /// The typed value converted to the ingredient's canonical stock unit via
  /// [_selectedLens], or `null` when there is nothing valid to preview yet.
  num? get _canonicalValue {
    final parsed = _parsedValue;
    if (parsed == null) return null;
    return _selectedLens.toCanonical(parsed);
  }

  /// Reasonable quick-set defaults in [_selectedLens]'s unit: half/1/2/3
  /// for decimal lenses, 1/2/3 for integer-only lenses.
  List<num> get _quickSetOptions =>
      _selectedLens.allowsDecimal ? const [0.5, 1, 2, 3] : const [1, 2, 3];

  void _handleChipTap(num naturalValue) {
    _controller.text = _formatNatural(naturalValue, _selectedLens);
  }

  /// Switches the active lens, re-scaling the field to the same canonical
  /// value expressed in the new lens's unit — so the underlying quantity
  /// never changes just because the user changed how they're looking at it.
  void _handleLensChanged(StockLens lens) {
    final canonical = _canonicalValue ?? _item.stock.value;
    setState(() => _selectedLens = lens);
    _controller.text = _formatNatural(lens.fromCanonical(canonical), lens);
  }

  Future<void> _handleConfirm() async {
    final canonical = _canonicalValue;
    if (canonical == null || canonical < 0) return;

    final notifier = ref.read(pantryControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();

    final failure = await notifier.setStock(_item.ingredientId, canonical);

    if (failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final canonical = _canonicalValue;
    final canConfirm = canonical != null && canonical >= 0;
    final otherLenses = _lenses.where((lens) => lens != _selectedLens);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: MenuarioSpacing.md,
          right: MenuarioSpacing.md,
          top: MenuarioSpacing.md,
          bottom: MediaQuery.of(context).viewInsets.bottom + MenuarioSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.row.ingredient.emoji ?? '🥫',
                  style: const TextStyle(fontSize: 24),
                ),
                MenuarioSpacing.gapH8,
                Expanded(
                  child: Text(
                    widget.row.ingredient.name,
                    style: MenuarioTypography.h4,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (_lenses.length > 1) ...[
              MenuarioSpacing.gapV16,
              SegmentedButton<StockLens>(
                segments: [
                  for (final lens in _lenses)
                    ButtonSegment(value: lens, label: Text(lens.label)),
                ],
                selected: {_selectedLens},
                showSelectedIcon: false,
                onSelectionChanged: (selection) =>
                    _handleLensChanged(selection.first),
              ),
            ],
            MenuarioSpacing.gapV16,
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.numberWithOptions(
                decimal: _selectedLens.allowsDecimal,
              ),
              inputFormatters: [
                if (_selectedLens.allowsDecimal)
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                else
                  FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: 'Cantidad',
                suffixText: _selectedLens.label,
                border: const OutlineInputBorder(),
              ),
            ),
            MenuarioSpacing.gapV8,
            if (canonical == null)
              Text(
                'Ingresa una cantidad válida',
                style: MenuarioTypography.body,
              )
            else
              for (final lens in otherLenses)
                Text(
                  '= ${_formatNatural(lens.fromCanonical(canonical), lens)} '
                  '${lens.label}',
                  style: MenuarioTypography.body,
                ),
            MenuarioSpacing.gapV16,
            Wrap(
              spacing: MenuarioSpacing.sm,
              children: [
                for (final option in _quickSetOptions)
                  ChoiceChip(
                    label: Text(
                      '${_formatNatural(option, _selectedLens)} '
                      '${_selectedLens.label}',
                    ),
                    selected: false,
                    onSelected: (_) => _handleChipTap(option),
                  ),
              ],
            ),
            MenuarioSpacing.gapV16,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                MenuarioSpacing.gapH8,
                FilledButton(
                  onPressed: canConfirm ? _handleConfirm : null,
                  child: const Text('Confirmar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
