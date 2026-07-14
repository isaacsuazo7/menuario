import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/today/presentation/today_screen.dart';

void main() {
  testWidgets('TodayScreen renders its placeholder body without an AppBar', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: TodayScreen())),
    );

    expect(find.text('Próximamente'), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
  });
}
