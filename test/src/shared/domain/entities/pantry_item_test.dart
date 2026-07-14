import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/entities/pantry_item.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/presentation.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  group('PantryItem', () {
    test(
      'a quantity-tracked item (e.g. avena) should carry a stock Quantity',
      () {
        // Arrange & Act
        const item = PantryItem.quantityTracked(
          ingredientId: 'ingredient-avena',
          category: Category.cereal,
          presentation: Presentation.package(yieldQty: 454, label: 'bolsa'),
          stock: Quantity(value: 200, unit: Unit.gram),
        );

        // Assert
        expect(item, isA<PantryItem>());
        expect(item, isA<QuantityTrackedPantryItem>());
        expect(
          (item as QuantityTrackedPantryItem).stock,
          const Quantity(value: 200, unit: Unit.gram),
        );
        expect(item.category, Category.cereal);
      },
    );

    test('a boolean-tracked item (e.g. Comino) should expose only the '
        'have/dont-have flag, with no numeric stock field', () {
      // Arrange & Act
      const item = PantryItem.booleanTracked(
        ingredientId: 'ingredient-comino',
        category: Category.condimento,
        presentation: Presentation.loose(),
        haveIt: false,
      );

      // Assert — mutually exclusive shape: no stock Quantity exists on
      // this variant at all (compile-time guaranteed by the sealed
      // union), only the boolean flag.
      expect(item, isA<PantryItem>());
      expect(item, isA<BooleanTrackedPantryItem>());
      expect((item as BooleanTrackedPantryItem).haveIt, isFalse);
    });

    test('boolean-tracked "no tengo" and "tengo" both carry the flag', () {
      // Arrange & Act
      const noTengo = PantryItem.booleanTracked(
        ingredientId: 'ingredient-comino',
        category: Category.condimento,
        presentation: Presentation.loose(),
        haveIt: false,
      );
      const tengo = PantryItem.booleanTracked(
        ingredientId: 'ingredient-sal',
        category: Category.condimento,
        presentation: Presentation.loose(),
        haveIt: true,
      );

      // Assert
      expect((noTengo as BooleanTrackedPantryItem).haveIt, isFalse);
      expect((tengo as BooleanTrackedPantryItem).haveIt, isTrue);
    });
  });
}
