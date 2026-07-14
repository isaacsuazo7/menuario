import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  group('Unit', () {
    test('should expose symbol and dimension', () {
      // Arrange & Act
      const unit = Unit(symbol: 'g', dimension: UnitDimension.mass);

      // Assert
      expect(unit.symbol, 'g');
      expect(unit.dimension, UnitDimension.mass);
    });

    test('two units with the same symbol and dimension should be equal', () {
      // Arrange
      const a = Unit(symbol: 'g', dimension: UnitDimension.mass);
      const b = Unit(symbol: 'g', dimension: UnitDimension.mass);

      // Act & Assert
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('two units with a different symbol should not be equal', () {
      // Arrange
      const a = Unit(symbol: 'g', dimension: UnitDimension.mass);
      const b = Unit(symbol: 'L', dimension: UnitDimension.volume);

      // Act & Assert
      expect(a, isNot(b));
    });

    group('well-known stock units', () {
      test('gram should be the mass dimension with symbol g', () {
        // Act & Assert
        expect(Unit.gram.symbol, 'g');
        expect(Unit.gram.dimension, UnitDimension.mass);
      });

      test('liter should be the volume dimension with symbol L', () {
        // Act & Assert
        expect(Unit.liter.symbol, 'L');
        expect(Unit.liter.dimension, UnitDimension.volume);
      });

      test('count should be the count dimension with symbol u', () {
        // Act & Assert
        expect(Unit.count.symbol, 'u');
        expect(Unit.count.dimension, UnitDimension.count);
      });
    });
  });
}
