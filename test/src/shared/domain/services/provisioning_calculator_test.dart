import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/entities/bom_line.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/entities/pantry_item.dart';
import 'package:menuario/src/shared/domain/entities/plan_entry.dart';
import 'package:menuario/src/shared/domain/entities/recipe.dart';
import 'package:menuario/src/shared/domain/entities/week_plan.dart';
import 'package:menuario/src/shared/domain/services/measurement_converter.dart';
import 'package:menuario/src/shared/domain/services/provisioning_calculator.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/day_of_week.dart';
import 'package:menuario/src/shared/domain/value_objects/meal_slot.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_mode.dart';
import 'package:menuario/src/shared/domain/value_objects/need_type.dart';
import 'package:menuario/src/shared/domain/value_objects/package_spec.dart';
import 'package:menuario/src/shared/domain/value_objects/presentation.dart';
import 'package:menuario/src/shared/domain/value_objects/purchase_quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  final calculator = ProvisioningCalculator(
    converter: const MeasurementConverter(),
  );
  const taza = Unit(symbol: 'taza', dimension: UnitDimension.volume);

  const avena = Ingredient(
    id: 'ingredient-avena',
    name: 'Avena',
    category: Category.cereal,
    measurementMode: MeasurementMode.mass,
    conversionFactor: 85,
  );

  const huevo = Ingredient(
    id: 'ingredient-huevo',
    name: 'Huevo',
    category: Category.proteina,
    measurementMode: MeasurementMode.count,
  );

  const leche = Ingredient(
    id: 'ingredient-leche',
    name: 'Leche',
    category: Category.lacteo,
    measurementMode: MeasurementMode.packageBase,
    conversionFactor: 0.24,
    package: PackageSpec(
      label: 'bolsa',
      yieldQty: 1,
      baseDimension: Unit.liter,
    ),
  );

  group('ProvisioningCalculator', () {
    group('weeklyConsumption', () {
      test('should sum BomLine quantity (converted to stock unit) x times its '
          'Recipe appears in the active WeekPlan '
          '(2 taza Avena x4 in week = 680 g)', () {
        // Arrange
        const recipe = Recipe(
          id: 'recipe-avena',
          name: 'Avena con leche',
          bomLines: [
            BomLine(
              recipeId: 'recipe-avena',
              ingredientId: 'ingredient-avena',
              quantity: Quantity(value: 2, unit: taza),
            ),
          ],
        );
        final weekPlan = WeekPlan(
          entries: [
            const PlanEntry(
              day: DayOfWeek.lun,
              mealSlot: MealSlot.desayuno,
              recipeId: 'recipe-avena',
              cooked: false,
            ),
            const PlanEntry(
              day: DayOfWeek.mar,
              mealSlot: MealSlot.desayuno,
              recipeId: 'recipe-avena',
              cooked: false,
            ),
            const PlanEntry(
              day: DayOfWeek.mie,
              mealSlot: MealSlot.desayuno,
              recipeId: 'recipe-avena',
              cooked: false,
            ),
            const PlanEntry(
              day: DayOfWeek.jue,
              mealSlot: MealSlot.desayuno,
              recipeId: 'recipe-avena',
              cooked: false,
            ),
          ],
        );

        // Act
        final result = calculator.weeklyConsumption(
          ingredient: avena,
          recipes: const [recipe],
          weekPlan: weekPlan,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(Quantity(value: 680, unit: Unit.gram)),
        );
      });

      test('should skip an "al gusto" (quantity-less) BomLine and count only '
          'the quantified ones', () {
        // Arrange — the same ingredient appears twice: once measured, once
        // "al gusto". Only the measured line may contribute a number.
        const recipe = Recipe(
          id: 'recipe-avena',
          name: 'Avena con leche',
          bomLines: [
            BomLine(
              recipeId: 'recipe-avena',
              ingredientId: 'ingredient-avena',
              quantity: Quantity(value: 2, unit: taza),
            ),
            BomLine(recipeId: 'recipe-avena', ingredientId: 'ingredient-avena'),
          ],
        );
        const weekPlan = WeekPlan(
          entries: [
            PlanEntry(
              day: DayOfWeek.lun,
              mealSlot: MealSlot.desayuno,
              recipeId: 'recipe-avena',
              cooked: false,
            ),
          ],
        );

        // Act
        final result = calculator.weeklyConsumption(
          ingredient: avena,
          recipes: const [recipe],
          weekPlan: weekPlan,
        );

        // Assert — 2 taza x 85 g, the "al gusto" line adding nothing.
        expect(
          result,
          const Right<Failure, Quantity>(Quantity(value: 170, unit: Unit.gram)),
        );
      });

      test('should report zero — never a Failure — when every BomLine for '
          'the ingredient is "al gusto"', () {
        // Arrange
        const recipe = Recipe(
          id: 'recipe-avena',
          name: 'Avena con leche',
          bomLines: [
            BomLine(recipeId: 'recipe-avena', ingredientId: 'ingredient-avena'),
          ],
        );
        const weekPlan = WeekPlan(
          entries: [
            PlanEntry(
              day: DayOfWeek.lun,
              mealSlot: MealSlot.desayuno,
              recipeId: 'recipe-avena',
              cooked: false,
            ),
          ],
        );

        // Act
        final result = calculator.weeklyConsumption(
          ingredient: avena,
          recipes: const [recipe],
          weekPlan: weekPlan,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(Quantity(value: 0, unit: Unit.gram)),
        );
      });

      test('should ignore recipes that never appear in the WeekPlan (0 '
          'consumption)', () {
        // Arrange
        const recipe = Recipe(
          id: 'recipe-avena',
          name: 'Avena con leche',
          bomLines: [
            BomLine(
              recipeId: 'recipe-avena',
              ingredientId: 'ingredient-avena',
              quantity: Quantity(value: 2, unit: taza),
            ),
          ],
        );
        const weekPlan = WeekPlan(entries: []);

        // Act
        final result = calculator.weeklyConsumption(
          ingredient: avena,
          recipes: const [recipe],
          weekPlan: weekPlan,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(Quantity(value: 0, unit: Unit.gram)),
        );
      });

      test('should default the zero-consumption unit via '
          'StockLensService.canonicalUnitFor, not the legacy measurementKind '
          'ternary (packageBase leche -> its own base dimension, liters)', () {
        // Arrange
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
        );
        const recipe = Recipe(
          id: 'recipe-leche',
          name: 'Café con leche',
          bomLines: [
            BomLine(
              recipeId: 'recipe-leche',
              ingredientId: 'ingredient-leche',
              quantity: Quantity(value: 1, unit: taza),
            ),
          ],
        );
        const weekPlan = WeekPlan(entries: []);

        // Act
        final result = calculator.weeklyConsumption(
          ingredient: leche,
          recipes: const [recipe],
          weekPlan: weekPlan,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(Quantity(value: 0, unit: Unit.liter)),
        );
      });

      test('should convert a packageBase ingredient into its base-dimension '
          'unit via the mode-aware bridge (leche 1 taza x0.24 = 0.24 L)', () {
        // Arrange
        const recipe = Recipe(
          id: 'recipe-leche',
          name: 'Café con leche',
          bomLines: [
            BomLine(
              recipeId: 'recipe-leche',
              ingredientId: 'ingredient-leche',
              quantity: Quantity(value: 1, unit: taza),
            ),
          ],
        );
        const weekPlan = WeekPlan(
          entries: [
            PlanEntry(
              day: DayOfWeek.lun,
              mealSlot: MealSlot.desayuno,
              recipeId: 'recipe-leche',
              cooked: false,
            ),
          ],
        );

        // Act
        final result = calculator.weeklyConsumption(
          ingredient: leche,
          recipes: const [recipe],
          weekPlan: weekPlan,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(
            Quantity(value: 0.24, unit: Unit.liter),
          ),
        );
      });

      test('should sum a unit-exact ingredient across a single planned '
          'appearance (huevo 17 u)', () {
        // Arrange
        const recipe = Recipe(
          id: 'recipe-huevo',
          name: 'Huevo revuelto',
          bomLines: [
            BomLine(
              recipeId: 'recipe-huevo',
              ingredientId: 'ingredient-huevo',
              quantity: Quantity(value: 17, unit: Unit.count),
            ),
          ],
        );
        const weekPlan = WeekPlan(
          entries: [
            PlanEntry(
              day: DayOfWeek.lun,
              mealSlot: MealSlot.desayuno,
              recipeId: 'recipe-huevo',
              cooked: false,
            ),
          ],
        );

        // Act
        final result = calculator.weeklyConsumption(
          ingredient: huevo,
          recipes: const [recipe],
          weekPlan: weekPlan,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(Quantity(value: 17, unit: Unit.count)),
        );
      });

      test('should propagate a Left from the underlying conversion (missing '
          'bulk factor)', () {
        // Arrange
        const noFactor = Ingredient(
          id: 'ingredient-arroz',
          name: 'Arroz',
          category: Category.cereal,
        );
        const recipe = Recipe(
          id: 'recipe-arroz',
          name: 'Arroz blanco',
          bomLines: [
            BomLine(
              recipeId: 'recipe-arroz',
              ingredientId: 'ingredient-arroz',
              quantity: Quantity(value: 2, unit: taza),
            ),
          ],
        );
        const weekPlan = WeekPlan(
          entries: [
            PlanEntry(
              day: DayOfWeek.lun,
              mealSlot: MealSlot.almuerzo,
              recipeId: 'recipe-arroz',
              cooked: false,
            ),
          ],
        );

        // Act
        final result = calculator.weeklyConsumption(
          ingredient: noFactor,
          recipes: const [recipe],
          weekPlan: weekPlan,
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
    });

    group('weeklyNeed', () {
      test('recipeDriven delegates to weeklyConsumption unchanged '
          '(2 taza Avena x4 in week = 680 g)', () {
        // Arrange
        const recipe = Recipe(
          id: 'recipe-avena',
          name: 'Avena con leche',
          bomLines: [
            BomLine(
              recipeId: 'recipe-avena',
              ingredientId: 'ingredient-avena',
              quantity: Quantity(value: 2, unit: taza),
            ),
          ],
        );
        final weekPlan = WeekPlan(
          entries: List.generate(
            4,
            (_) => const PlanEntry(
              day: DayOfWeek.lun,
              mealSlot: MealSlot.desayuno,
              recipeId: 'recipe-avena',
              cooked: false,
            ),
          ),
        );

        // Act
        final result = calculator.weeklyNeed(
          ingredient: avena,
          recipes: const [recipe],
          weekPlan: weekPlan,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(Quantity(value: 680, unit: Unit.gram)),
        );
      });

      test('weeklyFixed (packageAbstract) short-circuits to 1 whole package '
          'in Unit.package, ignoring BomLine quantities and needing no '
          'conversionFactor', () {
        // Arrange
        const espinaca = Ingredient(
          id: 'ingredient-espinaca',
          name: 'Espinaca',
          category: Category.vegetal,
          measurementMode: MeasurementMode.packageAbstract,
          package: PackageSpec(label: 'bolsa'),
          needType: NeedType.weeklyFixed,
        );
        const recipe = Recipe(
          id: 'recipe-tortilla',
          name: 'Tortilla de espinaca',
          bomLines: [
            BomLine(
              recipeId: 'recipe-tortilla',
              ingredientId: 'ingredient-espinaca',
              quantity: Quantity(value: 3, unit: taza),
            ),
          ],
        );
        const weekPlan = WeekPlan(
          entries: [
            PlanEntry(
              day: DayOfWeek.lun,
              mealSlot: MealSlot.almuerzo,
              recipeId: 'recipe-tortilla',
              cooked: false,
            ),
          ],
        );

        // Act
        final result = calculator.weeklyNeed(
          ingredient: espinaca,
          recipes: const [recipe],
          weekPlan: weekPlan,
        );

        // Assert — no missingConversionFactor Left even though espinaca
        // has no conversionFactor at all.
        expect(
          result,
          const Right<Failure, Quantity>(
            Quantity(value: 1, unit: Unit.package),
          ),
        );
      });

      test('weeklyFixed (packageBase) needs 1 whole package expressed as '
          "the package's yieldQty in its base dimension (leche bolsa=1 L)", () {
        // Arrange
        const lecheFixed = Ingredient(
          id: 'ingredient-leche-fixed',
          name: 'Leche',
          category: Category.lacteo,
          measurementMode: MeasurementMode.packageBase,
          package: PackageSpec(
            label: 'bolsa',
            yieldQty: 1,
            baseDimension: Unit.liter,
          ),
          needType: NeedType.weeklyFixed,
        );
        const recipe = Recipe(
          id: 'recipe-cafe',
          name: 'Café con leche',
          bomLines: [
            BomLine(
              recipeId: 'recipe-cafe',
              ingredientId: 'ingredient-leche-fixed',
              quantity: Quantity(value: 1, unit: taza),
            ),
          ],
        );
        const weekPlan = WeekPlan(
          entries: [
            PlanEntry(
              day: DayOfWeek.lun,
              mealSlot: MealSlot.desayuno,
              recipeId: 'recipe-cafe',
              cooked: false,
            ),
          ],
        );

        // Act
        final result = calculator.weeklyNeed(
          ingredient: lecheFixed,
          recipes: const [recipe],
          weekPlan: weekPlan,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(Quantity(value: 1, unit: Unit.liter)),
        );
      });

      test('weeklyFixed (packageBase) with a two-level package needs the '
          'DERIVED total, not a stale yieldQty', () {
        // Arrange — 2 u x 10 bolsas = 20, while yieldQty still says 7.
        const galletasFixed = Ingredient(
          id: 'ingredient-galletas-fixed',
          name: 'Galletas de arroz',
          category: Category.cereal,
          measurementMode: MeasurementMode.packageBase,
          package: PackageSpec(
            label: 'caja',
            yieldQty: 7,
            baseDimension: Unit.count,
            innerLabel: 'bolsa',
            innerQty: 2,
            innerCount: 10,
          ),
          needType: NeedType.weeklyFixed,
        );

        // Act
        final result = calculator.weeklyNeed(
          ingredient: galletasFixed,
          recipes: const [],
          weekPlan: const WeekPlan(entries: []),
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(Quantity(value: 20, unit: Unit.count)),
        );
      });
    });

    group('shortfall', () {
      test('should compute a positive shortfall (680 g consumption, 200 g '
          'stock -> 480 g)', () {
        // Arrange
        const consumption = Quantity(value: 680, unit: Unit.gram);
        const stock = Quantity(value: 200, unit: Unit.gram);

        // Act
        final result = calculator.shortfall(
          ingredient: avena,
          consumption: consumption,
          stock: stock,
        );

        // Assert
        expect(
          result,
          const Right<Failure, Quantity>(Quantity(value: 480, unit: Unit.gram)),
        );
      });

      test(
        'should never go negative (500 g consumption, 600 g stock -> 0)',
        () {
          // Arrange
          const consumption = Quantity(value: 500, unit: Unit.gram);
          const stock = Quantity(value: 600, unit: Unit.gram);

          // Act
          final result = calculator.shortfall(
            ingredient: avena,
            consumption: consumption,
            stock: stock,
          );

          // Assert
          expect(
            result,
            const Right<Failure, Quantity>(Quantity(value: 0, unit: Unit.gram)),
          );
        },
      );

      test('should return Left(negativeStock) for a negative stock value', () {
        // Arrange
        const consumption = Quantity(value: 680, unit: Unit.gram);
        const stock = Quantity(value: -5, unit: Unit.gram);

        // Act
        final result = calculator.shortfall(
          ingredient: avena,
          consumption: consumption,
          stock: stock,
        );

        // Assert
        expect(
          result,
          isA<Left<Failure, Quantity>>().having(
            (left) => left.value.code,
            'code',
            'negativeStock',
          ),
        );
      });

      test('should return Left(unitMismatch) instead of silently mixing '
          'units when consumption and stock are expressed in different '
          'units (680 g consumption vs 2 taza stock)', () {
        // Arrange
        const consumption = Quantity(value: 680, unit: Unit.gram);
        const stock = Quantity(value: 2, unit: taza);

        // Act
        final result = calculator.shortfall(
          ingredient: avena,
          consumption: consumption,
          stock: stock,
        );

        // Assert
        expect(
          result,
          isA<Left<Failure, Quantity>>().having(
            (left) => left.value.code,
            'code',
            'unitMismatch',
          ),
        );
      });

      test('should compute a real shortfall for a packageBase ingredient '
          'once consumption and stock both land in the base-dimension unit '
          '(leche 0.24 L consumption, 0.10 L stock -> 0.14 L, no '
          'unitMismatch)', () {
        // Arrange
        const consumption = Quantity(value: 0.24, unit: Unit.liter);
        const stock = Quantity(value: 0.10, unit: Unit.liter);

        // Act
        final result = calculator.shortfall(
          ingredient: leche,
          consumption: consumption,
          stock: stock,
        );

        // Assert — a closeTo tolerance absorbs the 0.24 - 0.10 binary
        // floating-point noise (0.13999999999999999), not a real precision
        // loss.
        expect(result, isA<Right<Failure, Quantity>>());
        final quantity = (result as Right<Failure, Quantity>).value;
        expect(quantity.value, closeTo(0.14, 1e-9));
        expect(quantity.unit, Unit.liter);
      });
    });

    group('purchaseQuantity', () {
      test('should translate a positive shortfall into a package purchase '
          '(huevo target 17, stock 6 -> shortfall 11 -> 1 cartón (15 u))', () {
        // Arrange
        const shortfall = Quantity(value: 11, unit: Unit.count);

        // Act
        final result = calculator.purchaseQuantity(
          shortfall: shortfall,
          presentation: const Presentation.package(
            yieldQty: 15,
            label: 'cartón (15 u)',
          ),
        );

        // Assert
        expect(
          result,
          const Right<Failure, PurchaseQuantity?>(
            PurchaseQuantity.packagePurchase(packs: 1, label: 'cartón (15 u)'),
          ),
        );
      });

      test('should translate a positive shortfall into a loose purchase '
          '(plátano target 9, stock 3 -> shortfall 6 -> 6 unidades)', () {
        // Arrange
        const shortfall = Quantity(value: 6, unit: Unit.count);

        // Act
        final result = calculator.purchaseQuantity(
          shortfall: shortfall,
          presentation: const Presentation.loose(),
        );

        // Assert
        expect(
          result,
          const Right<Failure, PurchaseQuantity?>(
            PurchaseQuantity.loosePurchase(units: 6),
          ),
        );
      });

      test('should return Right(null) when there is no shortfall to buy', () {
        // Arrange
        const shortfall = Quantity(value: 0, unit: Unit.gram);

        // Act
        final result = calculator.purchaseQuantity(
          shortfall: shortfall,
          presentation: const Presentation.package(
            yieldQty: 454,
            label: 'bolsas',
          ),
        );

        // Assert
        expect(result, const Right<Failure, PurchaseQuantity?>(null));
      });
    });

    group('shouldSurfaceBooleanItem', () {
      test('a "no tengo" boolean-tracked item (Comino) should be surfaced '
          '(true)', () {
        // Arrange
        const comino = PantryItem.booleanTracked(
          ingredientId: 'ingredient-comino',
          category: Category.condimento,
          haveIt: false,
        );

        // Act & Assert
        expect(calculator.shouldSurfaceBooleanItem(comino), isTrue);
      });

      test('a "tengo" boolean-tracked item (Sal) should be omitted from the '
          'buy list (false)', () {
        // Arrange
        const sal = PantryItem.booleanTracked(
          ingredientId: 'ingredient-sal',
          category: Category.condimento,
          haveIt: true,
        );

        // Act & Assert
        expect(calculator.shouldSurfaceBooleanItem(sal), isFalse);
      });

      test('a quantity-tracked item should never be surfaced through the '
          'boolean path', () {
        // Arrange
        const item = PantryItem.quantityTracked(
          ingredientId: 'ingredient-avena',
          category: Category.cereal,
          stock: Quantity(value: 200, unit: Unit.gram),
        );

        // Act & Assert
        expect(calculator.shouldSurfaceBooleanItem(item), isFalse);
      });
    });
  });
}
