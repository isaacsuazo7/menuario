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
}
