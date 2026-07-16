import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/value_objects/mass.dart';
import 'package:menuario/src/shared/domain/value_objects/stock_lens.dart';

void main() {
  group('StockLens', () {
    test('exposes label, canonicalPerUnit and allowsDecimal', () {
      // Arrange & Act
      const lb = StockLens(
        label: 'lb',
        canonicalPerUnit: Mass.gramsPerPound,
        allowsDecimal: true,
      );

      // Assert
      expect(lb.label, 'lb');
      expect(lb.canonicalPerUnit, Mass.gramsPerPound);
      expect(lb.allowsDecimal, isTrue);
    });

    group('toCanonical', () {
      test('converts pounds to grams (800 g pinned: 1.7638... lb * '
          '453.59237 ≈ 800 g)', () {
        // Arrange
        const lb = StockLens(
          label: 'lb',
          canonicalPerUnit: Mass.gramsPerPound,
          allowsDecimal: true,
        );

        // Act
        final grams = lb.toCanonical(1.75);

        // Assert — 1.75 lb -> 793.8 g (pinned)
        expect(grams, closeTo(793.8, 0.05));
      });

      test('converts packages to a base-dimension value via yieldQty '
          '(leche 3.5 bolsas, yieldQty 1 -> 3.5 L)', () {
        // Arrange
        const bolsa = StockLens(
          label: 'bolsa',
          canonicalPerUnit: 1,
          allowsDecimal: true,
        );

        // Act
        final liters = bolsa.toCanonical(3.5);

        // Assert
        expect(liters, 3.5);
      });
    });

    group('fromCanonical', () {
      test('converts grams to pounds (800 g -> 1.76 lb pinned)', () {
        // Arrange
        const lb = StockLens(
          label: 'lb',
          canonicalPerUnit: Mass.gramsPerPound,
          allowsDecimal: true,
        );

        // Act
        final pounds = lb.fromCanonical(800);

        // Assert — 800 / 453.59237 ≈ 1.7637 (rounds to 1.76 lb on display)
        expect(pounds, closeTo(1.7637, 0.001));
      });

      test('converts a base count into cartones (huevo yieldQty 15, '
          '7 u -> 0.4667 cartón, displays 0.47)', () {
        // Arrange
        const carton = StockLens(
          label: 'cartón',
          canonicalPerUnit: 15,
          allowsDecimal: true,
        );

        // Act
        final cartones = carton.fromCanonical(7);

        // Assert
        expect(cartones, closeTo(0.4667, 0.001));
      });
    });

    test('round-trips toCanonical(fromCanonical(s)) ≈ s (g/lb factor)', () {
      // Arrange
      const lb = StockLens(
        label: 'lb',
        canonicalPerUnit: Mass.gramsPerPound,
        allowsDecimal: true,
      );

      // Act
      final roundTripped = lb.toCanonical(lb.fromCanonical(800));

      // Assert
      expect(roundTripped, closeTo(800, 1e-9));
    });

    test('round-trips toCanonical(fromCanonical(s)) ≈ s (paquete/base '
        'yieldQty factor)', () {
      // Arrange
      const carton = StockLens(
        label: 'cartón',
        canonicalPerUnit: 15,
        allowsDecimal: true,
      );

      // Act
      final roundTripped = carton.toCanonical(carton.fromCanonical(7));

      // Assert
      expect(roundTripped, closeTo(7, 1e-9));
    });

    test('two lenses with the same fields are equal', () {
      // Arrange
      const a = StockLens(
        label: 'u',
        canonicalPerUnit: 1,
        allowsDecimal: false,
      );
      const b = StockLens(
        label: 'u',
        canonicalPerUnit: 1,
        allowsDecimal: false,
      );

      // Act & Assert
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });
}
