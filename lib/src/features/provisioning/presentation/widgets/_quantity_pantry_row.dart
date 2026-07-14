import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_state_pill.dart';
import 'package:menuario/src/shared/shared.dart';

/// A quantity-tracked Despensa row: emoji, name, stock + unit, a
/// [StatePill], and a +/- stepper wired to
/// [PantryController.adjustStock].
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

    Future<void> handleAdjust(int delta) async {
      final failure = await ref
          .read(pantryControllerProvider.notifier)
          .adjustStock(item.ingredientId, delta);

      if (failure != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      }
    }

    return ListTile(
      leading: Text(
        ingredient.emoji ?? '🥫',
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(ingredient.name),
      subtitle: Text('${item.stock.value} ${item.stock.unit.symbol}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatePill(isPositive: item.stock.value > 0),
          MenuarioSpacing.gapH8,
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () => handleAdjust(-1),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => handleAdjust(1),
          ),
        ],
      ),
    );
  }
}
