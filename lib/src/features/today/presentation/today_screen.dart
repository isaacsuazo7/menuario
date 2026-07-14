import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder screen for the "Hoy" (today) tab.
///
/// Displays only a title until the today-feature domain/data layers land.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hoy')),
      body: const Center(child: Text('Próximamente')),
    );
  }
}
