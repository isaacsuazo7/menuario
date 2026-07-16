import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_set_stock_sheet.dart';
import 'package:menuario/src/shared/shared.dart';

/// Pure and dependency-free (see [StockLensService]'s "no DI needed"
/// design decision) — safe to hold as a single const instance. Drives the
/// row's mode-aware stock display, step and effective-zero status.
const _stockLensService = StockLensService();

/// A quantity-tracked Despensa row: emoji, name, purchase-unit stock
/// display, and a +/- stepper wired to [PantryController.adjustStock] with
/// a presentation-aware smart step. Effective-zero ("no tengo") status is
/// shown as a subtle row-level error tint rather than a separate pill —
/// see `_state_pill.dart`'s docs for why boolean-tracked rows still use
/// the pill.
class QuantityPantryRow extends ConsumerWidget {
  const QuantityPantryRow({super.key, required this.row});

  /// The row to render. `row.item` MUST be a [QuantityTrackedPantryItem].
  final PantryRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watches the controller directly (rather than trusting `row` as a
    // static prop) so an optimistic patch re-renders this row immediately,
    // even when tested/rendered in isolation from the grouped screen.
    final liveRows = ref.watch(pantryControllerProvider).value;
    final liveRow =
        liveRows?.firstWhere(
          (candidate) => candidate.item.ingredientId == row.item.ingredientId,
          orElse: () => row,
        ) ??
        row;
    final item = liveRow.item as QuantityTrackedPantryItem;
    final ingredient = liveRow.ingredient;
    final step = _stockLensService.stockStep(ingredient);
    final display = _stockLensService.formatStock(ingredient, item.stock);
    final isZero = _stockLensService.isEffectivelyZero(ingredient, item.stock);
    final colorScheme = Theme.of(context).colorScheme;

    // Floors a decrement to exactly 0 rather than no-op-ing above zero, so
    // "no tengo" is always reachable (e.g. 57 g at a ~113.4 g step). `null`
    // when already at the floor, disabling the button instead of issuing a
    // redundant zero-delta save.
    final decrementDelta = -math.min(step, item.stock.value);

    Future<void> handleAdjust(num delta) async {
      final failure = await ref
          .read(pantryControllerProvider.notifier)
          .adjustStock(item.ingredientId, delta);

      if (failure != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      }
    }

    void handleOpenSetStock() {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => SetStockSheet(row: liveRow),
      );
    }

    return ListTile(
      tileColor: isZero
          ? colorScheme.errorContainer.withValues(alpha: 0.35)
          : null,
      leading: Text(
        ingredient.emoji ?? '🥫',
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(
        ingredient.name,
        style: isZero ? TextStyle(color: colorScheme.onErrorContainer) : null,
      ),
      subtitle: InkWell(onTap: handleOpenSetStock, child: Text(display)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: decrementDelta == 0
                ? null
                : () => handleAdjust(decrementDelta),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => handleAdjust(step),
          ),
        ],
      ),
    );
  }
}
