import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/data/models/quantity_dto.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  group('QuantityDTO round-trip', () {
    test('a mass Quantity survives fromEntity->toJson->fromJson->toEntity', () {
      // Arrange
      const entity = Quantity(value: 85, unit: Unit.gram);

      // Act
      final json = QuantityDTO.fromEntity(entity).toJson();
      final result = QuantityDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
      expect(json['unitSymbol'], 'g');
      expect(json['unitDimension'], 'mass');
    });

    test('a count Quantity with a custom unit round-trips exactly', () {
      // Arrange
      const entity = Quantity(
        value: 1.5,
        unit: Unit(symbol: 'taza', dimension: UnitDimension.volume),
      );

      // Act
      final json = QuantityDTO.fromEntity(entity).toJson();
      final result = QuantityDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
      expect(json['unitSymbol'], 'taza');
      expect(json['unitDimension'], 'volume');
    });
  });
}
