import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_kind.dart';

void main() {
  group('Ingredient', () {
    test('a bulk ingredient should carry its category, measurement kind '
        'and per-ingredient conversion factor (recipe-unit → stock-unit)', () {
      // Arrange & Act
      const avena = Ingredient(
        id: 'ingredient-avena',
        name: 'Avena',
        category: Category.cereal,
        measurementKind: MeasurementKind.bulk,
        booleanTracked: false,
        conversionFactor: 85,
      );

      // Assert
      expect(avena.category, Category.cereal);
      expect(avena.measurementKind, MeasurementKind.bulk);
      expect(avena.booleanTracked, isFalse);
      expect(avena.conversionFactor, 85);
    });

    test('a count-exact ingredient needs no conversion factor '
        '(recipe unit already equals stock unit)', () {
      // Arrange & Act
      const huevo = Ingredient(
        id: 'ingredient-huevo',
        name: 'Huevo',
        category: Category.proteina,
        measurementKind: MeasurementKind.unit,
        booleanTracked: false,
      );

      // Assert
      expect(huevo.measurementKind, MeasurementKind.unit);
      expect(huevo.conversionFactor, isNull);
    });

    test('a boolean-tracked ingredient carries the flag', () {
      // Arrange & Act
      const comino = Ingredient(
        id: 'ingredient-comino',
        name: 'Comino',
        category: Category.condimento,
        measurementKind: MeasurementKind.bulk,
        booleanTracked: true,
      );

      // Assert
      expect(comino.booleanTracked, isTrue);
    });
  });
}
