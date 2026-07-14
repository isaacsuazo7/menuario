import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/data/models/ingredient_dto.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_kind.dart';

void main() {
  group('IngredientDTO round-trip', () {
    test('a bulk ingredient survives fromEntity->toJson->fromJson->toEntity, '
        'id injected from doc id and absent from the map', () {
      // Arrange
      const entity = Ingredient(
        id: 'ingredient-avena',
        name: 'Avena',
        emoji: '🌾',
        category: Category.cereal,
        measurementKind: MeasurementKind.bulk,
        booleanTracked: false,
        conversionFactor: 85,
      );

      // Act
      final json = IngredientDTO.fromEntity(entity).toJson();
      final result = IngredientDTO.fromJson(
        json,
      ).toEntity(id: 'ingredient-avena');

      // Assert
      expect(result, entity);
      expect(result.emoji, '🌾');
      expect(json.containsKey('id'), isFalse);
      expect(json['category'], 'cereal');
      expect(json['measurementKind'], 'bulk');
    });

    test('a unit-tracked, boolean-tracked ingredient with no conversion '
        'factor round-trips exactly', () {
      // Arrange
      const entity = Ingredient(
        id: 'ingredient-comino',
        name: 'Comino',
        category: Category.condimento,
        measurementKind: MeasurementKind.unit,
        booleanTracked: true,
        conversionFactor: null,
      );

      // Act
      final json = IngredientDTO.fromEntity(entity).toJson();
      final result = IngredientDTO.fromJson(
        json,
      ).toEntity(id: 'ingredient-comino');

      // Assert
      expect(result, entity);
      expect(result.emoji, isNull);
      expect(json['conversionFactor'], isNull);
      expect(json['booleanTracked'], isTrue);
    });
  });
}
