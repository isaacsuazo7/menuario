import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/today/presentation/providers/now_provider.dart';
import 'package:menuario/src/features/today/presentation/widgets/_today_header.dart';

void main() {
  Future<void> pumpHeader(WidgetTester tester, {DateTime? now}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [nowProvider.overrideWithValue(now ?? DateTime(2024, 1, 2))],
        child: const MaterialApp(home: Scaffold(body: TodayHeader())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the morning greeting and its icon', (tester) async {
    await pumpHeader(tester, now: DateTime(2024, 1, 2, 8));

    expect(find.text('Buenos días'), findsOneWidget);
    expect(find.byIcon(Icons.wb_sunny_outlined), findsOneWidget);
  });

  testWidgets('shows the afternoon greeting and its icon', (tester) async {
    await pumpHeader(tester, now: DateTime(2024, 1, 2, 15));

    expect(find.text('Buenas tardes'), findsOneWidget);
    expect(find.byIcon(Icons.wb_twilight_outlined), findsOneWidget);
  });

  testWidgets('shows the night greeting and its icon', (tester) async {
    await pumpHeader(tester, now: DateTime(2024, 1, 2, 22));

    expect(find.text('Buenas noches'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
  });

  testWidgets('never shows the user name in the greeting', (tester) async {
    await pumpHeader(tester, now: DateTime(2024, 1, 2, 8));

    expect(find.textContaining('Bienvenido'), findsNothing);
  });

  testWidgets('keeps the Spanish long date line', (tester) async {
    await pumpHeader(tester, now: DateTime(2024, 1, 2, 8));

    expect(find.text('Martes 2 de enero'), findsOneWidget);
  });

  testWidgets('renders the greeting with the larger h2 style', (tester) async {
    await pumpHeader(tester, now: DateTime(2024, 1, 2, 8));

    final greeting = tester.widget<Text>(find.text('Buenos días'));
    expect(greeting.style, MenuarioTypography.h2);
  });

  testWidgets('tints the greeting icon from the color scheme', (tester) async {
    await pumpHeader(tester, now: DateTime(2024, 1, 2, 8));

    final context = tester.element(find.byType(TodayHeader));
    final icon = tester.widget<Icon>(find.byIcon(Icons.wb_sunny_outlined));
    expect(icon.color, Theme.of(context).colorScheme.primary);
  });

  testWidgets('renders the date larger and dimmed', (tester) async {
    await pumpHeader(tester, now: DateTime(2024, 1, 2));

    final date = tester.widget<Text>(find.text('Martes 2 de enero'));
    expect(date.style?.fontSize, MenuarioTypography.h6.fontSize);
  });
}
