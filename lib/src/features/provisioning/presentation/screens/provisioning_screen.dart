import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_groups_provider.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_category_section.dart';
import 'package:menuario/src/shared/shared.dart';

/// The "Abastecer" (Despensa) tab body: the pantry grouped by category with
/// inline stock/have-flag editing.
///
/// Rendered inside the shell's single [Scaffold]/[AppBar]; keeps its own
/// [Scaffold] (without an `appBar`) purely to provide the [Material]
/// ancestor its [ListTile]/[Switch] descendants require.
class ProvisioningScreen extends ConsumerWidget {
  const ProvisioningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsValue = ref.watch(pantryGroupsProvider);

    return Scaffold(
      body: AppAsyncValueWidget<List<PantryCategoryGroup>>(
        value: groupsValue,
        onRetry: () => ref.invalidate(pantryControllerProvider),
        builder: (context, groups) {
          if (groups.isEmpty) {
            return const _EmptyPantry();
          }
          return ListView(
            children: [
              for (final group in groups) CategorySection(group: group),
            ],
          );
        },
      ),
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
