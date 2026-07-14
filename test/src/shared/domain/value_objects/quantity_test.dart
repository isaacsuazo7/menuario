import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  group('Quantity', () {
    test('should expose value and unit', () {
      // Arrange & Act
      const quantity = Quantity(value: 85, unit: Unit.gram);

      // Assert
      expect(quantity.value, 85);
      expect(quantity.unit, Unit.gram);
    });

    group('operator +', () {
      test('should add two quantities of the same unit', () {
        // Arrange
        const a = Quantity(value: 100, unit: Unit.gram);
        const b = Quantity(value: 50, unit: Unit.gram);

        // Act
        final result = a + b;

        // Assert
        expect(result, const Quantity(value: 150, unit: Unit.gram));
      });

      test('should throw ArgumentError when units differ', () {
        // Arrange
        const a = Quantity(value: 100, unit: Unit.gram);
        const b = Quantity(value: 1, unit: Unit.liter);

        // Act & Assert
        expect(() => a + b, throwsArgumentError);
      });
    });

    group('operator -', () {
      test('should subtract two quantities of the same unit', () {
        // Arrange
        const a = Quantity(value: 100, unit: Unit.gram);
        const b = Quantity(value: 30, unit: Unit.gram);

        // Act
        final result = a - b;

        // Assert
        expect(result, const Quantity(value: 70, unit: Unit.gram));
      });

      test('should throw ArgumentError when units differ', () {
        // Arrange
        const a = Quantity(value: 100, unit: Unit.gram);
        const b = Quantity(value: 1, unit: Unit.count);

        // Act & Assert
        expect(() => a - b, throwsArgumentError);
      });
    });

    group('operator *', () {
      test('should scale the value by a scalar factor', () {
        // Arrange
        const quantity = Quantity(value: 2, unit: Unit.gram);

        // Act
        final result = quantity * 4;

        // Assert
        expect(result, const Quantity(value: 8, unit: Unit.gram));
      });
    });
  });
}
