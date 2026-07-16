import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/services/measurement_converter.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_kind.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_mode.dart';
import 'package:menuario/src/shared/domain/value_objects/package_spec.dart';
import 'package:menuario/src/shared/domain/value_objects/presentation.dart';
import 'package:menuario/src/shared/domain/value_objects/purchase_quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  const converter = MeasurementConverter();
  const taza = Unit(symbol: 'taza', dimension: UnitDimension.volume);

  group('MeasurementConverter', () {
    group('toStockUnit', () {
      test('mass mode multiplies recipe quantity by conversionFactor into '
          'grams (pollo, cf=1, 100 g -> 100 g)', () {
        // Arrange
        const pollo = Ingredient(
          id: 'ingredient-pollo',
          name: 'Pollo',
          category: Category.proteina,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          measurementMode: MeasurementMode.mass,
          conversionFactor: 1,
        );
        const recipeQuantity = Quantity(value: 100, unit: Unit.gram);

        // Act
        final result = converter.toStockUnit(
          recipeQuantity: recipeQuantity,
          ingredient: pollo,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(Quantity(value: 100, unit: Unit.gram)),
        );
      });

      test('mass mode passes the recipe quantity through as an identity '
          'when it is already in grams, requiring NO conversionFactor '
          '(queso already in g, no factor set, 250 g -> 250 g)', () {
        // Arrange
        const queso = Ingredient(
          id: 'ingredient-queso',
          name: 'Queso',
          category: Category.lacteo,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          measurementMode: MeasurementMode.mass,
        );
        const recipeQuantity = Quantity(value: 250, unit: Unit.gram);

        // Act
        final result = converter.toStockUnit(
          recipeQuantity: recipeQuantity,
          ingredient: queso,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(Quantity(value: 250, unit: Unit.gram)),
        );
      });

      test('mass mode multiplies by a different factor '
          '(avena 8 taza x 85 g/taza = 680 g)', () {
        // Arrange
        const avena = Ingredient(
          id: 'ingredient-avena',
          name: 'Avena',
          category: Category.cereal,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          measurementMode: MeasurementMode.mass,
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

      test('count mode passes the recipe quantity through unchanged '
          '(banano 2 u)', () {
        // Arrange
        const banano = Ingredient(
          id: 'ingredient-banano',
          name: 'Banano',
          category: Category.fruta,
          measurementKind: MeasurementKind.unit,
          booleanTracked: false,
          measurementMode: MeasurementMode.count,
        );
        const recipeQuantity = Quantity(value: 2, unit: Unit.count);

        // Act
        final result = converter.toStockUnit(
          recipeQuantity: recipeQuantity,
          ingredient: banano,
        );

        // Assert
        expect(result, const Right<Failure, Quantity>(recipeQuantity));
      });

      test('count mode returns Left(unknownUnit) for a non-count recipe '
          'unit (huevo given taza)', () {
        // Arrange
        const huevo = Ingredient(
          id: 'ingredient-huevo',
          name: 'Huevo',
          category: Category.proteina,
          measurementKind: MeasurementKind.unit,
          booleanTracked: false,
          measurementMode: MeasurementMode.count,
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

      test('packageBase mode with a volume base dimension multiplies into '
          'that base unit, not grams (leche 0.5 taza x 0.24 = 0.12 L)', () {
        // Arrange
        const leche = Ingredient(
          id: 'ingredient-leche',
          name: 'Leche',
          category: Category.lacteo,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          measurementMode: MeasurementMode.packageBase,
          conversionFactor: 0.24,
          package: PackageSpec(
            label: 'bolsa',
            yieldQty: 1,
            baseDimension: Unit.liter,
          ),
        );
        const recipeQuantity = Quantity(value: 0.5, unit: taza);

        // Act
        final result = converter.toStockUnit(
          recipeQuantity: recipeQuantity,
          ingredient: leche,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(
            Quantity(value: 0.12, unit: Unit.liter),
          ),
        );
      });

      test('packageBase mode with a count base dimension matches the '
          'recipe unit (huevo cartón, cf=1, 1 u -> 1 u)', () {
        // Arrange
        const huevoCarton = Ingredient(
          id: 'ingredient-huevo-carton',
          name: 'Huevo',
          category: Category.proteina,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          measurementMode: MeasurementMode.packageBase,
          conversionFactor: 1,
          package: PackageSpec(
            label: 'cartón',
            yieldQty: 15,
            baseDimension: Unit.count,
          ),
        );
        const recipeQuantity = Quantity(value: 1, unit: Unit.count);

        // Act
        final result = converter.toStockUnit(
          recipeQuantity: recipeQuantity,
          ingredient: huevoCarton,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(Quantity(value: 1, unit: Unit.count)),
        );
      });

      test('packageBase mode with a count base dimension passes the recipe '
          'quantity through as an identity, requiring NO conversionFactor '
          '(huevo cartón/u, no factor set, 1 u -> 1 u)', () {
        // Arrange
        const huevoCarton = Ingredient(
          id: 'ingredient-huevo-carton',
          name: 'Huevo',
          category: Category.proteina,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          measurementMode: MeasurementMode.packageBase,
          package: PackageSpec(
            label: 'cartón',
            yieldQty: 15,
            baseDimension: Unit.count,
          ),
        );
        const recipeQuantity = Quantity(value: 1, unit: Unit.count);

        // Act
        final result = converter.toStockUnit(
          recipeQuantity: recipeQuantity,
          ingredient: huevoCarton,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(Quantity(value: 1, unit: Unit.count)),
        );
      });

      test('packageBase mode with a count base dimension passes the recipe '
          'quantity through as an identity for a caja/u cracker, requiring '
          'NO conversionFactor (galletas-marías caja/u, no factor set, '
          '2 u -> 2 u)', () {
        // Arrange
        const galletasMarias = Ingredient(
          id: 'ingredient-galletas-marias',
          name: 'Galletas María',
          category: Category.cereal,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          measurementMode: MeasurementMode.packageBase,
          package: PackageSpec(
            label: 'caja',
            yieldQty: 20,
            baseDimension: Unit.count,
          ),
        );
        const recipeQuantity = Quantity(value: 2, unit: Unit.count);

        // Act
        final result = converter.toStockUnit(
          recipeQuantity: recipeQuantity,
          ingredient: galletasMarias,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(Quantity(value: 2, unit: Unit.count)),
        );
      });

      test('packageBase mode with a cross-dimension recipe unit still '
          'requires and applies conversionFactor (leche, base L, recipe '
          'in taza, cf=0.24, 0.5 taza -> 0.12 L)', () {
        // Arrange
        const leche = Ingredient(
          id: 'ingredient-leche',
          name: 'Leche',
          category: Category.lacteo,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          measurementMode: MeasurementMode.packageBase,
          conversionFactor: 0.24,
          package: PackageSpec(
            label: 'bolsa',
            yieldQty: 1,
            baseDimension: Unit.liter,
          ),
        );
        const recipeQuantity = Quantity(value: 0.5, unit: taza);

        // Act
        final result = converter.toStockUnit(
          recipeQuantity: recipeQuantity,
          ingredient: leche,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(
            Quantity(value: 0.12, unit: Unit.liter),
          ),
        );
      });

      test('packageBase mode with a cross-dimension recipe unit still '
          'reports Left(missingConversionFactor) when no factor is set '
          '(leche, base L, recipe in taza, no factor)', () {
        // Arrange
        const lecheNoFactor = Ingredient(
          id: 'ingredient-leche-no-factor',
          name: 'Leche',
          category: Category.lacteo,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          measurementMode: MeasurementMode.packageBase,
          package: PackageSpec(
            label: 'bolsa',
            yieldQty: 1,
            baseDimension: Unit.liter,
          ),
        );
        const recipeQuantity = Quantity(value: 0.5, unit: taza);

        // Act
        final result = converter.toStockUnit(
          recipeQuantity: recipeQuantity,
          ingredient: lecheNoFactor,
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

      test('packageAbstract mode multiplies into a package fraction '
          '(espinaca cf=0.1, 1 recipe unit -> 0.1 paq)', () {
        // Arrange
        const espinaca = Ingredient(
          id: 'ingredient-espinaca',
          name: 'Espinaca',
          category: Category.vegetal,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          measurementMode: MeasurementMode.packageAbstract,
          conversionFactor: 0.1,
          package: PackageSpec(label: 'bolsa'),
        );
        const recipeQuantity = Quantity(value: 1, unit: Unit.count);

        // Act
        final result = converter.toStockUnit(
          recipeQuantity: recipeQuantity,
          ingredient: espinaca,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(
            Quantity(value: 0.1, unit: Unit.package),
          ),
        );
      });

      test('packageAbstract mode passes the recipe quantity through as an '
          'identity when it is already in paq, requiring NO '
          'conversionFactor (espinaca given in paq directly, no factor '
          'set, 0.5 paq -> 0.5 paq)', () {
        // Arrange
        const espinaca = Ingredient(
          id: 'ingredient-espinaca',
          name: 'Espinaca',
          category: Category.vegetal,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          measurementMode: MeasurementMode.packageAbstract,
          package: PackageSpec(label: 'bolsa'),
        );
        const recipeQuantity = Quantity(value: 0.5, unit: Unit.package);

        // Act
        final result = converter.toStockUnit(
          recipeQuantity: recipeQuantity,
          ingredient: espinaca,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(
            Quantity(value: 0.5, unit: Unit.package),
          ),
        );
      });

      test('mass mode returns Left(missingConversionFactor) when the '
          'ingredient has no factor', () {
        // Arrange
        const arroz = Ingredient(
          id: 'ingredient-arroz',
          name: 'Arroz',
          category: Category.cereal,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          measurementMode: MeasurementMode.mass,
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

      test('packageAbstract mode returns Left(missingConversionFactor) when '
          'the ingredient has no factor (espinaca not yet backfilled)', () {
        // Arrange
        const espinaca = Ingredient(
          id: 'ingredient-espinaca',
          name: 'Espinaca',
          category: Category.vegetal,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          measurementMode: MeasurementMode.packageAbstract,
          package: PackageSpec(label: 'bolsa'),
        );
        const recipeQuantity = Quantity(value: 1, unit: Unit.count);

        // Act
        final result = converter.toStockUnit(
          recipeQuantity: recipeQuantity,
          ingredient: espinaca,
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

      test('boolean mode defensively returns Left(unknownUnit) — never '
          'reached in practice, boolean items route via '
          'shouldSurfaceBooleanItem instead', () {
        // Arrange
        const sal = Ingredient(
          id: 'ingredient-sal',
          name: 'Sal',
          category: Category.condimento,
          measurementKind: MeasurementKind.unit,
          booleanTracked: true,
          measurementMode: MeasurementMode.boolean,
        );
        const recipeQuantity = Quantity(value: 1, unit: Unit.count);

        // Act
        final result = converter.toStockUnit(
          recipeQuantity: recipeQuantity,
          ingredient: sal,
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

      test('package presentation should resolve a shortfall EXACTLY equal '
          'to the pack yield to a single pack, not an extra one '
          '(avena shortfall 454 g, bolsa yield 454 g -> 1 bolsa)', () {
        // Arrange
        const shortfall = Quantity(value: 454, unit: Unit.gram);

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
            PurchaseQuantity.packagePurchase(packs: 1, label: 'bolsas'),
          ),
        );
      });

      test('package presentation should resolve a shortfall that is an '
          'EXACT multiple of the pack yield without an off-by-one '
          '(avena shortfall 908 g, bolsa yield 454 g -> 2 bolsas)', () {
        // Arrange
        const shortfall = Quantity(value: 908, unit: Unit.gram);

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

      test('counter presentation should land exactly on 1 lb for a '
          'shortfall exactly at the 1 lb boundary (453.59237 g -> 1 lb, '
          'not 1 ¼ lb)', () {
        // Arrange
        const shortfall = Quantity(value: 453.59237, unit: Unit.gram);

        // Act
        final result = converter.toPurchaseQuantity(
          stockShortfall: shortfall,
          presentation: const Presentation.counter(),
        );

        // Assert
        expect(
          result,
          const Right<Failure, PurchaseQuantity>(
            PurchaseQuantity.counterPurchase(quarterPounds: 4),
          ),
        );
        expect(
          (result as Right<Failure, PurchaseQuantity>).value.display,
          '1 lb',
        );
      });

      test('counter presentation should land exactly on ½ lb for a '
          'shortfall exactly at the ½ lb boundary (226.796185 g -> ½ lb, '
          'not ¾ lb)', () {
        // Arrange
        const shortfall = Quantity(value: 226.796185, unit: Unit.gram);

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

      test('counter presentation should land exactly on ¼ lb for a '
          'shortfall exactly at the ¼ lb boundary (113.3980925 g -> ¼ lb, '
          'not ½ lb)', () {
        // Arrange
        const shortfall = Quantity(value: 113.3980925, unit: Unit.gram);

        // Act
        final result = converter.toPurchaseQuantity(
          stockShortfall: shortfall,
          presentation: const Presentation.counter(),
        );

        // Assert
        expect(
          result,
          const Right<Failure, PurchaseQuantity>(
            PurchaseQuantity.counterPurchase(quarterPounds: 1),
          ),
        );
        expect(
          (result as Right<Failure, PurchaseQuantity>).value.display,
          '¼ lb',
        );
      });

      test('counter presentation must not over-round when floating-point '
          'noise pushes a mathematically-exact 1 lb boundary marginally '
          'above it (0.1 * 4535.9237 g -> still 1 lb, not 1 ¼ lb)', () {
        // Arrange
        const shortfall = Quantity(value: 0.1 * 4535.9237, unit: Unit.gram);

        // Act
        final result = converter.toPurchaseQuantity(
          stockShortfall: shortfall,
          presentation: const Presentation.counter(),
        );

        // Assert
        expect(
          result,
          const Right<Failure, PurchaseQuantity>(
            PurchaseQuantity.counterPurchase(quarterPounds: 4),
          ),
        );
        expect(
          (result as Right<Failure, PurchaseQuantity>).value.display,
          '1 lb',
        );
      });
    });
  });
}
