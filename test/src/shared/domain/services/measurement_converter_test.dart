import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/services/measurement_converter.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_kind.dart';
import 'package:menuario/src/shared/domain/value_objects/presentation.dart';
import 'package:menuario/src/shared/domain/value_objects/purchase_quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  const converter = MeasurementConverter();
  const taza = Unit(symbol: 'taza', dimension: UnitDimension.volume);

  group('MeasurementConverter', () {
    group('toStockUnit', () {
      test('should convert a bulk ingredient via its conversionFactor '
          '(avena 8 taza x 85 g/taza = 680 g)', () {
        // Arrange
        const avena = Ingredient(
          id: 'ingredient-avena',
          name: 'Avena',
          category: Category.cereal,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          conversionFactor: 85,
        );
        const recipeQuantity = Quantity(value: 8, unit: taza);

        // Act
        final result = converter.toStockUnit(
          recipeQuantity: recipeQuantity,
          ingredient: avena,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(Quantity(value: 680, unit: Unit.gram)),
        );
      });

      test('should convert a different bulk ingredient with its own factor '
          '(arroz 3 taza x 50 g/taza = 150 g)', () {
        // Arrange
        const arroz = Ingredient(
          id: 'ingredient-arroz',
          name: 'Arroz',
          category: Category.cereal,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          conversionFactor: 50,
        );
        const recipeQuantity = Quantity(value: 3, unit: taza);

        // Act
        final result = converter.toStockUnit(
          recipeQuantity: recipeQuantity,
          ingredient: arroz,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(Quantity(value: 150, unit: Unit.gram)),
        );
      });

      test('should leave a unit-exact ingredient recipe quantity unchanged '
          '(huevo 17 u)', () {
        // Arrange
        const huevo = Ingredient(
          id: 'ingredient-huevo',
          name: 'Huevo',
          category: Category.proteina,
          measurementKind: MeasurementKind.unit,
          booleanTracked: false,
        );
        const recipeQuantity = Quantity(value: 17, unit: Unit.count);

        // Act
        final result = converter.toStockUnit(
          recipeQuantity: recipeQuantity,
          ingredient: huevo,
        );

        // Assert
        expect(result, const Right<Failure, Quantity>(recipeQuantity));
      });

      test('should return Left(missingConversionFactor) for a bulk ingredient '
          'with no factor', () {
        // Arrange
        const arroz = Ingredient(
          id: 'ingredient-arroz',
          name: 'Arroz',
          category: Category.cereal,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
        );
        const recipeQuantity = Quantity(value: 2, unit: taza);

        // Act
        final result = converter.toStockUnit(
          recipeQuantity: recipeQuantity,
          ingredient: arroz,
        );

        // Assert
        expect(
          result,
          isA<Left<Failure, Quantity>>().having(
            (left) => left.value.code,
            'code',
            'missingConversionFactor',
          ),
        );
      });

      test('should return Left(unknownUnit) for a unit-exact ingredient given '
          'a non-count recipe unit', () {
        // Arrange
        const huevo = Ingredient(
          id: 'ingredient-huevo',
          name: 'Huevo',
          category: Category.proteina,
          measurementKind: MeasurementKind.unit,
          booleanTracked: false,
        );
        const recipeQuantity = Quantity(value: 3, unit: taza);

        // Act
        final result = converter.toStockUnit(
          recipeQuantity: recipeQuantity,
          ingredient: huevo,
        );

        // Assert
        expect(
          result,
          isA<Left<Failure, Quantity>>().having(
            (left) => left.value.code,
            'code',
            'unknownUnit',
          ),
        );
      });
    });

    group('toPurchaseQuantity', () {
      test('loose presentation should ceil an already-integer shortfall '
          '(plátano shortfall 6 u -> 6 unidades)', () {
        // Arrange
        const shortfall = Quantity(value: 6, unit: Unit.count);

        // Act
        final result = converter.toPurchaseQuantity(
          stockShortfall: shortfall,
          presentation: const Presentation.loose(),
        );

        // Assert
        expect(
          result,
          const Right<Failure, PurchaseQuantity>(
            PurchaseQuantity.loosePurchase(units: 6),
          ),
        );
      });

      test('loose presentation should ceil a fractional shortfall up '
          '(2.4 -> 3 unidades, never rounds down)', () {
        // Arrange
        const shortfall = Quantity(value: 2.4, unit: Unit.count);

        // Act
        final result = converter.toPurchaseQuantity(
          stockShortfall: shortfall,
          presentation: const Presentation.loose(),
        );

        // Assert
        expect(
          result,
          const Right<Failure, PurchaseQuantity>(
            PurchaseQuantity.loosePurchase(units: 3),
          ),
        );
      });

      test('package presentation should ceil to whole bulk packs '
          '(avena shortfall 480 g, bolsa yield 454 g -> 2 bolsas)', () {
        // Arrange
        const shortfall = Quantity(value: 480, unit: Unit.gram);

        // Act
        final result = converter.toPurchaseQuantity(
          stockShortfall: shortfall,
          presentation: const Presentation.package(
            yieldQty: 454,
            label: 'bolsas',
          ),
        );

        // Assert
        expect(
          result,
          const Right<Failure, PurchaseQuantity>(
            PurchaseQuantity.packagePurchase(packs: 2, label: 'bolsas'),
          ),
        );
      });

      test('package presentation should ceil to whole unit packs '
          '(huevo shortfall 11 u, cartón yield 15 -> 1 cartón (15 u))', () {
        // Arrange
        const shortfall = Quantity(value: 11, unit: Unit.count);

        // Act
        final result = converter.toPurchaseQuantity(
          stockShortfall: shortfall,
          presentation: const Presentation.package(
            yieldQty: 15,
            label: 'cartón (15 u)',
          ),
        );

        // Assert
        expect(
          result,
          const Right<Failure, PurchaseQuantity>(
            PurchaseQuantity.packagePurchase(packs: 1, label: 'cartón (15 u)'),
          ),
        );
        expect(
          (result as Right<Failure, PurchaseQuantity>).value.display,
          '1 cartón (15 u)',
        );
      });

      test('counter presentation should round up to the next quarter-pound '
          '(pollo shortfall 1200 g -> 2 ¾ lb)', () {
        // Arrange
        const shortfall = Quantity(value: 1200, unit: Unit.gram);

        // Act
        final result = converter.toPurchaseQuantity(
          stockShortfall: shortfall,
          presentation: const Presentation.counter(),
        );

        // Assert
        expect(
          result,
          const Right<Failure, PurchaseQuantity>(
            PurchaseQuantity.counterPurchase(quarterPounds: 11),
          ),
        );
        expect(
          (result as Right<Failure, PurchaseQuantity>).value.display,
          '2 ¾ lb',
        );
      });

      test('counter presentation should round a small shortfall up to the '
          'next quarter-pound, never down (200 g -> ½ lb)', () {
        // Arrange
        const shortfall = Quantity(value: 200, unit: Unit.gram);

        // Act
        final result = converter.toPurchaseQuantity(
          stockShortfall: shortfall,
          presentation: const Presentation.counter(),
        );

        // Assert
        expect(
          result,
          const Right<Failure, PurchaseQuantity>(
            PurchaseQuantity.counterPurchase(quarterPounds: 2),
          ),
        );
        expect(
          (result as Right<Failure, PurchaseQuantity>).value.display,
          '½ lb',
        );
      });
    });
  });
}
