import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_set_stock_sheet.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_state_pill.dart';
import 'package:menuario/src/shared/shared.dart';

/// Pure and dependency-free (see [StockLensService]'s "no DI needed"
/// design decision) — safe to hold as a single const instance. Drives the
/// row's mode-aware stock display, step and effective-zero status.
const _stockLensService = StockLensService();

/// A quantity-tracked Despensa row: emoji, name, purchase-unit stock
/// display, a [StatePill], and a +/- stepper wired to
/// [PantryController.adjustStock] with a presentation-aware smart step.
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
      leading: Text(
        ingredient.emoji ?? '🥫',
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(ingredient.name),
      subtitle: InkWell(onTap: handleOpenSetStock, child: Text(display)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatePill(
            isPositive: !_stockLensService.isEffectivelyZero(
              ingredient,
              item.stock,
            ),
          ),
          MenuarioSpacing.gapH8,
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () => handleAdjust(-step),
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
