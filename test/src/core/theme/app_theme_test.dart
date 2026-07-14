import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/theme/theme.dart';

void main() {
  group('MenuarioTheme', () {
    test('dark builds a Material 3 ThemeData with a non-null colorScheme', () {
      final theme = MenuarioTheme.dark;

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme, isNotNull);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('light builds a Material 3 ThemeData with a non-null colorScheme', () {
      final theme = MenuarioTheme.light;

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme, isNotNull);
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test('dark and light derive their colorScheme from the same seed', () {
      final darkScheme = ColorScheme.fromSeed(
        seedColor: menuarioSeed,
        brightness: Brightness.dark,
      );
      final lightScheme = ColorScheme.fromSeed(
        seedColor: menuarioSeed,
        brightness: Brightness.light,
      );

      expect(MenuarioTheme.dark.colorScheme.primary, darkScheme.primary);
      expect(MenuarioTheme.light.colorScheme.primary, lightScheme.primary);
    });

    test('the category-colors ThemeExtension resolves on both themes', () {
      final darkExtension = MenuarioTheme.dark
          .extension<MenuarioCategoryColors>();
      final lightExtension = MenuarioTheme.light
          .extension<MenuarioCategoryColors>();

      expect(darkExtension, isNotNull);
      expect(lightExtension, isNotNull);
    });
  });
}
