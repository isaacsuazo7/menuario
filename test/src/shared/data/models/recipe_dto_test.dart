import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/data/models/recipe_dto.dart';
import 'package:menuario/src/shared/domain/entities/bom_line.dart';
import 'package:menuario/src/shared/domain/entities/recipe.dart';
import 'package:menuario/src/shared/domain/value_objects/meal_type.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';
import 'package:menuario/src/shared/domain/value_objects/video_link.dart';
import 'package:menuario/src/shared/domain/value_objects/video_source.dart';

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

    test('a recipe with a mealType survives '
        'fromEntity->toJson->fromJson->toEntity', () {
      // Arrange
      const entity = Recipe(
        id: 'recipe-1',
        name: 'Avena con leche',
        bomLines: [],
        mealType: MealType.desayuno,
      );

      // Act
      final json = RecipeDTO.fromEntity(entity).toJson();
      final result = RecipeDTO.fromJson(json).toEntity(id: 'recipe-1');

      // Assert
      expect(result.mealType, MealType.desayuno);
      expect(json['mealType'], 'desayuno');
    });

    test('a recipe with no mealType preserves null through the round-trip',
        () {
      // Arrange
      const entity = Recipe(id: 'recipe-1', name: 'Vacía', bomLines: []);

      // Act
      final json = RecipeDTO.fromEntity(entity).toJson();
      final result = RecipeDTO.fromJson(json).toEntity(id: 'recipe-1');

      // Assert
      expect(result.mealType, isNull);
      expect(json['mealType'], isNull);
    });

    test('an unknown mealType wire value degrades to null on toEntity', () {
      // Arrange
      const dto = RecipeDTO(name: 'Vacía', bomLines: [], mealType: 'bogus');

      // Act
      final result = dto.toEntity(id: 'recipe-1');

      // Assert
      expect(result.mealType, isNull);
    });

    test('a recipe with videos survives '
        'fromEntity->toJson->fromJson->toEntity', () {
      // Arrange
      const entity = Recipe(
        id: 'recipe-1',
        name: 'Avena con leche',
        bomLines: [],
        videos: [
          VideoLink(source: VideoSource.youtube, url: 'https://youtu.be/1'),
          VideoLink(
            source: VideoSource.tiktok,
            url: 'https://tiktok.com/@x/video/2',
          ),
        ],
      );

      // Act
      final json = RecipeDTO.fromEntity(entity).toJson();
      final result = RecipeDTO.fromJson(json).toEntity(id: 'recipe-1');

      // Assert
      expect(result, entity);
      expect(result.videos.map((v) => v.source).toList(), [
        VideoSource.youtube,
        VideoSource.tiktok,
      ]);
    });

    test('a Firestore doc with no videos key deserializes to an empty list',
        () {
      // Arrange
      final json = <String, dynamic>{'name': 'Vacía', 'bomLines': <Object?>[]};

      // Act
      final result = RecipeDTO.fromJson(json).toEntity(id: 'recipe-1');

      // Assert
      expect(result.videos, isEmpty);
    });

    test('a Firestore doc with no enabled key deserializes to enabled true',
        () {
      // Arrange
      final json = <String, dynamic>{'name': 'Vacía', 'bomLines': <Object?>[]};

      // Act
      final result = RecipeDTO.fromJson(json).toEntity(id: 'recipe-1');

      // Assert
      expect(result.enabled, isTrue);
    });

    test('an explicit enabled:false is preserved through the round-trip', () {
      // Arrange
      const entity = Recipe(
        id: 'recipe-1',
        name: 'Avena',
        bomLines: [],
        enabled: false,
      );

      // Act
      final json = RecipeDTO.fromEntity(entity).toJson();
      final result = RecipeDTO.fromJson(json).toEntity(id: 'recipe-1');

      // Assert
      expect(json['enabled'], isFalse);
      expect(result.enabled, isFalse);
    });
  });
}
