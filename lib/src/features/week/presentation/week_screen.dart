import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder body for the "Semana" (week) tab.
///
/// Rendered inside the shell's single [Scaffold]/[AppBar]; displays only a
/// placeholder message until the week-feature domain/data layers land.
class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Próximamente'));
  }
}
