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

    test('a quantity-less line round-trips as a null quantity', () {
      // Arrange
      const entity = BomLine(
        recipeId: 'recipe-3',
        ingredientId: 'ingredient-oregano',
      );

      // Act
      final json = BomLineDTO.fromEntity(entity).toJson();
      final result = BomLineDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
      expect(result.quantity, isNull);
      expect(json['quantity'], isNull);
    });

    test('a legacy document with a quantity still decodes exactly as '
        'before — backward compatibility', () {
      // Arrange — the shape every existing Firestore recipe carries today.
      final json = <String, dynamic>{
        'recipeId': 'recipe-legacy',
        'ingredientId': 'ingredient-avena',
        'quantity': <String, dynamic>{
          'value': 8,
          'unitSymbol': 'taza',
          'unitDimension': 'volume',
        },
      };

      // Act
      final result = BomLineDTO.fromJson(json).toEntity();

      // Assert
      expect(
        result.quantity,
        const Quantity(
          value: 8,
          unit: Unit(symbol: 'taza', dimension: UnitDimension.volume),
        ),
      );
    });

    test('an absent quantity key decodes to null instead of throwing', () {
      // Arrange
      final json = <String, dynamic>{
        'recipeId': 'recipe-new',
        'ingredientId': 'ingredient-miel',
      };

      // Act
      final result = BomLineDTO.fromJson(json).toEntity();

      // Assert
      expect(result.quantity, isNull);
      expect(result.ingredientId, 'ingredient-miel');
    });

    test('a schema-drifted, non-map quantity decodes to null instead of '
        'throwing', () {
      // Arrange — a hand-edited or half-written document.
      final json = <String, dynamic>{
        'recipeId': 'recipe-drift',
        'ingredientId': 'ingredient-chia',
        'quantity': 'al gusto',
      };

      // Act
      final result = BomLineDTO.fromJson(json).toEntity();

      // Assert
      expect(result.quantity, isNull);
    });
  });
}
