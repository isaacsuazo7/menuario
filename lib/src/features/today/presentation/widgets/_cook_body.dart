import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/today/presentation/models/cook_item.dart';
import 'package:menuario/src/features/today/presentation/providers/cook_list_provider.dart';
import 'package:menuario/src/features/today/presentation/widgets/today_meal_detail_sheet.dart';
import 'package:menuario/src/features/week/presentation/widgets/_plan_slot_cell.dart';

/// The Cocinar body: resolved batch-cook targets grouped into "Para hoy" /
/// "Para mañana" sections, each hidden when empty.
///
/// Rendered only once `TodayScreen`'s combined `AsyncValue` has resolved,
/// so [cookListProvider] is already `AsyncData` by the time this builds.
class CookBody extends ConsumerWidget {
  const CookBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(cookListProvider).value;
    final hoy = lists?.hoy ?? const <CookItem>[];
    final manana = lists?.manana ?? const <CookItem>[];

    if (hoy.isEmpty && manana.isEmpty) {
      return const Center(
        child: Padding(
          padding: MenuarioSpacing.paddingAll16,
          child: Text('Nada para cocinar hoy', textAlign: TextAlign.center),
        ),
      );
    }

    return ListView(
      children: [
        if (hoy.isNotEmpty) _GroupSection(title: 'Para hoy', items: hoy),
        if (manana.isNotEmpty)
          _GroupSection(title: 'Para mañana', items: manana),
      ],
    );
  }
}

class _GroupSection extends StatelessWidget {
  const _GroupSection({required this.title, required this.items});

  final String title;
  final List<CookItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            MenuarioSpacing.md,
            MenuarioSpacing.md,
            MenuarioSpacing.md,
            MenuarioSpacing.xs,
          ),
          child: Text(title, style: MenuarioTypography.h6),
        ),
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
