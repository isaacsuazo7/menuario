import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/main.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/auth/auth_service.dart';
import 'package:menuario/src/core/theme/theme.dart';
import 'package:menuario/src/features/settings/presentation/providers/theme_settings_provider.dart';
import 'package:menuario/src/shared/domain/entities/theme_settings.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  // No `bootstrapFirebase`/`Firebase.initializeApp` call anywhere in this
  // file — `MenuarioApp` must be constructible and testable on its own,
  // fully independent from `main()`'s Firebase boot sequence.
  Future<MaterialApp> pumpApp(
    WidgetTester tester, {
    ThemeSettings? settings,
  }) async {
    final mockAuthService = MockAuthService();
    when(
      () => mockAuthService.authStateChanges,
    ).thenAnswer((_) => const Stream<User?>.empty());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          if (settings != null)
            themeSettingsProvider.overrideWith(
              () => _StubThemeSettingsController(settings),
            ),
        ],
        child: const MenuarioApp(),
      ),
    );
    await tester.pump();

    return tester.widget<MaterialApp>(find.byType(MaterialApp));
  }

  testWidgets('applies the Material 3 dark theme by default', (tester) async {
    final app = await pumpApp(tester);

    expect(app.themeMode, ThemeMode.dark);
    expect(app.theme?.useMaterial3, isTrue);
    expect(app.darkTheme?.useMaterial3, isTrue);
    expect(
      app.theme?.colorScheme.primary,
      MenuarioTheme.light().colorScheme.primary,
    );
    expect(
      app.darkTheme?.colorScheme.primary,
      MenuarioTheme.dark().colorScheme.primary,
    );
  });

  testWidgets('takes its themeMode from the saved settings', (tester) async {
    final app = await pumpApp(
      tester,
      settings: const ThemeSettings(mode: ThemeMode.light, seed: menuarioSeed),
    );

    expect(app.themeMode, ThemeMode.light);
  });

  testWidgets('honors ThemeMode.system from the saved settings', (
    tester,
  ) async {
    final app = await pumpApp(
      tester,
      settings: const ThemeSettings(mode: ThemeMode.system, seed: menuarioSeed),
    );

    expect(app.themeMode, ThemeMode.system);
  });

  testWidgets('seeds both themes from the saved settings', (tester) async {
    final emerald = menuarioSeedOptions[1].color;

    final app = await pumpApp(
      tester,
      settings: ThemeSettings(mode: ThemeMode.dark, seed: emerald),
    );

    expect(
      app.theme?.colorScheme.primary,
      MenuarioTheme.light(seed: emerald).colorScheme.primary,
    );
    expect(
      app.darkTheme?.colorScheme.primary,
      MenuarioTheme.dark(seed: emerald).colorScheme.primary,
    );
  });
}

/// Serves [settings] synchronously so the pumped app never observes a
/// loading frame — the default-theme fallback is covered separately.
class _StubThemeSettingsController extends ThemeSettingsController {
  _StubThemeSettingsController(this._settings);

  final ThemeSettings _settings;

  @override
  Future<ThemeSettings> build() async => _settings;
}
