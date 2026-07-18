import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/entities/bom_line.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  group('BomLine', () {
    const taza = Unit(symbol: 'taza', dimension: UnitDimension.volume);

    test('should carry a recipe ref, ingredient ref and quantity', () {
      // Arrange & Act
      const line = BomLine(
        recipeId: 'recipe-avena',
        ingredientId: 'ingredient-avena',
        quantity: Quantity(value: 8, unit: taza),
      );

      // Assert
      expect(line.recipeId, 'recipe-avena');
      expect(line.ingredientId, 'ingredient-avena');
      expect(line.quantity, const Quantity(value: 8, unit: taza));
    });

    test('should not expose a mutator: copyWith produces a new immutable '
        'instance without altering the original', () {
      // Arrange
      const original = BomLine(
        recipeId: 'recipe-avena',
        ingredientId: 'ingredient-avena',
        quantity: Quantity(value: 8, unit: taza),
      );

      // Act
      final replaced = original.copyWith(
        quantity: const Quantity(value: 4, unit: taza),
      );

      // Assert — original is untouched (protects Dra. Barahona's plan).
      expect(original.quantity, const Quantity(value: 8, unit: taza));
      expect(replaced.quantity, const Quantity(value: 4, unit: taza));
      expect(identical(original, replaced), isFalse);
    });

    test('should allow an omitted quantity — an "al gusto" line for a '
        'boolean-tracked ingredient carries no number at all', () {
      // Arrange & Act
      const line = BomLine(
        recipeId: 'recipe-pollo',
        ingredientId: 'ingredient-oregano',
      );

      // Assert
      expect(line.recipeId, 'recipe-pollo');
      expect(line.ingredientId, 'ingredient-oregano');
      expect(line.quantity, isNull);
    });
  });
}
