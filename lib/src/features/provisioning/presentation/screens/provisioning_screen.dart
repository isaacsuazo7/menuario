import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_groups_provider.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_category_section.dart';
import 'package:menuario/src/features/shopping/presentation/providers/provisioning_tab_provider.dart';
import 'package:menuario/src/features/shopping/presentation/widgets/shopping_list_section.dart';
import 'package:menuario/src/shared/shared.dart';

/// The "Abastecer" tab body: a `[Despensa | Comprar]` toggle switching
/// between the pantry list (inline stock/have-flag editing) and the
/// derived shopping list — no new tab or route.
///
/// Rendered inside the shell's single [Scaffold]/[AppBar]; keeps its own
/// [Scaffold] (without an `appBar`) purely to provide the [Material]
/// ancestor its [ListTile]/[Switch] descendants require.
class ProvisioningScreen extends ConsumerWidget {
  const ProvisioningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(provisioningTabProvider);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: MenuarioSpacing.paddingAll16,
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
          Expanded(
            child: switch (tab) {
              ProvisioningTab.despensa => const _DespensaBody(),
              ProvisioningTab.comprar => const ShoppingListSection(),
            },
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
