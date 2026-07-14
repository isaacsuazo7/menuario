import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder body for the "Hoy" (today) tab.
///
/// Rendered inside the shell's single [Scaffold]/[AppBar]; displays only a
/// placeholder message until the today-feature domain/data layers land.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Próximamente'));
  }
}
