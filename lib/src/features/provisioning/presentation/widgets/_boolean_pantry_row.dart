import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_state_pill.dart';
import 'package:menuario/src/shared/shared.dart';

/// A boolean-tracked Despensa row: emoji, name, a [StatePill], and a
/// have/don't-have toggle wired to [PantryController.toggleHave].
class BooleanPantryRow extends ConsumerWidget {
  const BooleanPantryRow({super.key, required this.row});

  /// The row to render. `row.item` MUST be a [BooleanTrackedPantryItem].
  final PantryRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // See `QuantityPantryRow` for why this watches the controller directly
    // instead of trusting `row` as a static prop.
    final liveRows = ref.watch(pantryControllerProvider).value;
    final liveRow =
        liveRows?.firstWhere(
          (candidate) => candidate.item.ingredientId == row.item.ingredientId,
          orElse: () => row,
        ) ??
        row;
    final item = liveRow.item as BooleanTrackedPantryItem;
    final ingredient = liveRow.ingredient;

    Future<void> handleToggle() async {
      final failure = await ref
          .read(pantryControllerProvider.notifier)
          .toggleHave(item.ingredientId);

      if (failure != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      }
    }

    return ListTile(
      leading: EmojiAvatar(emoji: ingredient.emoji ?? '🥫', size: 32),
      title: Text(ingredient.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatePill(isPositive: item.haveIt),
          Switch(value: item.haveIt, onChanged: (_) => handleToggle()),
        ],
      ),
    );
  }
}
