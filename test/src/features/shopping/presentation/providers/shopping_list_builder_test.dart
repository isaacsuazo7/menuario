import 'package:flutter_test/flutter_test.dart';
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
    measurementKind: MeasurementKind.unit,
    booleanTracked: false,
    measurementMode: MeasurementMode.count,
  );
  const recipeHuevo = Recipe(
    id: 'recipe-huevo',
    name: 'Huevo revuelto',
    bomLines: [
      BomLine(
        recipeId: 'recipe-huevo',
        ingredientId: 'ing-huevo',
        quantity: Quantity(value: 17, unit: Unit.count),
      ),
    ],
  );

  const platano = Ingredient(
    id: 'ing-platano',
    name: 'Plátano',
    category: Category.fruta,
    measurementKind: MeasurementKind.unit,
    booleanTracked: false,
  );
  const recipePlatano = Recipe(
    id: 'recipe-platano',
    name: 'Plátano frito',
    bomLines: [
      BomLine(
        recipeId: 'recipe-platano',
        ingredientId: 'ing-platano',
        quantity: Quantity(value: 9, unit: Unit.count),
      ),
    ],
  );

  const arroz = Ingredient(
    id: 'ing-arroz',
    name: 'Arroz',
    category: Category.cereal,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
  );
  const recipeArroz = Recipe(
    id: 'recipe-arroz',
    name: 'Arroz blanco',
    bomLines: [
      BomLine(
        recipeId: 'recipe-arroz',
        ingredientId: 'ing-arroz',
        quantity: Quantity(value: 2, unit: taza),
      ),
    ],
  );

  const comino = Ingredient(
    id: 'ing-comino',
    name: 'Comino',
    category: Category.condimento,
    measurementKind: MeasurementKind.unit,
    booleanTracked: true,
  );
  const cominoItem = PantryItem.booleanTracked(
    ingredientId: 'ing-comino',
    category: Category.condimento,
    presentation: Presentation.loose(),
    haveIt: false,
  );

  const sal = Ingredient(
    id: 'ing-sal',
    name: 'Sal',
    category: Category.condimento,
    measurementKind: MeasurementKind.unit,
    booleanTracked: true,
  );
  const salItem = PantryItem.booleanTracked(
    ingredientId: 'ing-sal',
    category: Category.condimento,
    presentation: Presentation.loose(),
    haveIt: true,
  );

  group('ShoppingListBuilder', () {
    test(
      'a short ingredient appears with the correct purchase quantity display',
      () {
        // Arrange
        const weekPlan = WeekPlan(
          entries: [
            PlanEntry(
              day: DayOfWeek.lun,
              mealSlot: MealSlot.almuerzo,
              recipeId: 'recipe-platano',
              cooked: false,
            ),
          ],
        );
        const platanoStock = PantryItem.quantityTracked(
          ingredientId: 'ing-platano',
          category: Category.fruta,
          presentation: Presentation.loose(),
          stock: Quantity(value: 3, unit: Unit.count),
        );

        // Act
        final result = builder.build(
          weekPlan: weekPlan,
          recipes: const [recipePlatano],
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
      const huevoStock = PantryItem.quantityTracked(
        ingredientId: 'ing-huevo',
        category: Category.proteina,
        presentation: Presentation.package(
          yieldQty: 15,
          label: 'cartón (15 u)',
        ),
        stock: Quantity(value: 20, unit: Unit.count),
      );

      // Act
      final result = builder.build(
        weekPlan: weekPlan,
        recipes: const [recipeHuevo],
        ingredientsById: const {'ing-huevo': huevo},
        pantryByIngredientId: const {'ing-huevo': huevoStock},
      );

      // Assert
      expect(result.groups, isEmpty);
      expect(result.skipped, isEmpty);
    });

    test('an ingredient absent from the pantry is assumed at zero stock and '
        'appears at full demand', () {
      // Arrange
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
      final result = builder.build(
        weekPlan: weekPlan,
        recipes: const [recipeHuevo],
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
          weekPlan: const WeekPlan(entries: []),
          recipes: const [],
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
        weekPlan: const WeekPlan(entries: []),
        recipes: const [],
        ingredientsById: const {'ing-sal': sal},
        pantryByIngredientId: const {'ing-sal': salItem},
      );

      // Assert
      expect(result.groups, isEmpty);
    });

    test('a per-ingredient calculation failure skips only that row and the '
        'rest still render', () {
      // Arrange
      const weekPlan = WeekPlan(
        entries: [
          PlanEntry(
            day: DayOfWeek.lun,
            mealSlot: MealSlot.almuerzo,
            recipeId: 'recipe-arroz',
            cooked: false,
          ),
          PlanEntry(
            day: DayOfWeek.lun,
            mealSlot: MealSlot.cena,
            recipeId: 'recipe-platano',
            cooked: false,
          ),
        ],
      );
      const platanoStock = PantryItem.quantityTracked(
        ingredientId: 'ing-platano',
        category: Category.fruta,
        presentation: Presentation.loose(),
        stock: Quantity(value: 3, unit: Unit.count),
      );

      // Act
      final result = builder.build(
        weekPlan: weekPlan,
        recipes: const [recipeArroz, recipePlatano],
        ingredientsById: const {'ing-arroz': arroz, 'ing-platano': platano},
        pantryByIngredientId: const {'ing-platano': platanoStock},
      );

      // Assert
      expect(result.skipped, ['ing-arroz']);
      expect(result.groups, hasLength(1));
      expect(result.groups.single.rows.single.ingredientId, 'ing-platano');
    });

    test('rows are grouped by Category.values fixed order, empty categories '
        'omitted', () {
      // Arrange
      const weekPlan = WeekPlan(
        entries: [
          PlanEntry(
            day: DayOfWeek.lun,
            mealSlot: MealSlot.desayuno,
            recipeId: 'recipe-huevo',
            cooked: false,
          ),
          PlanEntry(
            day: DayOfWeek.lun,
            mealSlot: MealSlot.almuerzo,
            recipeId: 'recipe-platano',
            cooked: false,
          ),
        ],
      );

      // Act
      final result = builder.build(
        weekPlan: weekPlan,
        recipes: const [recipeHuevo, recipePlatano],
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
  });

  group('presentationForPurchase adapter', () {
    test('mass mode maps to a counter presentation', () {
      const ingredient = Ingredient(
        id: 'ing-carne',
        name: 'Carne molida',
        category: Category.proteina,
        measurementKind: MeasurementKind.bulk,
        booleanTracked: false,
        measurementMode: MeasurementMode.mass,
      );

      expect(presentationForPurchase(ingredient), const Presentation.counter());
    });

    test('count mode maps to a loose presentation', () {
      const ingredient = Ingredient(
        id: 'ing-platano',
        name: 'Plátano',
        category: Category.fruta,
        measurementKind: MeasurementKind.unit,
        booleanTracked: false,
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
        measurementKind: MeasurementKind.bulk,
        booleanTracked: false,
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
        measurementKind: MeasurementKind.bulk,
        booleanTracked: false,
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
