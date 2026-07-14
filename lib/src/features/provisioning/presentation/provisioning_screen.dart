import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder body for the "Abastecer" (provisioning) tab.
///
/// Rendered inside the shell's single [Scaffold]/[AppBar]; displays only a
/// placeholder message until the provisioning-feature domain/data layers
/// land.
class ProvisioningScreen extends ConsumerWidget {
  const ProvisioningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Próximamente'));
  }
}
