import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/today/presentation/greeting.dart';
import 'package:menuario/src/features/today/presentation/providers/now_provider.dart';

/// The time-of-day greeting + Spanish long date header.
///
/// Carries no user name on purpose — the signed-in identity already lives in
/// the drawer. Reads [nowProvider] (never `DateTime.now()`) so both the
/// greeting and the date stay testable without the wall clock.
class TodayHeader extends ConsumerWidget {
  const TodayHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowProvider);
    final greeting = greetingFor(now);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: MenuarioSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(greeting.icon, color: colorScheme.primary),
              MenuarioSpacing.gapH8,
              Text(greeting.label, style: MenuarioTypography.h2),
            ],
          ),
          MenuarioSpacing.gapV4,
          Text(
            spanishLongDate(now),
            style: MenuarioTypography.h6.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
