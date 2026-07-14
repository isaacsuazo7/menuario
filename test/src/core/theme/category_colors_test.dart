import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/theme/category_colors.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  group('MenuarioCategoryColors.colorFor', () {
    const fallback = Color(0xFF00FF00);
    final palette = MenuarioCategoryColors.light();

    test('returns the palette color for a known category', () {
      final result = palette.colorFor(Category.proteina, fallback: fallback);

      expect(result, palette.proteina);
      expect(result, isNot(fallback));
    });

    test('returns the passed fallback for Category.otro', () {
      final result = palette.colorFor(Category.otro, fallback: fallback);

      expect(result, fallback);
    });
  });
}
