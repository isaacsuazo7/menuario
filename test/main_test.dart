import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/main.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/auth/auth_service.dart';
import 'package:menuario/src/core/theme/theme.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  // No `bootstrapFirebase`/`Firebase.initializeApp` call anywhere in this
  // file — `MenuarioApp` must be constructible and testable on its own,
  // fully independent from `main()`'s Firebase boot sequence.
  testWidgets('MenuarioApp applies the Material 3 dark theme by default', (
    tester,
  ) async {
    final mockAuthService = MockAuthService();
    when(
      () => mockAuthService.authStateChanges,
    ).thenAnswer((_) => const Stream<User?>.empty());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        child: const MenuarioApp(),
      ),
    );
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app.themeMode, ThemeMode.dark);
    expect(app.theme?.useMaterial3, isTrue);
    expect(app.darkTheme?.useMaterial3, isTrue);
    expect(
      app.theme?.colorScheme.primary,
      MenuarioTheme.light.colorScheme.primary,
    );
    expect(
      app.darkTheme?.colorScheme.primary,
      MenuarioTheme.dark.colorScheme.primary,
    );
  });
}
