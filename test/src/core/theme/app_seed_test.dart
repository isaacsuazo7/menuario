import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/theme/app_seed.dart';

void main() {
  group('menuarioSeedOptions', () {
    test('is a closed, curated list of 6 to 8 seeds', () {
      expect(menuarioSeedOptions.length, inInclusiveRange(6, 8));
    });

    test('contains the default menuarioSeed', () {
      final colors = menuarioSeedOptions.map((option) => option.color);

      expect(colors, contains(menuarioSeed));
    });

    test('leads with the default menuarioSeed', () {
      expect(menuarioSeedOptions.first.color, menuarioSeed);
    });

    test('exposes a unique color per option', () {
      final colors = menuarioSeedOptions.map((option) => option.color).toSet();

      expect(colors, hasLength(menuarioSeedOptions.length));
    });

    test('exposes a non-empty label per option', () {
      for (final option in menuarioSeedOptions) {
        expect(option.label, isNotEmpty);
      }
    });

    test('exposes a unique label per option', () {
      final labels = menuarioSeedOptions.map((option) => option.label).toSet();

      expect(labels, hasLength(menuarioSeedOptions.length));
    });
  });

  group('menuarioSeedFor', () {
    test('resolves a curated seed from its 32-bit ARGB value', () {
      final resolved = menuarioSeedFor(menuarioSeed.toARGB32());

      expect(resolved, menuarioSeed);
    });

    test('returns null for a color outside the curated list', () {
      const uncurated = Color(0xFF123456);

      expect(menuarioSeedFor(uncurated.toARGB32()), isNull);
    });

    test('returns null for a null value', () {
      expect(menuarioSeedFor(null), isNull);
    });
  });
}
