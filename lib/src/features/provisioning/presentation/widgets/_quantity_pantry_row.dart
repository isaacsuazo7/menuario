import 'dart:math' as math;

import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/theme/coverage_colors.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/weekly_consumption_provider.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_set_stock_sheet.dart';
import 'package:menuario/src/shared/shared.dart';

/// Pure and dependency-free (see [StockLensService]'s "no DI needed"
/// design decision) — safe to hold as a single const instance. Drives the
/// row's mode-aware stock display, step and effective-zero status.
const _stockLensService = StockLensService();

/// Pure and dependency-free, same as [_stockLensService] — derives the
/// row's tri-state coverage status.
const _coverageCalculator = CoverageCalculator();

/// A quantity-tracked Despensa row: emoji, name, purchase-unit stock
/// display (with a weekly-need suffix when planned), and a +/- stepper
/// wired to [PantryController.adjustStock] with a presentation-aware
/// smart step.
///
/// Row-level status color is driven ENTIRELY by [CoverageCalculator] — a
/// single tri-state source of truth ([CoverageStatus]) that supersedes
/// the previous binary effective-zero tile tint (never layered on top of
/// it). Boolean-tracked rows keep the separate "no tengo"/"tengo" pill —
/// see `_state_pill.dart`'s docs for why.
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
    final stockDisplay = _stockLensService.formatStock(ingredient, item.stock);
    final isZero = _stockLensService.isEffectivelyZero(ingredient, item.stock);

    final weeklyNeed = ref
        .watch(weeklyConsumptionByIngredientProvider)
        .value?[ingredient.id];
    final status = _coverageCalculator.statusFor(
      weeklyNeed: weeklyNeed,
      stock: item.stock,
      isEffectivelyZero: isZero,
    );
    final coverageColors = Theme.of(
      context,
    ).extension<MenuarioCoverageColors>();
    final tileColor = coverageColors != null && status != CoverageStatus.neutral
        ? coverageColors.colorFor(status).withValues(alpha: 0.35)
        : null;

    final display = _subtitleFor(
      ingredient: ingredient,
      stockDisplay: stockDisplay,
      weeklyNeed: weeklyNeed,
    );

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
      tileColor: tileColor,
      leading: EmojiAvatar(emoji: ingredient.emoji ?? '🥫', size: 32),
      title: Text(ingredient.name),
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

/// The subtitle text: [stockDisplay] alone when [weeklyNeed] carries no
/// usable signal (not planned, `Left`-skipped/needs-factor, or a
/// zero/negative need — degrading gracefully rather than showing a
/// misleading number), otherwise `"«stock» · necesitás «need»"`, both
/// formatted via [StockLensService.formatStock] so lens/fraction
/// formatting stays consistent between the two numbers.
String _subtitleFor({
  required Ingredient ingredient,
  required String stockDisplay,
  required Either<Failure, Quantity>? weeklyNeed,
}) {
  if (weeklyNeed is! Right<Failure, Quantity>) {
    return stockDisplay;
  }
  final need = weeklyNeed.value;
  if (need.value <= 0) {
    return stockDisplay;
  }
  final needDisplay = _stockLensService.formatStock(ingredient, need);
  return '$stockDisplay · necesitás $needDisplay';
}
