import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/theme/coverage_colors.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  group('MenuarioCoverageColors.colorFor', () {
    final palette = MenuarioCoverageColors.light();

    test('cubierto resolves to the palette green', () {
      expect(palette.colorFor(CoverageStatus.cubierto), palette.cubierto);
    });

    test('justo resolves to the palette amber', () {
      expect(palette.colorFor(CoverageStatus.justo), palette.justo);
    });

    test('falta resolves to the palette red', () {
      expect(palette.colorFor(CoverageStatus.falta), palette.falta);
    });

    test('neutral resolves to the palette neutral (no tint)', () {
      expect(palette.colorFor(CoverageStatus.neutral), palette.neutral);
    });

    test('dark and light paletes are distinct instances tuned per '
        'brightness', () {
      final dark = MenuarioCoverageColors.dark();
      final light = MenuarioCoverageColors.light();

      expect(dark.cubierto, isNot(light.cubierto));
      expect(dark.falta, isNot(light.falta));
    });

    test('fromBrightness picks dark for Brightness.dark and light for '
        'Brightness.light', () {
      expect(
        MenuarioCoverageColors.fromBrightness(Brightness.dark).cubierto,
        MenuarioCoverageColors.dark().cubierto,
      );
      expect(
        MenuarioCoverageColors.fromBrightness(Brightness.light).cubierto,
        MenuarioCoverageColors.light().cubierto,
      );
    });
  });
}
