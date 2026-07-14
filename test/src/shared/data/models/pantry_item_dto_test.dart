import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/data/models/pantry_item_dto.dart';
import 'package:menuario/src/shared/domain/entities/pantry_item.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/presentation.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  group('PantryItemDTO round-trip', () {
    test(
      'a quantity-tracked item survives '
      'fromEntity->toJson->fromJson->toEntity via the "quantityTracked" '
      'type discriminator, id injected from doc id and absent from the map',
      () {
        // Arrange
        const entity = PantryItem.quantityTracked(
          ingredientId: 'ingredient-avena',
          category: Category.cereal,
          presentation: Presentation.package(yieldQty: 454, label: 'bolsa'),
          stock: Quantity(value: 340, unit: Unit.gram),
        );

        // Act
        final json = PantryItemDTO.fromEntity(entity).toJson();
        final result = PantryItemDTO.fromJson(
          json,
        ).toEntity(ingredientId: 'ingredient-avena');

        // Assert
        expect(result, entity);
        expect(json['type'], 'quantityTracked');
        expect(json.containsKey('ingredientId'), isFalse);
      },
    );

    test(
      'a boolean-tracked item survives '
      'fromEntity->toJson->fromJson->toEntity via the "booleanTracked" '
      'type discriminator, id injected from doc id and absent from the map',
      () {
        // Arrange
        const entity = PantryItem.booleanTracked(
          ingredientId: 'ingredient-comino',
          category: Category.condimento,
          presentation: Presentation.loose(),
          haveIt: true,
        );

        // Act
        final json = PantryItemDTO.fromEntity(entity).toJson();
        final result = PantryItemDTO.fromJson(
          json,
        ).toEntity(ingredientId: 'ingredient-comino');

        // Assert
        expect(result, entity);
        expect(json['type'], 'booleanTracked');
        expect(json.containsKey('ingredientId'), isFalse);
      },
    );

    test('a boolean-tracked item that does not have the ingredient round-trips '
        'exactly, proving haveIt is not hardcoded true', () {
      // Arrange
      const entity = PantryItem.booleanTracked(
        ingredientId: 'ingredient-sal',
        category: Category.condimento,
        presentation: Presentation.counter(),
        haveIt: false,
      );

      // Act
      final json = PantryItemDTO.fromEntity(entity).toJson();
      final result = PantryItemDTO.fromJson(
        json,
      ).toEntity(ingredientId: 'ingredient-sal');

      // Assert
      expect(result, entity);
      expect(json['haveIt'], isFalse);
    });
  });
}
