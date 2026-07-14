import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/entities/bom_line.dart';
import 'package:menuario/src/shared/domain/entities/recipe.dart';
import 'package:menuario/src/shared/domain/value_objects/meal_type.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  group('Recipe', () {
    const taza = Unit(symbol: 'taza', dimension: UnitDimension.volume);

    test('should carry an id, a name and an ordered list of BomLines', () {
      // Arrange
      const firstLine = BomLine(
        recipeId: 'recipe-avena',
        ingredientId: 'ingredient-avena',
        quantity: Quantity(value: 8, unit: taza),
      );
      const secondLine = BomLine(
        recipeId: 'recipe-avena',
        ingredientId: 'ingredient-leche',
        quantity: Quantity(value: 2, unit: taza),
      );

      // Act
      const recipe = Recipe(
        id: 'recipe-avena',
        name: 'Avena con leche',
        bomLines: [firstLine, secondLine],
      );

      // Assert
      expect(recipe.id, 'recipe-avena');
      expect(recipe.name, 'Avena con leche');
      expect(recipe.bomLines, [firstLine, secondLine]);
    });

    test('should default mealType to null when not provided', () {
      // Act
      const recipe = Recipe(id: 'recipe-avena', name: 'Avena', bomLines: []);

      // Assert
      expect(recipe.mealType, isNull);
    });

    test('should carry the given mealType when provided', () {
      // Act
      const recipe = Recipe(
        id: 'recipe-avena',
        name: 'Avena',
        bomLines: [],
        mealType: MealType.desayuno,
      );

      // Assert
      expect(recipe.mealType, MealType.desayuno);
    });
  });
}
