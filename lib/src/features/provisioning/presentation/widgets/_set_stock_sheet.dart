import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/shared/shared.dart';

/// Pure and dependency-free (see [StockPresentationService]'s "no DI
/// needed" design decision) — safe to hold as a single const instance.
const _stockPresentation = StockPresentationService();

/// Direct-entry bottom sheet: sets a quantity-tracked item's stock to an
/// exact absolute value, typed in the item's natural purchase unit (lb for
/// `counter`, packs for `package`, whole units for `loose`) and converted
/// to the stock's own unit (grams or count) via [StockPresentationService]
/// on confirm.
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
  late final TextEditingController _controller;
  late final bool _allowsDecimal;

  @override
  void initState() {
    super.initState();
    _item = widget.row.item as QuantityTrackedPantryItem;
    _allowsDecimal = _item.presentation is PresentationCounter;

    final naturalValue = _stockPresentation.toNaturalValue(
      stockValue: _item.stock.value,
      presentation: _item.presentation,
    );
    _controller = TextEditingController(text: _formatNatural(naturalValue));
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
  /// displays as `1` and `0.50` as `0.5`. Integer-only presentations round
  /// first, since their field never carries a decimal point.
  String _formatNatural(num value) {
    if (!_allowsDecimal) return value.round().toString();

    var fixed = value.toStringAsFixed(2);
    while (fixed.contains('.') && fixed.endsWith('0')) {
      fixed = fixed.substring(0, fixed.length - 1);
    }
    if (fixed.endsWith('.')) {
      fixed = fixed.substring(0, fixed.length - 1);
    }
    return fixed;
  }

  /// The typed value in the field's natural unit, or `null` when the field
  /// is empty or not a valid number.
  num? get _parsedValue {
    final text = _controller.text.trim();
    if (text.isEmpty) return null;
    return num.tryParse(text);
  }

  /// The typed value converted to the item's stock unit (grams or count),
  /// or `null` when there is nothing valid to preview yet.
  num? get _previewStockValue {
    final parsed = _parsedValue;
    if (parsed == null) return null;
    return _stockPresentation.toStockValue(
      naturalValue: parsed,
      presentation: _item.presentation,
      stockUnit: _item.stock.unit,
    );
  }

  /// The natural-unit label shown as the field suffix and on quick-set
  /// chips: `lb` for counter, the pack `label` for package, `u` for loose.
  String get _naturalUnitLabel => switch (_item.presentation) {
    PresentationCounter() => 'lb',
    PresentationPackage(:final label) => label,
    PresentationLoose() => 'u',
  };

  /// Reasonable quick-set defaults in the field's natural unit: half/1/2/3
  /// lb for counter, 1/2/3 units or packs otherwise.
  List<num> get _quickSetOptions =>
      _allowsDecimal ? const [0.5, 1, 2, 3] : const [1, 2, 3];

  void _handleChipTap(num naturalValue) {
    _controller.text = _formatNatural(naturalValue);
  }

  Future<void> _handleConfirm() async {
    final parsed = _parsedValue;
    if (parsed == null || parsed < 0) return;

    final stockValue = _stockPresentation.toStockValue(
      naturalValue: parsed,
      presentation: _item.presentation,
      stockUnit: _item.stock.unit,
    );

    final notifier = ref.read(pantryControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();

    final failure = await notifier.setStock(_item.ingredientId, stockValue);

    if (failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _previewStockValue;
    final unitSymbol = _item.stock.unit.symbol;
    final canConfirm = _parsedValue != null && _parsedValue! >= 0;

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
                Text(widget.row.ingredient.name, style: MenuarioTypography.h4),
              ],
            ),
            MenuarioSpacing.gapV16,
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.numberWithOptions(
                decimal: _allowsDecimal,
              ),
              inputFormatters: [
                if (_allowsDecimal)
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                else
                  FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: 'Cantidad',
                suffixText: _naturalUnitLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            MenuarioSpacing.gapV8,
            Text(
              preview == null
                  ? 'Ingresa una cantidad válida'
                  : '≈ ${preview.round()} $unitSymbol',
              style: MenuarioTypography.body,
            ),
            MenuarioSpacing.gapV16,
            Wrap(
              spacing: MenuarioSpacing.sm,
              children: [
                for (final option in _quickSetOptions)
                  ChoiceChip(
                    label: Text('${_formatNatural(option)} $_naturalUnitLabel'),
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
