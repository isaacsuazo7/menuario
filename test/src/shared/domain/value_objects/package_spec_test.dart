import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/value_objects/package_spec.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  group('PackageSpec', () {
    test('a packageBase spec carries label, yieldQty and baseDimension '
        '(leche bolsa=1L)', () {
      // Arrange & Act
      const leche = PackageSpec(
        label: 'bolsa',
        yieldQty: 1,
        baseDimension: Unit.liter,
      );

      // Assert
      expect(leche.label, 'bolsa');
      expect(leche.yieldQty, 1);
      expect(leche.baseDimension, Unit.liter);
    });

    test('a packageAbstract spec has no yieldQty or baseDimension '
        '(lechuga bolsa)', () {
      // Arrange & Act
      const lechuga = PackageSpec(label: 'bolsa');

      // Assert
      expect(lechuga.label, 'bolsa');
      expect(lechuga.yieldQty, isNull);
      expect(lechuga.baseDimension, isNull);
    });

    test('two specs with the same fields are equal', () {
      // Arrange
      const a = PackageSpec(
        label: 'cartón',
        yieldQty: 15,
        baseDimension: Unit.count,
      );
      const b = PackageSpec(
        label: 'cartón',
        yieldQty: 15,
        baseDimension: Unit.count,
      );

      // Act & Assert
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('copyWith replaces only the given field', () {
      // Arrange
      const original = PackageSpec(label: 'bolsa', yieldQty: 1);

      // Act
      final updated = original.copyWith(yieldQty: 2);

      // Assert
      expect(updated.label, 'bolsa');
      expect(updated.yieldQty, 2);
    });
  });

  group('PackageSpec.effectiveYieldQty', () {
    test('multiplies the inner level when innerQty and innerCount are both '
        'set (salmas caja = 8 bolsas x 3 u)', () {
      // Arrange & Act
      const salmas = PackageSpec(
        label: 'caja',
        innerLabel: 'bolsa',
        innerQty: 3,
        innerCount: 8,
      );

      // Assert
      expect(salmas.effectiveYieldQty, 24);
    });

    test('the inner product wins over a stale hand-computed yieldQty', () {
      // Arrange & Act
      const galletas = PackageSpec(
        label: 'caja',
        yieldQty: 99,
        innerLabel: 'bolsa',
        innerQty: 2,
        innerCount: 10,
      );

      // Assert
      expect(galletas.effectiveYieldQty, 20);
    });

    test('falls back to yieldQty when no inner level is described', () {
      // Arrange & Act
      const legacy = PackageSpec(label: 'caja', yieldQty: 24);

      // Assert
      expect(legacy.effectiveYieldQty, 24);
    });

    test('falls back to yieldQty when only one inner field is set', () {
      // Arrange & Act
      const halfFilled = PackageSpec(
        label: 'caja',
        yieldQty: 24,
        innerLabel: 'bolsa',
        innerQty: 3,
      );

      // Assert
      expect(halfFilled.effectiveYieldQty, 24);
    });

    test('is null when neither yieldQty nor a complete inner level is set', () {
      // Arrange & Act
      const abstract = PackageSpec(label: 'bolsa');

      // Assert
      expect(abstract.effectiveYieldQty, isNull);
    });
  });

  group('PackageSpec.innerBreakdown', () {
    test('renders the two-level breakdown, pluralizing the inner label', () {
      // Arrange & Act
      const salmas = PackageSpec(
        label: 'caja',
        innerLabel: 'bolsa',
        innerQty: 3,
        innerCount: 8,
      );

      // Assert
      expect(salmas.innerBreakdown, '8 bolsas × 3 u');
    });

    test('keeps the inner label singular for a single inner pack', () {
      // Arrange & Act
      const single = PackageSpec(
        label: 'caja',
        innerLabel: 'bolsa',
        innerQty: 3,
        innerCount: 1,
      );

      // Assert
      expect(single.innerBreakdown, '1 bolsa × 3 u');
    });

    test('defaults the inner label when only the quantities are known', () {
      // Arrange & Act
      const unlabeled = PackageSpec(label: 'caja', innerQty: 2, innerCount: 10);

      // Assert
      expect(unlabeled.innerBreakdown, '10 paquetes × 2 u');
    });

    test('is null for a single-level package', () {
      // Arrange & Act
      const legacy = PackageSpec(label: 'caja', yieldQty: 24);

      // Assert
      expect(legacy.innerBreakdown, isNull);
    });
  });
}
