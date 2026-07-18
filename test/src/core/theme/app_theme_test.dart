import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/theme/theme.dart';

void main() {
  group('MenuarioTheme', () {
    test('dark builds a Material 3 ThemeData with a non-null colorScheme', () {
      final theme = MenuarioTheme.dark();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme, isNotNull);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('light builds a Material 3 ThemeData with a non-null colorScheme', () {
      final theme = MenuarioTheme.light();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme, isNotNull);
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test('dark and light default to the menuarioSeed palette', () {
      final darkScheme = ColorScheme.fromSeed(
        seedColor: menuarioSeed,
        brightness: Brightness.dark,
      );
      final lightScheme = ColorScheme.fromSeed(
        seedColor: menuarioSeed,
        brightness: Brightness.light,
      );

      expect(MenuarioTheme.dark().colorScheme.primary, darkScheme.primary);
      expect(MenuarioTheme.light().colorScheme.primary, lightScheme.primary);
    });

    test('the category-colors ThemeExtension resolves on both themes', () {
      final darkExtension = MenuarioTheme.dark()
          .extension<MenuarioCategoryColors>();
      final lightExtension = MenuarioTheme.light()
          .extension<MenuarioCategoryColors>();

      expect(darkExtension, isNotNull);
      expect(lightExtension, isNotNull);
    });

    test('the coverage-colors ThemeExtension resolves on both themes', () {
      final darkExtension = MenuarioTheme.dark()
          .extension<MenuarioCoverageColors>();
      final lightExtension = MenuarioTheme.light()
          .extension<MenuarioCoverageColors>();

      expect(darkExtension, isNotNull);
      expect(lightExtension, isNotNull);
    });
  });

  group('MenuarioTheme seeding', () {
    final emerald = menuarioSeedOptions[1].color;

    test('dark derives its palette from the supplied seed', () {
      final expected = ColorScheme.fromSeed(
        seedColor: emerald,
        brightness: Brightness.dark,
      );

      final theme = MenuarioTheme.dark(seed: emerald);

      expect(theme.colorScheme.primary, expected.primary);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('light derives its palette from the supplied seed', () {
      final expected = ColorScheme.fromSeed(
        seedColor: emerald,
        brightness: Brightness.light,
      );

      final theme = MenuarioTheme.light(seed: emerald);

      expect(theme.colorScheme.primary, expected.primary);
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test('a different seed yields a different primary', () {
      expect(
        MenuarioTheme.dark(seed: emerald).colorScheme.primary,
        isNot(MenuarioTheme.dark(seed: menuarioSeed).colorScheme.primary),
      );
    });

    test('every curated seed builds both brightnesses', () {
      for (final option in menuarioSeedOptions) {
        expect(
          MenuarioTheme.dark(seed: option.color).colorScheme.brightness,
          Brightness.dark,
          reason: 'dark failed for "${option.label}"',
        );
        expect(
          MenuarioTheme.light(seed: option.color).colorScheme.brightness,
          Brightness.light,
          reason: 'light failed for "${option.label}"',
        );
      }
    });

    test('both theme extensions survive a custom seed', () {
      final theme = MenuarioTheme.dark(seed: emerald);

      expect(theme.extension<MenuarioCategoryColors>(), isNotNull);
      expect(theme.extension<MenuarioCoverageColors>(), isNotNull);
    });

    test('the domain color extensions stay brightness-derived, never seeded: '
        'red must keep reading as an alarm under any palette', () {
      final indigo = MenuarioTheme.dark(seed: menuarioSeed);
      final emeraldTheme = MenuarioTheme.dark(seed: emerald);

      expect(
        emeraldTheme.extension<MenuarioCoverageColors>(),
        indigo.extension<MenuarioCoverageColors>(),
      );
      expect(
        emeraldTheme.extension<MenuarioCategoryColors>(),
        indigo.extension<MenuarioCategoryColors>(),
      );
    });
  });
}
