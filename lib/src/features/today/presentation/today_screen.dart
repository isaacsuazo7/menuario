import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/features/today/presentation/providers/today_tab_provider.dart';
import 'package:menuario/src/features/today/presentation/widgets/_cook_body.dart';
import 'package:menuario/src/features/today/presentation/widgets/_eat_body.dart';
import 'package:menuario/src/features/today/presentation/widgets/_today_header.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';
import 'package:menuario/src/shared/shared.dart';

/// The active [WeekPlan] and every loaded [Recipe], combined so [TodayScreen]
/// can drive a single [AppAsyncValueWidget]. `authStateProvider`'s
/// [AsyncValue] gates the same loading/error state (via [_combine]) but its
/// resolved [User] isn't carried here — `TodayHeader` re-watches it directly.
typedef _TodayScreenData = ({WeekPlan plan, List<Recipe> recipes});

/// Combines [planAsync], [recipesAsync] and [authAsync] into one
/// [AsyncValue]: an error on any side surfaces first, then loading until all
/// three have resolved, then the combined [_TodayScreenData].
AsyncValue<_TodayScreenData> _combine(
  AsyncValue<WeekPlan> planAsync,
  AsyncValue<List<Recipe>> recipesAsync,
  AsyncValue<User?> authAsync,
) {
  if (planAsync.hasError) {
    return AsyncError(planAsync.error!, planAsync.stackTrace!);
  }
  if (recipesAsync.hasError) {
    return AsyncError(recipesAsync.error!, recipesAsync.stackTrace!);
  }
  if (authAsync.hasError) {
    return AsyncError(authAsync.error!, authAsync.stackTrace!);
  }

  final plan = planAsync.value;
  final recipes = recipesAsync.value;
  if (plan == null || recipes == null || authAsync.isLoading) {
    return const AsyncLoading();
  }

  return AsyncData((plan: plan, recipes: recipes));
}

/// The "Hoy" tab body: a read-only daily home surface — a greeting + Spanish
/// date, and a `[Cocinar | Comer]` toggle over two schedule-derived lenses
/// on the active [WeekPlan]. No plan mutation happens here: [PlanEntry.cooked]
/// and `PlanController`'s mutators are untouched by this feature.
///
/// Rendered inside the shell's single [Scaffold]/[AppBar]; keeps its own
/// [Scaffold] (without an `appBar`), matching [ProvisioningScreen] and
/// `WeekScreen`.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planControllerProvider);
    final recipesAsync = ref.watch(recipeListProvider);
    final authAsync = ref.watch(authStateProvider);
    final combined = _combine(planAsync, recipesAsync, authAsync);
    final tab = ref.watch(todayTabProvider);

    return Scaffold(
      body: AppAsyncValueWidget<_TodayScreenData>(
        value: combined,
        onRetry: () {
          ref.invalidate(planControllerProvider);
          ref.invalidate(recipeListProvider);
        },
        builder: (context, _) {
          return Column(
            children: [
              const TodayHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: MenuarioSpacing.md,
                ),
                child: SegmentedButton<TodayTab>(
                  segments: const [
                    ButtonSegment(
                      value: TodayTab.cocinar,
                      label: Text('Cocinar'),
                    ),
                    ButtonSegment(value: TodayTab.comer, label: Text('Comer')),
                  ],
                  selected: {tab},
                  onSelectionChanged: (selection) =>
                      ref.read(todayTabProvider.notifier).set(selection.first),
                ),
              ),
              Expanded(
                child: switch (tab) {
                  TodayTab.cocinar => const CookBody(),
                  TodayTab.comer => const EatBody(),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
