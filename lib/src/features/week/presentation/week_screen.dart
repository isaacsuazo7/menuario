import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder screen for the "Semana" (week) tab.
///
/// Displays only a title until the week-feature domain/data layers land.
class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Semana')),
      body: const Center(child: Text('Próximamente')),
    );
  }
}
