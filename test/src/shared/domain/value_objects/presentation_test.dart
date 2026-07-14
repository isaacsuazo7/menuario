import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/value_objects/presentation.dart';

void main() {
  group('Presentation', () {
    test('loose should be a Presentation with no extra fields', () {
      // Arrange & Act
      const presentation = Presentation.loose();

      // Assert
      expect(presentation, isA<Presentation>());
      expect(presentation, const Presentation.loose());
    });

    test('package should carry yieldQty and label', () {
      // Arrange & Act
      const presentation = Presentation.package(yieldQty: 454, label: 'bolsa');

      // Assert
      expect(presentation, isA<Presentation>());
      expect(
        presentation,
        const Presentation.package(yieldQty: 454, label: 'bolsa'),
      );
    });

    test('counter should be a Presentation with no extra fields', () {
      // Arrange & Act
      const presentation = Presentation.counter();

      // Assert
      expect(presentation, isA<Presentation>());
      expect(presentation, const Presentation.counter());
    });

    test('should support exhaustive pattern matching over all 3 variants', () {
      // Arrange
      const presentations = [
        Presentation.loose(),
        Presentation.package(yieldQty: 15, label: 'cartón'),
        Presentation.counter(),
      ];

      // Act
      final described = presentations.map((presentation) {
        return switch (presentation) {
          PresentationLoose() => 'loose',
          PresentationPackage(:final yieldQty, :final label) =>
            'package($yieldQty $label)',
          PresentationCounter() => 'counter',
        };
      }).toList();

      // Assert
      expect(described, ['loose', 'package(15 cartón)', 'counter']);
    });
  });
}
