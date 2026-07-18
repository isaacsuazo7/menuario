import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/theme/app_seed.dart';
import 'package:menuario/src/features/settings/presentation/screens/appearance_screen.dart';
import 'package:menuario/src/shared/data/repositories/theme_settings_repository_impl.dart';
import 'package:menuario/src/shared/domain/entities/theme_settings.dart';
import 'package:menuario/src/shared/domain/repositories/theme_settings_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockThemeSettingsRepository extends Mock
    implements ThemeSettingsRepository {}

void main() {
  late MockThemeSettingsRepository mockRepository;

  final emerald = menuarioSeedOptions[1].color;

  setUpAll(() {
    registerFallbackValue(ThemeSettings.defaults);
  });

  setUp(() {
    mockRepository = MockThemeSettingsRepository();
    when(
      () => mockRepository.save(any()),
    ).thenAnswer((_) async => const Right(null));
  });

  Future<void> pumpScreen(WidgetTester tester, {ThemeSettings? saved}) async {
    when(
      () => mockRepository.getActive(),
    ).thenAnswer((_) async => Right(saved));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUidProvider.overrideWithValue('uid-A'),
          themeSettingsRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(home: AppearanceScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('titles the screen "Apariencia"', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Apariencia'), findsOneWidget);
  });

  testWidgets('offers the three theme modes in Spanish', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Claro'), findsOneWidget);
    expect(find.text('Oscuro'), findsOneWidget);
    expect(find.text('Sistema'), findsOneWidget);
  });

  testWidgets('offers every curated seed, and only those', (tester) async {
    await pumpScreen(tester);

    for (final option in menuarioSeedOptions) {
      expect(
        find.byKey(ValueKey('seed-${option.color.toARGB32()}')),
        findsOneWidget,
        reason: 'missing the "${option.label}" seed',
      );
    }
    expect(
      find.byKey(const ValueKey('seed-4278255456')),
      findsNothing,
      reason: 'no uncurated seed may be offered',
    );
  });

  testWidgets('persists the picked mode', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Claro'));
    await tester.pumpAndSettle();

    verify(
      () => mockRepository.save(
        const ThemeSettings(mode: ThemeMode.light, seed: menuarioSeed),
      ),
    ).called(1);
  });

  testWidgets('persists the picked seed', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byKey(ValueKey('seed-${emerald.toARGB32()}')));
    await tester.pumpAndSettle();

    verify(
      () => mockRepository.save(
        ThemeSettings(mode: ThemeMode.dark, seed: emerald),
      ),
    ).called(1);
  });

  testWidgets('keeps the mode when only the seed changes', (tester) async {
    await pumpScreen(
      tester,
      saved: const ThemeSettings(mode: ThemeMode.system, seed: menuarioSeed),
    );

    await tester.tap(find.byKey(ValueKey('seed-${emerald.toARGB32()}')));
    await tester.pumpAndSettle();

    verify(
      () => mockRepository.save(
        ThemeSettings(mode: ThemeMode.system, seed: emerald),
      ),
    ).called(1);
  });

  testWidgets('marks the saved seed as selected', (tester) async {
    await pumpScreen(
      tester,
      saved: ThemeSettings(mode: ThemeMode.dark, seed: emerald),
    );

    expect(
      find.descendant(
        of: find.byKey(ValueKey('seed-${emerald.toARGB32()}')),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('surfaces a failure message without applying the change', (
    tester,
  ) async {
    when(() => mockRepository.save(any())).thenAnswer(
      (_) async => Left(Failure(message: 'Sin conexión', code: 'unavailable')),
    );

    await pumpScreen(tester);

    await tester.tap(find.byKey(ValueKey('seed-${emerald.toARGB32()}')));
    await tester.pumpAndSettle();

    expect(find.text('Sin conexión'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(ValueKey('seed-${menuarioSeed.toARGB32()}')),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
      reason: 'a failed write must roll back to the previous seed',
    );
  });

  testWidgets('surfaces a load failure with a retry affordance', (
    tester,
  ) async {
    when(() => mockRepository.getActive()).thenAnswer(
      (_) async => Left(Failure(message: 'Falló la carga', code: 'boom')),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUidProvider.overrideWithValue('uid-A'),
          themeSettingsRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(home: AppearanceScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Falló la carga'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });
}
