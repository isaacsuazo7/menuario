import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/entities/bom_line.dart';
import 'package:menuario/src/shared/domain/entities/recipe.dart';
import 'package:menuario/src/shared/domain/value_objects/meal_type.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';
import 'package:menuario/src/shared/domain/value_objects/video_link.dart';
import 'package:menuario/src/shared/domain/value_objects/video_source.dart';

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

    test('should default videos to an empty list when not provided', () {
      // Act
      const recipe = Recipe(id: 'recipe-avena', name: 'Avena', bomLines: []);

      // Assert
      expect(recipe.videos, isEmpty);
    });

    test('should carry the given videos when provided', () {
      // Arrange
      const video = VideoLink(
        source: VideoSource.youtube,
        url: 'https://youtu.be/abc',
      );

      // Act
      const recipe = Recipe(
        id: 'recipe-avena',
        name: 'Avena',
        bomLines: [],
        videos: [video],
      );

      // Assert
      expect(recipe.videos, [video]);
    });

    test('should default enabled to true when not provided', () {
      // Act
      const recipe = Recipe(id: 'recipe-avena', name: 'Avena', bomLines: []);

      // Assert
      expect(recipe.enabled, isTrue);
    });

    test('should carry enabled as false when explicitly disabled', () {
      // Act
      const recipe = Recipe(
        id: 'recipe-avena',
        name: 'Avena',
        bomLines: [],
        enabled: false,
      );

      // Assert
      expect(recipe.enabled, isFalse);
    });

    test('should not expose a mutator: copyWith produces a new immutable '
        'instance without altering the original', () {
      // Arrange
      const original = Recipe(
        id: 'recipe-avena',
        name: 'Avena',
        bomLines: [],
        enabled: true,
      );

      // Act
      final replaced = original.copyWith(enabled: false);

      // Assert
      expect(original.enabled, isTrue);
      expect(replaced.enabled, isFalse);
      expect(identical(original, replaced), isFalse);
    });
  });
}
