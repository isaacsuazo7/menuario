import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/data/models/recipe_dto.dart';
import 'package:menuario/src/shared/domain/entities/bom_line.dart';
import 'package:menuario/src/shared/domain/entities/recipe.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  group('RecipeDTO round-trip', () {
    test('a recipe with ordered BomLines survives '
        'fromEntity->toJson->fromJson->toEntity, id injected from doc id '
        'and absent from the map', () {
      // Arrange
      const entity = Recipe(
        id: 'recipe-1',
        name: 'Avena con leche',
        emoji: '🥣',
        bomLines: [
          BomLine(
            recipeId: 'recipe-1',
            ingredientId: 'ingredient-avena',
            quantity: Quantity(value: 1, unit: Unit.count),
          ),
          BomLine(
            recipeId: 'recipe-1',
            ingredientId: 'ingredient-leche',
            quantity: Quantity(value: 250, unit: Unit.liter),
          ),
        ],
      );

      // Act
      final json = RecipeDTO.fromEntity(entity).toJson();
      final result = RecipeDTO.fromJson(json).toEntity(id: 'recipe-1');

      // Assert
      expect(result, entity);
      expect(result.bomLines.map((b) => b.ingredientId).toList(), [
        'ingredient-avena',
        'ingredient-leche',
      ]);
      expect(result.emoji, '🥣');
      expect(json.containsKey('id'), isFalse);
    });

    test('a recipe with no BomLines round-trips to an empty list', () {
      // Arrange
      const entity = Recipe(id: 'recipe-empty', name: 'Vacía', bomLines: []);

      // Act
      final json = RecipeDTO.fromEntity(entity).toJson();
      final result = RecipeDTO.fromJson(json).toEntity(id: 'recipe-empty');

      // Assert
      expect(result, entity);
      expect(result.bomLines, isEmpty);
      expect(result.emoji, isNull);
    });
  });
}
