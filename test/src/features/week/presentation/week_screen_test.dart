import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/week/presentation/week_screen.dart';

void main() {
  testWidgets('WeekScreen renders the "Semana" title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: WeekScreen())),
    );

    expect(find.text('Semana'), findsOneWidget);
  });
}
