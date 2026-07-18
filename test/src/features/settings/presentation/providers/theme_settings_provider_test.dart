import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/core/theme/app_seed.dart';
import 'package:menuario/src/features/settings/presentation/providers/theme_settings_provider.dart';
import 'package:menuario/src/shared/data/repositories/theme_settings_repository_impl.dart';
import 'package:menuario/src/shared/domain/entities/theme_settings.dart';
import 'package:menuario/src/shared/domain/repositories/theme_settings_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockThemeSettingsRepository extends Mock
    implements ThemeSettingsRepository {}

void main() {
  late MockThemeSettingsRepository mockRepository;

  final emerald = menuarioSeedOptions[1].color;
  final saved = ThemeSettings(mode: ThemeMode.light, seed: emerald);
  final failure = Failure(message: 'no se pudo guardar', code: 'save-fail');

  setUpAll(() {
    registerFallbackValue(ThemeSettings.defaults);
  });

  setUp(() {
    mockRepository = MockThemeSettingsRepository();
  });

  ProviderContainer makeContainer({String? uid = 'uid-A'}) {
    final container = ProviderContainer(
      overrides: [
        currentUidProvider.overrideWithValue(uid),
        themeSettingsRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('build', () {
    test('falls back to the defaults when no document exists', () async {
      when(
        () => mockRepository.getActive(),
      ).thenAnswer((_) async => const Right(null));

      final container = makeContainer();

      final settings = await container.read(themeSettingsProvider.future);

      expect(settings, ThemeSettings.defaults);
    });

    test('loads the saved settings when a document exists', () async {
      when(
        () => mockRepository.getActive(),
      ).thenAnswer((_) async => Right(saved));

      final container = makeContainer();

      final settings = await container.read(themeSettingsProvider.future);

      expect(settings, saved);
    });

    test('resolves to the defaults while signed out', () async {
      final container = makeContainer(uid: null);

      final settings = await container.read(themeSettingsProvider.future);

      expect(settings, ThemeSettings.defaults);
    });

    test('never reads the repository while signed out', () async {
      final container = makeContainer(uid: null);

      await container.read(themeSettingsProvider.future);

      verifyNever(() => mockRepository.getActive());
    });

    test('throws FailureException when the load fails', () async {
      when(
        () => mockRepository.getActive(),
      ).thenAnswer((_) async => Left(failure));

      final container = makeContainer();

      expect(
        () => container.read(themeSettingsProvider.future),
        throwsA(isA<FailureException>()),
      );
    });
  });

  group('setMode', () {
    test('persists the new mode, keeping the seed', () async {
      when(
        () => mockRepository.getActive(),
      ).thenAnswer((_) async => Right(saved));
      when(
        () => mockRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      final container = makeContainer();
      await container.read(themeSettingsProvider.future);

      final result = await container
          .read(themeSettingsProvider.notifier)
          .setMode(ThemeMode.system);

      expect(result, isNull);
      verify(
        () => mockRepository.save(
          ThemeSettings(mode: ThemeMode.system, seed: emerald),
        ),
      ).called(1);
      expect(
        container.read(themeSettingsProvider).value,
        ThemeSettings(mode: ThemeMode.system, seed: emerald),
      );
    });

    test('applies the new mode optimistically before persistence', () async {
      when(
        () => mockRepository.getActive(),
      ).thenAnswer((_) async => Right(saved));
      final completer = Completer<Either<Failure, void>>();
      when(
        () => mockRepository.save(any()),
      ).thenAnswer((_) => completer.future);

      final container = makeContainer();
      await container.read(themeSettingsProvider.future);

      final pending = container
          .read(themeSettingsProvider.notifier)
          .setMode(ThemeMode.system);

      expect(
        container.read(themeSettingsProvider).value?.mode,
        ThemeMode.system,
        reason: 'the UI must repaint before Firestore acknowledges',
      );

      completer.complete(const Right(null));
      await pending;
    });

    test('rolls back and returns the Failure when persistence fails', () async {
      when(
        () => mockRepository.getActive(),
      ).thenAnswer((_) async => Right(saved));
      when(
        () => mockRepository.save(any()),
      ).thenAnswer((_) async => Left(failure));

      final container = makeContainer();
      await container.read(themeSettingsProvider.future);

      final result = await container
          .read(themeSettingsProvider.notifier)
          .setMode(ThemeMode.system);

      expect(result, failure);
      expect(container.read(themeSettingsProvider).value, saved);
    });
  });

  group('setSeed', () {
    test('persists the new seed, keeping the mode', () async {
      when(
        () => mockRepository.getActive(),
      ).thenAnswer((_) async => Right(saved));
      when(
        () => mockRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      final container = makeContainer();
      await container.read(themeSettingsProvider.future);

      final result = await container
          .read(themeSettingsProvider.notifier)
          .setSeed(menuarioSeed);

      expect(result, isNull);
      verify(
        () => mockRepository.save(
          const ThemeSettings(mode: ThemeMode.light, seed: menuarioSeed),
        ),
      ).called(1);
      expect(container.read(themeSettingsProvider).value?.seed, menuarioSeed);
    });

    test(
      'a failed save never rolls back over a newer successful one',
      () async {
        when(
          () => mockRepository.getActive(),
        ).thenAnswer((_) async => Right(saved));

        final violet = menuarioSeedOptions[3].color;
        final firstSave = Completer<Either<Failure, void>>();
        final secondSave = Completer<Either<Failure, void>>();
        when(() => mockRepository.save(any())).thenAnswer((invocation) {
          final settings =
              invocation.positionalArguments.first as ThemeSettings;
          return settings.seed == menuarioSeed
              ? firstSave.future
              : secondSave.future;
        });

        final container = makeContainer();
        await container.read(themeSettingsProvider.future);
        final notifier = container.read(themeSettingsProvider.notifier);

        // Two rapid taps: the second lands while the first is still in flight,
        // then resolves successfully BEFORE the first comes back failed.
        final first = notifier.setSeed(menuarioSeed);
        final second = notifier.setSeed(violet);

        secondSave.complete(const Right(null));
        expect(await second, isNull);

        firstSave.complete(Left(failure));
        expect(await first, failure);

        expect(
          container.read(themeSettingsProvider).value?.seed,
          violet,
          reason: 'the superseded failure must not discard the persisted seed',
        );
      },
    );

    test('rolls back and returns the Failure when persistence fails', () async {
      when(
        () => mockRepository.getActive(),
      ).thenAnswer((_) async => Right(saved));
      when(
        () => mockRepository.save(any()),
      ).thenAnswer((_) async => Left(failure));

      final container = makeContainer();
      await container.read(themeSettingsProvider.future);

      final result = await container
          .read(themeSettingsProvider.notifier)
          .setSeed(menuarioSeed);

      expect(result, failure);
      expect(container.read(themeSettingsProvider).value, saved);
    });
  });
}
