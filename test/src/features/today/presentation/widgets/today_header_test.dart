import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/features/today/presentation/providers/now_provider.dart';
import 'package:menuario/src/features/today/presentation/widgets/_today_header.dart';
import 'package:mocktail/mocktail.dart';

class MockUser extends Mock implements User {}

void main() {
  Future<void> pumpHeader(
    WidgetTester tester, {
    User? user,
    DateTime? now,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(user)),
          nowProvider.overrideWithValue(now ?? DateTime(2024, 1, 2)),
        ],
        child: const MaterialApp(home: Scaffold(body: TodayHeader())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the first name and the Spanish date', (tester) async {
    final mockUser = MockUser();
    when(() => mockUser.displayName).thenReturn('Isaac Suazo');

    await pumpHeader(tester, user: mockUser, now: DateTime(2024, 1, 2));

    expect(find.textContaining('Isaac'), findsOneWidget);
    expect(find.textContaining('Martes 2 de enero'), findsOneWidget);
  });

  testWidgets(
    'falls back to a generic greeting when displayName is null, without '
    'crashing',
    (tester) async {
      final mockUser = MockUser();
      when(() => mockUser.displayName).thenReturn(null);

      await pumpHeader(tester, user: mockUser);

      expect(tester.takeException(), isNull);
      expect(find.textContaining('null'), findsNothing);
    },
  );

  testWidgets(
    'falls back to a generic greeting when displayName is empty',
    (tester) async {
      final mockUser = MockUser();
      when(() => mockUser.displayName).thenReturn('');

      await pumpHeader(tester, user: mockUser);

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('renders the date even without a signed-in user', (
    tester,
  ) async {
    await pumpHeader(tester, user: null, now: DateTime(2024, 1, 2));

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Martes 2 de enero'), findsOneWidget);
  });
}
