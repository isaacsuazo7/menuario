import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/entities/pantry_item.dart';
import 'package:menuario/src/shared/domain/services/stock_presentation_service.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/presentation.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  const service = StockPresentationService();

  group('StockPresentationService', () {
    group('stockStep', () {
      test('loose item steps by 1 unit (huevo 7 u -> step 1)', () {
        // Arrange
        const item =
            PantryItem.quantityTracked(
                  ingredientId: 'ingredient-huevo',
                  category: Category.proteina,
                  presentation: Presentation.loose(),
                  stock: Quantity(value: 7, unit: Unit.count),
                )
                as QuantityTrackedPantryItem;

        // Act
        final step = service.stockStep(item);

        // Assert
        expect(step, 1);
      });

      test('package item with bulk yield steps by yieldQty in grams '
          '(avena yieldQty 454 -> step 454 g)', () {
        // Arrange
        const item =
            PantryItem.quantityTracked(
                  ingredientId: 'ingredient-avena',
                  category: Category.cereal,
                  presentation: Presentation.package(
                    yieldQty: 454,
                    label: 'bolsas',
                  ),
                  stock: Quantity(value: 0, unit: Unit.gram),
                )
                as QuantityTrackedPantryItem;

        // Act
        final step = service.stockStep(item);

        // Assert
        expect(step, 454);
      });

      test('package item with unit yield steps by yieldQty in count '
          '(huevo cartón yieldQty 15 -> step 15 u)', () {
        // Arrange
        const item =
            PantryItem.quantityTracked(
                  ingredientId: 'ingredient-huevo-carton',
                  category: Category.proteina,
                  presentation: Presentation.package(
                    yieldQty: 15,
                    label: 'cartón (15 u)',
                  ),
                  stock: Quantity(value: 0, unit: Unit.count),
                )
                as QuantityTrackedPantryItem;

        // Act
        final step = service.stockStep(item);

        // Assert
        expect(step, 15);
      });

      test('counter item steps by a quarter-pound in grams '
          '(pollo 1.75 lb -> step ¼ lb, next value 2.00 lb)', () {
        // Arrange
        const item =
            PantryItem.quantityTracked(
                  ingredientId: 'ingredient-pollo',
                  category: Category.proteina,
                  presentation: Presentation.counter(),
                  stock: Quantity(value: 793.7866475, unit: Unit.gram),
                )
                as QuantityTrackedPantryItem;

        // Act
        final step = service.stockStep(item);

        // Assert
        expect(step, closeTo(113.3980925, 1e-9));
        expect(item.stock.value + step, closeTo(907.18474, 1e-6));
      });
    });

    group('display', () {
      test('counter item shows decimal pounds at 2dp '
          '(pollo 793.7 g -> "1.75 lb")', () {
        // Arrange
        const stock = Quantity(value: 793.7, unit: Unit.gram);

        // Act
        final display = service.display(stock, const Presentation.counter());

        // Assert
        expect(display.label, '1.75 lb');
      });

      test('counter item truncates for presentation only, storage untouched '
          '(carne molida 151 g -> "0.33 lb")', () {
        // Arrange
        const stock = Quantity(value: 151, unit: Unit.gram);

        // Act
        final display = service.display(stock, const Presentation.counter());

        // Assert
        expect(display.label, '0.33 lb');
        expect(stock.value, 151);
      });

      test('package item at exactly one pack uses the presentation label '
          '(avena 454 g, yieldQty 454, label "bolsa" -> "1 bolsa")', () {
        // Arrange
        const stock = Quantity(value: 454, unit: Unit.gram);
        const presentation = Presentation.package(
          yieldQty: 454,
          label: 'bolsa',
        );

        // Act
        final display = service.display(stock, presentation);

        // Assert
        expect(display.label, '1 bolsa');
      });

      test('package item at a non-multiple of yieldQty trims trailing '
          'zeros to at most 2 decimals '
          '(avena 227 g, yieldQty 454, label "bolsa" -> "0.5 bolsa")', () {
        // Arrange
        const stock = Quantity(value: 227, unit: Unit.gram);
        const presentation = Presentation.package(
          yieldQty: 454,
          label: 'bolsa',
        );

        // Act
        final display = service.display(stock, presentation);

        // Assert
        expect(display.label, '0.5 bolsa');
      });

      test('loose item shows a whole-unit count '
          '(huevo 7 u -> "7 u")', () {
        // Arrange
        const stock = Quantity(value: 7, unit: Unit.count);

        // Act
        final display = service.display(stock, const Presentation.loose());

        // Assert
        expect(display.label, '7 u');
      });
    });

    group('toStockValue / toNaturalValue', () {
      test('counter round-trips pounds to grams and back '
          '(1.75 lb <-> 793.7866475 g)', () {
        // Act
        final stockValue = service.toStockValue(
          naturalValue: 1.75,
          presentation: const Presentation.counter(),
          stockUnit: Unit.gram,
        );
        final naturalValue = service.toNaturalValue(
          stockValue: stockValue,
          presentation: const Presentation.counter(),
        );

        // Assert
        expect(stockValue, closeTo(793.7866475, 1e-6));
        expect(naturalValue, closeTo(1.75, 1e-9));
      });

      test('package (bulk yield) round-trips packs to grams and back '
          '(2 bolsas, yieldQty 454 <-> 908 g)', () {
        // Arrange
        const presentation = Presentation.package(
          yieldQty: 454,
          label: 'bolsas',
        );

        // Act
        final stockValue = service.toStockValue(
          naturalValue: 2,
          presentation: presentation,
          stockUnit: Unit.gram,
        );
        final naturalValue = service.toNaturalValue(
          stockValue: stockValue,
          presentation: presentation,
        );

        // Assert
        expect(stockValue, 908);
        expect(naturalValue, 2);
      });

      test('package (unit yield) round-trips packs to count and back '
          '(1 cartón, yieldQty 15 <-> 15 u)', () {
        // Arrange
        const presentation = Presentation.package(
          yieldQty: 15,
          label: 'cartón (15 u)',
        );

        // Act
        final stockValue = service.toStockValue(
          naturalValue: 1,
          presentation: presentation,
          stockUnit: Unit.count,
        );
        final naturalValue = service.toNaturalValue(
          stockValue: stockValue,
          presentation: presentation,
        );

        // Assert
        expect(stockValue, 15);
        expect(naturalValue, 1);
      });

      test('loose round-trips units to stock count unchanged '
          '(7 u <-> 7 u)', () {
        // Act
        final stockValue = service.toStockValue(
          naturalValue: 7,
          presentation: const Presentation.loose(),
          stockUnit: Unit.count,
        );
        final naturalValue = service.toNaturalValue(
          stockValue: stockValue,
          presentation: const Presentation.loose(),
        );

        // Assert
        expect(stockValue, 7);
        expect(naturalValue, 7);
      });
    });
  });
}
