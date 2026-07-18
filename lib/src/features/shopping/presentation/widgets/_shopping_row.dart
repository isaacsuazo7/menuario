import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_set_stock_sheet.dart';
import 'package:menuario/src/features/shopping/presentation/models/shopping_row.dart';
import 'package:menuario/src/features/shopping/presentation/providers/shopping_checkoff_provider.dart';
import 'package:menuario/src/shared/shared.dart';

/// A single Comprar tile.
///
/// - Quantity-tracked [row]s: emoji, name (strikethrough once ticked via
///   [shoppingCheckoffProvider], local-only), the purchase-quantity display
///   as a tappable restock launcher, and a checkbox that only ever touches
///   the ephemeral checkoff state.
/// - Boolean-tracked [row]s: quantity-less and tick-only — the checkbox IS
///   the real restock action, calling [PantryController.toggleHave]
///   directly. Never opens [SetStockSheet] (it casts to
///   `QuantityTrackedPantryItem` and would crash).
class ShoppingRowTile extends ConsumerWidget {
  const ShoppingRowTile({super.key, required this.row});

  /// The row to render.
  final ShoppingRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return row.isBooleanTracked
        ? _BooleanRow(row: row)
        : _QuantityRow(row: row);
  }
}

class _BooleanRow extends ConsumerWidget {
  const _BooleanRow({required this.row});

  final ShoppingRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Forces `pantryControllerProvider` to initialize (and this row to
    // rebuild once it resolves) so [handleToggleHave] never races an
    // in-flight load — mirrors `BooleanPantryRow`'s own watch.
    ref.watch(pantryControllerProvider);

    Future<void> handleToggleHave() async {
      final failure = await ref
          .read(pantryControllerProvider.notifier)
          .toggleHave(row.ingredientId);

      if (failure != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      }
    }

    return ListTile(
      leading: EmojiAvatar(emoji: row.ingredient.emoji ?? '🥫', size: 32),
      title: Text(row.ingredient.name),
      trailing: Checkbox(value: false, onChanged: (_) => handleToggleHave()),
    );
  }
}

class _QuantityRow extends ConsumerWidget {
  const _QuantityRow({required this.row});

  final ShoppingRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Forces `pantryControllerProvider` to initialize before the restock
    // launcher ever reads it — see `_BooleanRow`'s matching watch.
    ref.watch(pantryControllerProvider);

    final checked = ref
        .watch(shoppingCheckoffProvider)
        .contains(row.ingredientId);

    void handleToggleCheckoff() {
      ref.read(shoppingCheckoffProvider.notifier).toggle(row.ingredientId);
    }

    Future<void> handleRestockTap() async {
      if (!row.pantryExists) {
        final repository = ref.read(pantryRepositoryProvider);
        await repository.save(row.pantryItem);
        ref.invalidate(pantryControllerProvider);
      }
      // Reads through the controller (not `row.pantryItem`) so an
      // assume-zero ingredient opens the sheet on its now-persisted real
      // row, and an existing ingredient always reflects the latest
      // optimistic state.
      await ref.read(pantryControllerProvider.future);
      if (!context.mounted) return;

      final liveRows = ref.read(pantryControllerProvider).value ?? const [];
      final liveRow = liveRows.firstWhere(
        (candidate) => candidate.item.ingredientId == row.ingredientId,
        orElse: () =>
            PantryRow(item: row.pantryItem, ingredient: row.ingredient),
      );

      await showModalBottomSheet<void>(
        context: context,
        builder: (_) => SetStockSheet(row: liveRow),
      );
    }

    return ListTile(
      leading: EmojiAvatar(emoji: row.ingredient.emoji ?? '🥫', size: 32),
      title: Text(
        row.ingredient.name,
        style: checked
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: InkWell(
        onTap: handleRestockTap,
        child: Text(row.quantityDisplay ?? ''),
      ),
      trailing: Checkbox(
        value: checked,
        onChanged: (_) => handleToggleCheckoff(),
      ),
    );
  }
}
