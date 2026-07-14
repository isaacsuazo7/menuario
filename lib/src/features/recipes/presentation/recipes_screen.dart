import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder screen for the "Recetario" (recipes) tab.
///
/// Displays only a title until the recipes-feature domain/data layers land.
class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recetario')),
      body: const Center(child: Text('Próximamente')),
    );
  }
}
