import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_groups_provider.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_category_section.dart';
import 'package:menuario/src/features/shopping/presentation/providers/provisioning_tab_provider.dart';
import 'package:menuario/src/features/shopping/presentation/widgets/shopping_list_section.dart';
import 'package:menuario/src/shared/presentation/tab_page_sync.dart';
import 'package:menuario/src/shared/shared.dart';

/// The "Abastecer" tab body: a `[Despensa | Comprar]` toggle switching
/// between the pantry list (inline stock/have-flag editing) and the
/// derived shopping list — no new tab or route.
///
/// Rendered inside the shell's single [Scaffold]/[AppBar]; keeps its own
/// [Scaffold] (without an `appBar`) purely to provide the [Material]
/// ancestor its [ListTile]/[Switch] descendants require.
class ProvisioningScreen extends ConsumerStatefulWidget {
  const ProvisioningScreen({super.key});

  @override
  ConsumerState<ProvisioningScreen> createState() => _ProvisioningScreenState();
}

class _ProvisioningScreenState extends ConsumerState<ProvisioningScreen>
    with TabPageSync<ProvisioningScreen> {
  @override
  int get initialTabIndex => ref.read(provisioningTabProvider).index;

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(provisioningTabProvider);

    // Provider -> page: keep the swipe view in sync when the tab changes
    // (toggle tap or anywhere else). ref.listen MUST sit at build()'s root.
    ref.listen<ProvisioningTab>(provisioningTabProvider, (previous, next) {
      syncPageToIndex(next.index);
    });

    return Scaffold(
      body: Column(
        // Stretch so the tab band spans the full width: an opaque band that
        // only covered its own natural width would still let the coverage
        // colors of the list show either side of it.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            key: const Key('provisioning-tab-band'),
            // The band owns an opaque background of its own. Without it the
            // red/amber coverage rows underneath show through, and the band
            // reads as floating over the list instead of anchoring it.
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: MenuarioSpacing.paddingAll16,
              child: Center(
                child: SegmentedButton<ProvisioningTab>(
                  segments: const [
                    ButtonSegment(
                      value: ProvisioningTab.despensa,
                      label: Text('Despensa'),
                    ),
                    ButtonSegment(
                      value: ProvisioningTab.comprar,
                      label: Text('Comprar'),
                    ),
                  ],
                  selected: {tab},
                  onSelectionChanged: (selection) => ref
                      .read(provisioningTabProvider.notifier)
                      .set(selection.first),
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (index) => ref
                  .read(provisioningTabProvider.notifier)
                  .set(ProvisioningTab.values[index]),
              children: const [_DespensaBody(), ShoppingListSection()],
            ),
          ),
        ],
      ),
    );
  }
}

class _DespensaBody extends ConsumerWidget {
  const _DespensaBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsValue = ref.watch(pantryGroupsProvider);

    return AppAsyncValueWidget<List<PantryCategoryGroup>>(
      value: groupsValue,
      onRetry: () => ref.invalidate(pantryControllerProvider),
      builder: (context, groups) {
        if (groups.isEmpty) {
          return const _EmptyPantry();
        }
        return ListView(
          children: [for (final group in groups) CategorySection(group: group)],
        );
      },
    );
  }
}

class _EmptyPantry extends StatelessWidget {
  const _EmptyPantry();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tu despensa está vacía.'));
  }
}
