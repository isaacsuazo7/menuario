import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/shopping/presentation/models/shopping_row.dart';
import 'package:menuario/src/features/shopping/presentation/providers/shopping_list_builder.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  final calculator = ProvisioningCalculator(
    converter: const MeasurementConverter(),
  );
  final builder = ShoppingListBuilder(calculator: calculator);

  const taza = Unit(symbol: 'taza', dimension: UnitDimension.volume);

  const huevo = Ingredient(
    id: 'ing-huevo',
    name: 'Huevo',
    category: Category.proteina,
    measurementMode: MeasurementMode.count,
  );

  const platano = Ingredient(
    id: 'ing-platano',
    name: 'Plátano',
    category: Category.fruta,
    measurementMode: MeasurementMode.count,
  );

  const arroz = Ingredient(
    id: 'ing-arroz',
    name: 'Arroz',
    category: Category.cereal,
  );

  const comino = Ingredient(
    id: 'ing-comino',
    name: 'Comino',
    category: Category.condimento,
  );
  const cominoItem = PantryItem.booleanTracked(
    ingredientId: 'ing-comino',
    category: Category.condimento,
    haveIt: false,
  );

  const sal = Ingredient(
    id: 'ing-sal',
    name: 'Sal',
    category: Category.condimento,
  );
  const salItem = PantryItem.booleanTracked(
    ingredientId: 'ing-sal',
    category: Category.condimento,
    haveIt: true,
  );

  group('ShoppingListBuilder', () {
    test(
      'a short ingredient appears with the correct purchase quantity display',
      () {
        // Arrange — weekly need pinned from the (already-tested) shared
        // weekly-consumption join: platano's single recipe demands 9.
        const platanoStock = PantryItem.quantityTracked(
          ingredientId: 'ing-platano',
          category: Category.fruta,
          stock: Quantity(value: 3, unit: Unit.count),
        );

        // Act
        final result = builder.build(
          weeklyConsumptionByIngredient: const {
            'ing-platano': Right(Quantity(value: 9, unit: Unit.count)),
          },
          ingredientsById: const {'ing-platano': platano},
          pantryByIngredientId: const {'ing-platano': platanoStock},
        );

        // Assert
        expect(result.skipped, isEmpty);
        expect(result.groups, hasLength(1));
        expect(result.groups.single.category, Category.fruta);
        final row = result.groups.single.rows.single;
        expect(row.ingredientId, 'ing-platano');
        expect(row.quantityDisplay, '6 unidades');
        expect(row.isBooleanTracked, isFalse);
        expect(row.pantryExists, isTrue);
      },
    );

    test('a fully-stocked ingredient does not appear', () {
      // Arrange
      const huevoStock = PantryItem.quantityTracked(
        ingredientId: 'ing-huevo',
        category: Category.proteina,
        stock: Quantity(value: 20, unit: Unit.count),
      );

      // Act
      final result = builder.build(
        weeklyConsumptionByIngredient: const {
          'ing-huevo': Right(Quantity(value: 17, unit: Unit.count)),
        },
        ingredientsById: const {'ing-huevo': huevo},
        pantryByIngredientId: const {'ing-huevo': huevoStock},
      );

      // Assert
      expect(result.groups, isEmpty);
      expect(result.skipped, isEmpty);
    });

    test('an ingredient absent from the pantry is assumed at zero stock and '
        'appears at full demand', () {
      // Act
      final result = builder.build(
        weeklyConsumptionByIngredient: const {
          'ing-huevo': Right(Quantity(value: 17, unit: Unit.count)),
        },
        ingredientsById: const {'ing-huevo': huevo},
        pantryByIngredientId: const {},
      );

      // Assert
      expect(result.groups, hasLength(1));
      final row = result.groups.single.rows.single;
      expect(row.ingredientId, 'ing-huevo');
      expect(row.quantityDisplay, '17 unidades');
      expect(row.pantryExists, isFalse);
      expect(row.pantryItem, isA<QuantityTrackedPantryItem>());
    });

    test(
      'a "no tengo" boolean-tracked item is surfaced without a quantity',
      () {
        // Act
        final result = builder.build(
          weeklyConsumptionByIngredient: const {},
          ingredientsById: const {'ing-comino': comino},
          pantryByIngredientId: const {'ing-comino': cominoItem},
        );

        // Assert
        expect(result.groups, hasLength(1));
        final row = result.groups.single.rows.single;
        expect(row.isBooleanTracked, isTrue);
        expect(row.quantityDisplay, isNull);
      },
    );

    test('a "tengo" boolean-tracked item does not appear', () {
      // Act
      final result = builder.build(
        weeklyConsumptionByIngredient: const {},
        ingredientsById: const {'ing-sal': sal},
        pantryByIngredientId: const {'ing-sal': salItem},
      );

      // Assert
      expect(result.groups, isEmpty);
    });

    test('a per-ingredient calculation failure skips only that row and the '
        'rest still render', () {
      // Arrange
      const platanoStock = PantryItem.quantityTracked(
        ingredientId: 'ing-platano',
        category: Category.fruta,
        stock: Quantity(value: 3, unit: Unit.count),
      );

      // Act
      final result = builder.build(
        weeklyConsumptionByIngredient: <String, Either<Failure, Quantity>>{
          'ing-arroz': Left(Failure.missingConversionFactor('Arroz')),
          'ing-platano': const Right(Quantity(value: 9, unit: Unit.count)),
        },
        ingredientsById: const {'ing-arroz': arroz, 'ing-platano': platano},
        pantryByIngredientId: const {'ing-platano': platanoStock},
      );

      // Assert
      expect(result.skipped, hasLength(1));
      expect(result.skipped.single.name, 'Arroz');
      expect(result.skipped.single.reason, SkipReason.needsFactor);
      expect(result.groups, hasLength(1));
      expect(result.groups.single.rows.single.ingredientId, 'ing-platano');
    });

    test('a shortfall unit-mismatch skip is named with the "other" reason, '
        'distinct from a missing-factor skip', () {
      // Arrange — arroz's stock is tracked in taza while its (already
      // converted) weekly need is expressed in grams, mirroring a real
      // shortfall unitMismatch.
      const mismatchedStock = PantryItem.quantityTracked(
        ingredientId: 'ing-arroz',
        category: Category.cereal,
        stock: Quantity(value: 2, unit: taza),
      );
      const arrozWithFactor = Ingredient(
        id: 'ing-arroz',
        name: 'Arroz',
        category: Category.cereal,
        measurementMode: MeasurementMode.mass,
        conversionFactor: 50,
      );

      // Act
      final result = builder.build(
        weeklyConsumptionByIngredient: const {
          'ing-arroz': Right(Quantity(value: 100, unit: Unit.gram)),
        },
        ingredientsById: const {'ing-arroz': arrozWithFactor},
        pantryByIngredientId: const {'ing-arroz': mismatchedStock},
      );

      // Assert
      expect(result.skipped, hasLength(1));
      expect(result.skipped.single.name, 'Arroz');
      expect(result.skipped.single.reason, SkipReason.other);
      expect(result.groups, isEmpty);
    });

    test('rows are grouped by Category.values fixed order, empty categories '
        'omitted', () {
      // Act
      final result = builder.build(
        weeklyConsumptionByIngredient: const {
          'ing-huevo': Right(Quantity(value: 17, unit: Unit.count)),
          'ing-platano': Right(Quantity(value: 9, unit: Unit.count)),
        },
        ingredientsById: const {
          'ing-huevo': huevo,
          'ing-platano': platano,
          'ing-comino': comino,
        },
        pantryByIngredientId: const {'ing-comino': cominoItem},
      );

      // Assert — Category.values order: proteina, vegetal, fruta, cereal,
      // lacteo, condimento, semilla, otro.
      expect(result.groups.map((g) => g.category), [
        Category.proteina,
        Category.fruta,
        Category.condimento,
      ]);
    });

    test('a weekly-consumption entry whose ingredient is unresolved is '
        'skipped without a crash (defensive — should not happen once '
        'ingredientsById is complete)', () {
      // Act
      final result = builder.build(
        weeklyConsumptionByIngredient: const {
          'ing-unknown': Right(Quantity(value: 1, unit: Unit.count)),
        },
        ingredientsById: const {},
        pantryByIngredientId: const {},
      );

      // Assert
      expect(result.groups, isEmpty);
      expect(result.skipped, isEmpty);
    });

    test('a weeklyFixed ingredient with less than 1 package in stock appears '
        'in Comprar (buy 1) — the map already carries its 1-package need, '
        'the builder needs no NeedType branching of its own', () {
      // Arrange
      const espinaca = Ingredient(
        id: 'ing-espinaca',
        name: 'Espinaca',
        category: Category.vegetal,
        measurementMode: MeasurementMode.packageAbstract,
        package: PackageSpec(label: 'bolsa'),
        needType: NeedType.weeklyFixed,
      );
      const espinacaStock = PantryItem.quantityTracked(
        ingredientId: 'ing-espinaca',
        category: Category.vegetal,
        stock: Quantity(value: 0.5, unit: Unit.package),
      );

      // Act
      final result = builder.build(
        weeklyConsumptionByIngredient: const {
          'ing-espinaca': Right(Quantity(value: 1, unit: Unit.package)),
        },
        ingredientsById: const {'ing-espinaca': espinaca},
        pantryByIngredientId: const {'ing-espinaca': espinacaStock},
      );

      // Assert
      expect(result.skipped, isEmpty);
      final row = result.groups.single.rows.single;
      expect(row.ingredientId, 'ing-espinaca');
      expect(row.quantityDisplay, '1 bolsa');
    });
  });

  group('presentationForPurchase adapter', () {
    test('mass mode maps to a counter presentation', () {
      const ingredient = Ingredient(
        id: 'ing-carne',
        name: 'Carne molida',
        category: Category.proteina,
        measurementMode: MeasurementMode.mass,
      );

      expect(presentationForPurchase(ingredient), const Presentation.counter());
    });

    test('count mode maps to a loose presentation', () {
      const ingredient = Ingredient(
        id: 'ing-platano',
        name: 'Plátano',
        category: Category.fruta,
        measurementMode: MeasurementMode.count,
      );

      expect(presentationForPurchase(ingredient), const Presentation.loose());
    });

    test('packageBase mode maps to a package presentation using its yieldQty '
        'and label', () {
      const ingredient = Ingredient(
        id: 'ing-leche',
        name: 'Leche',
        category: Category.lacteo,
        measurementMode: MeasurementMode.packageBase,
        package: PackageSpec(
          label: 'bolsa',
          yieldQty: 1,
          baseDimension: Unit.liter,
        ),
      );

      expect(
        presentationForPurchase(ingredient),
        const Presentation.package(yieldQty: 1, label: 'bolsa'),
      );
    });

    test('packageAbstract mode maps to a single-pack package presentation '
        'using its label', () {
      const ingredient = Ingredient(
        id: 'ing-lechuga',
        name: 'Lechuga',
        category: Category.vegetal,
        measurementMode: MeasurementMode.packageAbstract,
        package: PackageSpec(label: 'bolsa'),
      );

      expect(
        presentationForPurchase(ingredient),
        const Presentation.package(yieldQty: 1, label: 'bolsa'),
      );
    });
  });
}
