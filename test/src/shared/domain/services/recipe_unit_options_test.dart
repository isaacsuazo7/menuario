import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/services/measurement_converter.dart';
import 'package:menuario/src/shared/domain/services/recipe_unit_options.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_kind.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_mode.dart';
import 'package:menuario/src/shared/domain/value_objects/package_spec.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  const converter = MeasurementConverter();

  group('recipeUnitsFor', () {
    test('count mode returns strictly {u} (banano, no factor)', () {
      // Arrange
      const banano = Ingredient(
        id: 'ingredient-banano',
        name: 'Banano',
        category: Category.fruta,
        measurementKind: MeasurementKind.unit,
        booleanTracked: false,
        measurementMode: MeasurementMode.count,
      );

      // Act
      final result = recipeUnitsFor(banano);

      // Assert
      expect(result, const [Unit.count]);
    });

    test('mass mode without conversionFactor returns {g, kg} only, no '
        'taza/cda (queso, no factor)', () {
      // Arrange
      const queso = Ingredient(
        id: 'ingredient-queso',
        name: 'Queso',
        category: Category.lacteo,
        measurementKind: MeasurementKind.bulk,
        booleanTracked: false,
        measurementMode: MeasurementMode.mass,
      );

      // Act
      final result = recipeUnitsFor(queso);

      // Assert
      expect(result, unorderedEquals(<Unit>[Unit.gram, Unit.kilogram]));
    });

    test('mass mode with conversionFactor adds taza/cda to {g, kg} '
        '(avena, cf=85)', () {
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

      // Act
      final result = recipeUnitsFor(avena);

      // Assert
      expect(
        result,
        unorderedEquals(<Unit>[
          Unit.gram,
          Unit.kilogram,
          Unit.cup,
          Unit.tablespoon,
        ]),
      );
    });

    test('packageBase mode with a volume base dimension and no factor '
        'returns {L, ml} only (leche, no factor)', () {
      // Arrange
      const leche = Ingredient(
        id: 'ingredient-leche',
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

      // Act
      final result = recipeUnitsFor(leche);

      // Assert
      expect(result, unorderedEquals(<Unit>[Unit.liter, Unit.milliliter]));
    });

    test('packageBase mode with a volume base dimension and a factor adds '
        'taza/cda to {L, ml} (leche, cf=0.24)', () {
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

      // Act
      final result = recipeUnitsFor(leche);

      // Assert
      expect(
        result,
        unorderedEquals(<Unit>[
          Unit.liter,
          Unit.milliliter,
          Unit.cup,
          Unit.tablespoon,
        ]),
      );
    });

    test('packageBase mode with a count base dimension and no factor '
        'returns {u} only — count has no metric sibling (huevo cartón, no '
        'factor)', () {
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

      // Act
      final result = recipeUnitsFor(huevoCarton);

      // Assert
      expect(result, const [Unit.count]);
    });

    test('packageBase mode with a count base dimension and a factor still '
        'returns {u} only — the dimension gate excludes taza/cda for a '
        'counted package regardless of conversionFactor (huevo cartón, '
        'cf=1)', () {
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

      // Act
      final result = recipeUnitsFor(huevoCarton);

      // Assert
      expect(result, const [Unit.count]);
    });

    test('packageAbstract mode without a factor returns {paq} only '
        '(espinaca, no factor)', () {
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

      // Act
      final result = recipeUnitsFor(espinaca);

      // Assert
      expect(result, const [Unit.package]);
    });

    test('packageAbstract mode with a factor adds taza/cda to {paq} '
        '(espinaca, cf=0.1)', () {
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

      // Act
      final result = recipeUnitsFor(espinaca);

      // Assert
      expect(
        result,
        unorderedEquals(<Unit>[Unit.package, Unit.cup, Unit.tablespoon]),
      );
    });

    test('boolean mode returns the empty set (sal, never numerically '
        'tracked)', () {
      // Arrange
      const sal = Ingredient(
        id: 'ingredient-sal',
        name: 'Sal',
        category: Category.condimento,
        measurementKind: MeasurementKind.unit,
        booleanTracked: true,
        measurementMode: MeasurementMode.boolean,
      );

      // Act
      final result = recipeUnitsFor(sal);

      // Assert
      expect(result, isEmpty);
    });

    test('convertibility invariant: every unit recipeUnitsFor returns for '
        'an ingredient converts cleanly via toStockUnit for THAT '
        'ingredient (never missingConversionFactor/unknownUnit)', () {
      // Arrange — one representative ingredient per mode/factor
      // combination, spanning every branch exercised above.
      const ingredients = <Ingredient>[
        Ingredient(
          id: 'ingredient-banano',
          name: 'Banano',
          category: Category.fruta,
          measurementKind: MeasurementKind.unit,
          booleanTracked: false,
          measurementMode: MeasurementMode.count,
        ),
        Ingredient(
          id: 'ingredient-queso',
          name: 'Queso',
          category: Category.lacteo,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          measurementMode: MeasurementMode.mass,
        ),
        Ingredient(
          id: 'ingredient-avena',
          name: 'Avena',
          category: Category.cereal,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          measurementMode: MeasurementMode.mass,
          conversionFactor: 85,
        ),
        Ingredient(
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
        ),
        Ingredient(
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
        ),
        Ingredient(
          id: 'ingredient-huevo-carton-no-factor',
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
        ),
        Ingredient(
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
        ),
        Ingredient(
          id: 'ingredient-espinaca-no-factor',
          name: 'Espinaca',
          category: Category.vegetal,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          measurementMode: MeasurementMode.packageAbstract,
          package: PackageSpec(label: 'bolsa'),
        ),
        Ingredient(
          id: 'ingredient-espinaca',
          name: 'Espinaca',
          category: Category.vegetal,
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
          measurementMode: MeasurementMode.packageAbstract,
          conversionFactor: 0.1,
          package: PackageSpec(label: 'bolsa'),
        ),
      ];

      for (final ingredient in ingredients) {
        final units = recipeUnitsFor(ingredient);

        for (final unit in units) {
          // Act
          final result = converter.toStockUnit(
            recipeQuantity: Quantity(value: 1, unit: unit),
            ingredient: ingredient,
          );

          // Assert
          expect(
            result,
            isA<Right<Failure, Quantity>>(),
            reason:
                '${ingredient.id} offers ${unit.symbol} but it does not '
                'convert: $result',
          );
        }
      }
    });
  });
}
