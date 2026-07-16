import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/features/today/presentation/models/cook_item.dart';
import 'package:menuario/src/features/today/presentation/providers/today_meals_provider.dart';
import 'package:menuario/src/features/today/presentation/widgets/today_meal_detail_sheet.dart';
import 'package:menuario/src/features/week/presentation/providers/today_provider.dart';
import 'package:menuario/src/features/week/presentation/widgets/_plan_slot_cell.dart';

/// The Comer body: today's planned meals in slot order, or the matching
/// empty-state copy.
///
/// Rendered only once `TodayScreen`'s combined `AsyncValue` has resolved,
/// so [todayMealsProvider] is already `AsyncData` by the time this builds.
class EatBody extends ConsumerWidget {
  const EatBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final items = ref.watch(todayMealsProvider).value ?? const [];

    if (today == null) {
      return const _EmptyMessage('Domingo, día libre');
    }
    if (items.isEmpty) {
      return const _EmptyMessage('Nada planeado — planificá en Semana');
    }

    return ListView(
      children: [
        for (final item in items)
          PlanSlotCell(
            day: item.day,
            mealSlot: item.slot,
            entry: item.entry,
            recipe: item.recipe,
            onTap: () => _openSheet(context, item),
          ),
      ],
    );
  }

  void _openSheet(BuildContext context, CookItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          TodayMealDetailSheet(recipe: item.recipe, mealSlot: item.slot),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: MenuarioSpacing.paddingAll16,
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
