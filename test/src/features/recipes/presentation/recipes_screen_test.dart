import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/recipes/presentation/recipes_screen.dart';

void main() {
  testWidgets('RecipesScreen renders the "Recetario" title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: RecipesScreen())),
    );

    expect(find.text('Recetario'), findsOneWidget);
  });
}
