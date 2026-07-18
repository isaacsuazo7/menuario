import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/presentation/bom_quantity_label.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  group('bomQuantityLabel', () {
    test('renders value and unit symbol for a measured line', () {
      // Arrange
      const quantity = Quantity(value: 2, unit: Unit.count);

      // Act
      final label = bomQuantityLabel(quantity);

      // Assert
      expect(label, '2 u');
    });

    test('renders "Al gusto" for a quantity-less line', () {
      // Act
      final label = bomQuantityLabel(null);

      // Assert
      expect(label, 'Al gusto');
    });
  });
}
