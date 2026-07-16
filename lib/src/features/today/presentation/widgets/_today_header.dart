import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/today/presentation/greeting.dart';
import 'package:menuario/src/features/today/presentation/providers/now_provider.dart';

/// The "Bienvenido {first name}" + Spanish long date header.
///
/// Reads [authStateProvider] for the name and [nowProvider] for the date —
/// both overridable seams, so this widget is testable without touching
/// Firebase or the wall clock.
class TodayHeader extends ConsumerWidget {
  const TodayHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final now = ref.watch(nowProvider);
    final firstName = firstNameFrom(user?.displayName);
    final greeting = firstName.isEmpty
        ? '¡Bienvenido!'
        : 'Bienvenido $firstName';

    return Padding(
      padding: MenuarioSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting, style: MenuarioTypography.h4),
          MenuarioSpacing.gapV4,
          Text(
            spanishLongDate(now),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
