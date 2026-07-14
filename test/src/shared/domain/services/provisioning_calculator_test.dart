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
import 'package:menuario/src/shared/domain/value_objects/measurement_kind.dart';
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
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    conversionFactor: 85,
  );

  const huevo = Ingredient(
    id: 'ingredient-huevo',
    name: 'Huevo',
    category: Category.proteina,
    measurementKind: MeasurementKind.unit,
    booleanTracked: false,
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
          measurementKind: MeasurementKind.bulk,
          booleanTracked: false,
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
          presentation: Presentation.loose(),
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
          presentation: Presentation.loose(),
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
          presentation: Presentation.package(yieldQty: 454, label: 'bolsas'),
          stock: Quantity(value: 200, unit: Unit.gram),
        );

        // Act & Assert
        expect(calculator.shouldSurfaceBooleanItem(item), isFalse);
      });
    });
  });
}
