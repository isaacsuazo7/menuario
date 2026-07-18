import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/theme/app_seed.dart';
import 'package:menuario/src/shared/domain/entities/theme_settings.dart';

void main() {
  group('ThemeSettings.defaults', () {
    test('matches the pre-customization behavior: dark mode', () {
      expect(ThemeSettings.defaults.mode, ThemeMode.dark);
    });

    test('matches the pre-customization behavior: the menuario seed', () {
      expect(ThemeSettings.defaults.seed, menuarioSeed);
    });
  });

  group('ThemeSettings', () {
    test('is a value type: two identical settings are equal', () {
      const a = ThemeSettings(mode: ThemeMode.light, seed: menuarioSeed);
      const b = ThemeSettings(mode: ThemeMode.light, seed: menuarioSeed);

      expect(a, b);
    });

    test('distinguishes settings that differ only by mode', () {
      const dark = ThemeSettings(mode: ThemeMode.dark, seed: menuarioSeed);
      const light = ThemeSettings(mode: ThemeMode.light, seed: menuarioSeed);

      expect(dark, isNot(light));
    });

    test('distinguishes settings that differ only by seed', () {
      const first = ThemeSettings(mode: ThemeMode.dark, seed: menuarioSeed);
      final second = ThemeSettings(
        mode: ThemeMode.dark,
        seed: menuarioSeedOptions.last.color,
      );

      expect(first, isNot(second));
    });

    test('copyWith replaces only the named field', () {
      final updated = ThemeSettings.defaults.copyWith(mode: ThemeMode.system);

      expect(updated.mode, ThemeMode.system);
      expect(updated.seed, ThemeSettings.defaults.seed);
    });
  });
}
