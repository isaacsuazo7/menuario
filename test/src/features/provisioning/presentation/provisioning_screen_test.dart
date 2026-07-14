import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/provisioning/presentation/provisioning_screen.dart';

void main() {
  testWidgets('ProvisioningScreen renders the "Abastecer" title', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ProvisioningScreen())),
    );

    expect(find.text('Abastecer'), findsOneWidget);
  });
}
