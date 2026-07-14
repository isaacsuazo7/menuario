import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/data/models/bom_line_dto.dart';
import 'package:menuario/src/shared/domain/entities/bom_line.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  group('BomLineDTO round-trip', () {
    test('survives fromEntity->toJson->fromJson->toEntity', () {
      // Arrange
      const entity = BomLine(
        recipeId: 'recipe-1',
        ingredientId: 'ingredient-1',
        quantity: Quantity(value: 2, unit: Unit.count),
      );

      // Act
      final json = BomLineDTO.fromEntity(entity).toJson();
      final result = BomLineDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
      expect(json['recipeId'], 'recipe-1');
      expect(json['ingredientId'], 'ingredient-1');
      expect(json['quantity'], isA<Map<String, dynamic>>());
    });

    test('a different recipe/ingredient/quantity round-trips exactly', () {
      // Arrange
      const entity = BomLine(
        recipeId: 'recipe-2',
        ingredientId: 'ingredient-9',
        quantity: Quantity(value: 0.5, unit: Unit.liter),
      );

      // Act
      final json = BomLineDTO.fromEntity(entity).toJson();
      final result = BomLineDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
    });
  });
}
