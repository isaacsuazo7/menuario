import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/today/presentation/providers/now_provider.dart';
import 'package:menuario/src/features/today/presentation/widgets/_today_header.dart';
import 'package:mocktail/mocktail.dart';

class MockUser extends Mock implements User {}

void main() {
  MockUser buildUser({String? displayName, String? email}) {
    final user = MockUser();
    when(() => user.displayName).thenReturn(displayName);
    when(() => user.email).thenReturn(email);
    return user;
  }

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
    final user = buildUser(displayName: 'Isaac Suazo');

    await pumpHeader(tester, user: user, now: DateTime(2024, 1, 2));

    expect(find.textContaining('Isaac'), findsOneWidget);
    expect(find.textContaining('Martes 2 de enero'), findsOneWidget);
  });

  testWidgets(
    'derives the greeting name from the email when displayName is null',
    (tester) async {
      final user = buildUser(displayName: null, email: 'isaac.suazo@x.com');

      await pumpHeader(tester, user: user);

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Isaac'), findsOneWidget);
    },
  );

  testWidgets(
    'derives the greeting name from the email when displayName is empty',
    (tester) async {
      final user = buildUser(displayName: '', email: 'dev-claude@cit.hn');

      await pumpHeader(tester, user: user);

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Dev-claude'), findsOneWidget);
    },
  );

  testWidgets(
    'falls back to "¡Bienvenido!" when neither displayName nor email exist',
    (tester) async {
      final user = buildUser(displayName: null, email: null);

      await pumpHeader(tester, user: user);

      expect(tester.takeException(), isNull);
      expect(find.text('¡Bienvenido!'), findsOneWidget);
      expect(find.textContaining('null'), findsNothing);
    },
  );

  testWidgets('renders the date even without a signed-in user', (tester) async {
    await pumpHeader(tester, user: null, now: DateTime(2024, 1, 2));

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Martes 2 de enero'), findsOneWidget);
  });

  testWidgets('renders the greeting with the larger h2 style', (tester) async {
    final user = buildUser(displayName: 'Isaac Suazo');

    await pumpHeader(tester, user: user);

    final greeting = tester.widget<Text>(find.text('Bienvenido Isaac'));
    expect(greeting.style, MenuarioTypography.h2);
  });

  testWidgets('renders the date larger and dimmed', (tester) async {
    await pumpHeader(tester, user: null, now: DateTime(2024, 1, 2));

    final date = tester.widget<Text>(find.text('Martes 2 de enero'));
    expect(date.style?.fontSize, MenuarioTypography.h6.fontSize);
  });
}
