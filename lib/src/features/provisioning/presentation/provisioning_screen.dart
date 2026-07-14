import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder screen for the "Abastecer" (provisioning) tab.
///
/// Displays only a title until the provisioning-feature domain/data layers
/// land.
class ProvisioningScreen extends ConsumerWidget {
  const ProvisioningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Abastecer')),
      body: const Center(child: Text('Próximamente')),
    );
  }
}
