import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/data/models/ingredient_dto.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_kind.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_mode.dart';
import 'package:menuario/src/shared/domain/value_objects/need_type.dart';
import 'package:menuario/src/shared/domain/value_objects/package_spec.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  group('IngredientDTO round-trip', () {
    test('a bulk ingredient survives fromEntity->toJson->fromJson->toEntity, '
        'id injected from doc id and absent from the map', () {
      // Arrange
      const entity = Ingredient(
        id: 'ingredient-avena',
        name: 'Avena',
        emoji: '🌾',
        category: Category.cereal,
        measurementKind: MeasurementKind.bulk,
        booleanTracked: false,
        conversionFactor: 85,
      );

      // Act
      final json = IngredientDTO.fromEntity(entity).toJson();
      final result = IngredientDTO.fromJson(
        json,
      ).toEntity(id: 'ingredient-avena');

      // Assert
      expect(result, entity);
      expect(result.emoji, '🌾');
      expect(json.containsKey('id'), isFalse);
      expect(json['category'], 'cereal');
      expect(json['measurementKind'], 'bulk');
    });

    test('a unit-tracked, boolean-tracked ingredient with no conversion '
        'factor round-trips exactly', () {
      // Arrange
      const entity = Ingredient(
        id: 'ingredient-comino',
        name: 'Comino',
        category: Category.condimento,
        measurementKind: MeasurementKind.unit,
        booleanTracked: true,
        conversionFactor: null,
      );

      // Act
      final json = IngredientDTO.fromEntity(entity).toJson();
      final result = IngredientDTO.fromJson(
        json,
      ).toEntity(id: 'ingredient-comino');

      // Assert
      expect(result, entity);
      expect(result.emoji, isNull);
      expect(json['conversionFactor'], isNull);
      expect(json['booleanTracked'], isTrue);
    });

    test('a packageBase ingredient with a default-lens override round-trips '
        'its measurementMode/package/defaultLensLabel exactly', () {
      // Arrange
      const entity = Ingredient(
        id: 'ingredient-leche',
        name: 'Leche',
        emoji: '🥛',
        category: Category.lacteo,
        measurementKind: MeasurementKind.bulk,
        booleanTracked: false,
        measurementMode: MeasurementMode.packageBase,
        package: PackageSpec(
          label: 'bolsa',
          yieldQty: 1,
          baseDimension: Unit.liter,
        ),
        defaultLensLabel: 'L',
      );

      // Act
      final json = IngredientDTO.fromEntity(entity).toJson();
      final result = IngredientDTO.fromJson(
        json,
      ).toEntity(id: 'ingredient-leche');

      // Assert
      expect(result, entity);
      expect(json['measurementMode'], 'packageBase');
      expect(json['defaultLensLabel'], 'L');
      expect(json['package'], isA<Map<String, dynamic>>());
    });

    test('a weeklyFixed ingredient round-trips its needType exactly', () {
      // Arrange
      const entity = Ingredient(
        id: 'ingredient-espinaca',
        name: 'Espinaca',
        category: Category.vegetal,
        measurementKind: MeasurementKind.bulk,
        booleanTracked: false,
        measurementMode: MeasurementMode.packageAbstract,
        package: PackageSpec(label: 'bolsa'),
        needType: NeedType.weeklyFixed,
      );

      // Act
      final json = IngredientDTO.fromEntity(entity).toJson();
      final result = IngredientDTO.fromJson(
        json,
      ).toEntity(id: 'ingredient-espinaca');

      // Assert
      expect(result, entity);
      expect(json['needType'], 'weeklyFixed');
    });

    test('an optional ingredient round-trips its needType exactly', () {
      // Arrange
      const entity = Ingredient(
        id: 'ingredient-fresas',
        name: 'Fresas',
        category: Category.fruta,
        measurementKind: MeasurementKind.bulk,
        booleanTracked: false,
        measurementMode: MeasurementMode.packageAbstract,
        package: PackageSpec(label: 'caja'),
        needType: NeedType.optional,
      );

      // Act
      final json = IngredientDTO.fromEntity(entity).toJson();
      final result = IngredientDTO.fromJson(
        json,
      ).toEntity(id: 'ingredient-fresas');

      // Assert
      expect(result, entity);
      expect(json['needType'], 'optional');
    });
  });

  group('IngredientDTO back-compat read (old-shape document, no '
      'measurementMode)', () {
    test(
      'a bulk-measurementKind old-shape doc derives measurementMode mass',
      () {
        // Arrange — no `measurementMode`/`package`/`defaultLensLabel` keys
        // at all, exactly what a pre-rollout Firestore doc looks like.
        final json = {
          'name': 'Arroz',
          'category': 'cereal',
          'measurementKind': 'bulk',
          'booleanTracked': false,
          'conversionFactor': 50,
        };

        // Act
        final result = IngredientDTO.fromJson(
          json,
        ).toEntity(id: 'ingredient-arroz');

        // Assert
        expect(result.measurementMode, MeasurementMode.mass);
        expect(result.package, isNull);
      },
    );

    test('a unit-measurementKind old-shape doc derives measurementMode '
        'count', () {
      // Arrange
      final json = {
        'name': 'Huevo',
        'category': 'proteina',
        'measurementKind': 'unit',
        'booleanTracked': false,
      };

      // Act
      final result = IngredientDTO.fromJson(
        json,
      ).toEntity(id: 'ingredient-huevo');

      // Assert
      expect(result.measurementMode, MeasurementMode.count);
    });

    test('a booleanTracked old-shape doc derives measurementMode boolean '
        'regardless of measurementKind', () {
      // Arrange
      final json = {
        'name': 'Comino',
        'category': 'condimento',
        'measurementKind': 'unit',
        'booleanTracked': true,
      };

      // Act
      final result = IngredientDTO.fromJson(
        json,
      ).toEntity(id: 'ingredient-comino');

      // Assert
      expect(result.measurementMode, MeasurementMode.boolean);
    });

    test(
      'an old-shape doc with no needType key defaults to recipeDriven',
      () {
        // Arrange
        final json = {
          'name': 'Arroz',
          'category': 'cereal',
          'measurementKind': 'bulk',
          'booleanTracked': false,
          'conversionFactor': 50,
        };

        // Act
        final result = IngredientDTO.fromJson(
          json,
        ).toEntity(id: 'ingredient-arroz');

        // Assert
        expect(result.needType, NeedType.recipeDriven);
      },
    );
  });
}
