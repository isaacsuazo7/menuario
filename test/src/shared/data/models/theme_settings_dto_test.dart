import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/theme/app_seed.dart';
import 'package:menuario/src/shared/data/models/theme_settings_dto.dart';
import 'package:menuario/src/shared/domain/entities/theme_settings.dart';

void main() {
  final emerald = menuarioSeedOptions[1].color;

  group('ThemeSettingsDTO round-trip', () {
    test('fromEntity stores the mode as a string and the seed as an int', () {
      final dto = ThemeSettingsDTO.fromEntity(
        ThemeSettings(mode: ThemeMode.light, seed: emerald),
      );

      expect(dto.mode, 'light');
      expect(dto.seed, emerald.toARGB32());
    });

    test('entity -> DTO -> entity preserves the settings', () {
      final original = ThemeSettings(mode: ThemeMode.system, seed: emerald);

      final restored = ThemeSettingsDTO.fromEntity(original).toEntity();

      expect(restored, original);
    });

    test('entity -> json -> entity preserves the settings', () {
      final original = ThemeSettings(mode: ThemeMode.light, seed: emerald);

      final json = ThemeSettingsDTO.fromEntity(original).toJson();
      final restored = ThemeSettingsDTO.fromJson(json).toEntity();

      expect(restored, original);
    });

    for (final mode in ThemeMode.values) {
      test('round-trips ThemeMode.${mode.name} through JSON', () {
        final original = ThemeSettings(mode: mode, seed: menuarioSeed);

        final json = ThemeSettingsDTO.fromEntity(original).toJson();
        final restored = ThemeSettingsDTO.fromJson(json).toEntity();

        expect(restored.mode, mode);
      });
    }

    for (final option in menuarioSeedOptions) {
      test('round-trips the "${option.label}" seed through JSON', () {
        final original = ThemeSettings(
          mode: ThemeMode.dark,
          seed: option.color,
        );

        final json = ThemeSettingsDTO.fromEntity(original).toJson();
        final restored = ThemeSettingsDTO.fromJson(json).toEntity();

        expect(restored.seed, option.color);
      });
    }
  });

  group('ThemeSettingsDTO degrades gracefully', () {
    test('falls back to the default mode on an unknown mode string', () {
      final restored = ThemeSettingsDTO.fromJson({
        'mode': 'neon',
        'seed': emerald.toARGB32(),
      }).toEntity();

      expect(restored.mode, ThemeSettings.defaults.mode);
      expect(restored.seed, emerald, reason: 'a valid seed must survive');
    });

    test('falls back to the default seed on an uncurated seed value', () {
      const uncurated = Color(0xFF123456);

      final restored = ThemeSettingsDTO.fromJson({
        'mode': 'light',
        'seed': uncurated.toARGB32(),
      }).toEntity();

      expect(restored.seed, ThemeSettings.defaults.seed);
      expect(restored.mode, ThemeMode.light, reason: 'a valid mode survives');
    });

    test('falls back to the defaults on an empty document', () {
      final restored = ThemeSettingsDTO.fromJson(
        const <String, dynamic>{},
      ).toEntity();

      expect(restored, ThemeSettings.defaults);
    });

    test('falls back to the defaults on null values', () {
      final restored = ThemeSettingsDTO.fromJson({
        'mode': null,
        'seed': null,
      }).toEntity();

      expect(restored, ThemeSettings.defaults);
    });

    test('does not throw on wrong-typed values, it falls back', () {
      final restored = ThemeSettingsDTO.fromJson({
        'mode': 42,
        'seed': 'not-an-int',
      }).toEntity();

      expect(restored, ThemeSettings.defaults);
    });

    test('does not throw on a nested/structural type mismatch', () {
      final restored = ThemeSettingsDTO.fromJson({
        'mode': <String, dynamic>{'value': 'dark'},
        'seed': <int>[1, 2, 3],
      }).toEntity();

      expect(restored, ThemeSettings.defaults);
    });
  });
}
