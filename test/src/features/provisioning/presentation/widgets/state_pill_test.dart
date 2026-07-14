import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_state_pill.dart';

void main() {
  testWidgets('shows the green pill when isPositive is true', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: StatePill(isPositive: true))),
    );

    expect(find.text('🟢 Tengo'), findsOneWidget);
    expect(find.text('🔴 No tengo'), findsNothing);
  });

  testWidgets('shows the red pill when isPositive is false', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: StatePill(isPositive: false))),
    );

    expect(find.text('🔴 No tengo'), findsOneWidget);
    expect(find.text('🟢 Tengo'), findsNothing);
  });
}
