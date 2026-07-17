import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_mode.dart';
import 'package:menuario/src/shared/domain/value_objects/need_type.dart';
import 'package:menuario/src/shared/domain/value_objects/package_spec.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  group('Ingredient', () {
    test('a mass-mode ingredient should carry its category and '
        'per-ingredient conversion factor (recipe-unit → stock-unit)', () {
      // Arrange & Act
      const avena = Ingredient(
        id: 'ingredient-avena',
        name: 'Avena',
        category: Category.cereal,
        measurementMode: MeasurementMode.mass,
        conversionFactor: 85,
      );

      // Assert
      expect(avena.category, Category.cereal);
      expect(avena.measurementMode, MeasurementMode.mass);
      expect(avena.conversionFactor, 85);
    });

    test('a count-mode ingredient needs no conversion factor '
        '(recipe unit already equals stock unit)', () {
      // Arrange & Act
      const huevo = Ingredient(
        id: 'ingredient-huevo',
        name: 'Huevo',
        category: Category.proteina,
        measurementMode: MeasurementMode.count,
      );

      // Assert
      expect(huevo.measurementMode, MeasurementMode.count);
      expect(huevo.conversionFactor, isNull);
    });

    test('a boolean-mode ingredient carries no numeric conversion state', () {
      // Arrange & Act
      const comino = Ingredient(
        id: 'ingredient-comino',
        name: 'Comino',
        category: Category.condimento,
        measurementMode: MeasurementMode.boolean,
      );

      // Assert
      expect(comino.measurementMode, MeasurementMode.boolean);
      expect(comino.conversionFactor, isNull);
    });

    test('measurementMode defaults to mass when not specified', () {
      // Arrange & Act
      const huevo = Ingredient(
        id: 'ingredient-huevo',
        name: 'Huevo',
        category: Category.proteina,
      );

      // Assert
      expect(huevo.measurementMode, MeasurementMode.mass);
      expect(huevo.package, isNull);
      expect(huevo.defaultLensLabel, isNull);
    });

    test('an ingredient may carry the measurementMode, package and '
        'defaultLensLabel fields together', () {
      // Arrange & Act
      const leche = Ingredient(
        id: 'ingredient-leche',
        name: 'Leche',
        category: Category.lacteo,
        measurementMode: MeasurementMode.packageBase,
        package: PackageSpec(
          label: 'bolsa',
          yieldQty: 1,
          baseDimension: Unit.liter,
        ),
        defaultLensLabel: 'L',
      );

      // Assert
      expect(leche.measurementMode, MeasurementMode.packageBase);
      expect(leche.package?.label, 'bolsa');
      expect(leche.package?.yieldQty, 1);
      expect(leche.package?.baseDimension, Unit.liter);
      expect(leche.defaultLensLabel, 'L');
    });

    test('needType defaults to recipeDriven when not specified', () {
      // Arrange & Act
      const huevo = Ingredient(
        id: 'ingredient-huevo',
        name: 'Huevo',
        category: Category.proteina,
      );

      // Assert
      expect(huevo.needType, NeedType.recipeDriven);
    });

    test('an ingredient may declare weeklyFixed or optional needType', () {
      // Arrange & Act
      const espinaca = Ingredient(
        id: 'ingredient-espinaca',
        name: 'Espinaca',
        category: Category.vegetal,
        measurementMode: MeasurementMode.packageAbstract,
        package: PackageSpec(label: 'bolsa'),
        needType: NeedType.weeklyFixed,
      );
      const fresas = Ingredient(
        id: 'ingredient-fresas',
        name: 'Fresas',
        category: Category.fruta,
        measurementMode: MeasurementMode.packageAbstract,
        package: PackageSpec(label: 'caja'),
        needType: NeedType.optional,
      );

      // Assert
      expect(espinaca.needType, NeedType.weeklyFixed);
      expect(fresas.needType, NeedType.optional);
    });
  });
}
