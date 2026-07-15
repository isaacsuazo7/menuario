import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/shopping/presentation/widgets/shopping_list_section.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockPantryRepository extends Mock implements PantryRepository {}

class MockIngredientRepository extends Mock implements IngredientRepository {}

class MockWeekPlanRepository extends Mock implements WeekPlanRepository {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  late MockPantryRepository mockPantryRepository;
  late MockIngredientRepository mockIngredientRepository;
  late MockWeekPlanRepository mockWeekPlanRepository;
  late MockRecipeRepository mockRecipeRepository;

  const taza = Unit(symbol: 'taza', dimension: UnitDimension.volume);

  const huevo = Ingredient(
    id: 'ing-huevo',
    name: 'Huevo',
    emoji: '🥚',
    category: Category.proteina,
    measurementKind: MeasurementKind.unit,
    booleanTracked: false,
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

  const arroz = Ingredient(
    id: 'ing-arroz',
    name: 'Arroz',
    emoji: '🍚',
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

  setUp(() {
    mockPantryRepository = MockPantryRepository();
    mockIngredientRepository = MockIngredientRepository();
    mockWeekPlanRepository = MockWeekPlanRepository();
    mockRecipeRepository = MockRecipeRepository();
  });

  Future<void> pumpSection(WidgetTester tester) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          pantryRepositoryProvider.overrideWithValue(mockPantryRepository),
          ingredientRepositoryProvider.overrideWithValue(
            mockIngredientRepository,
          ),
          weekPlanRepositoryProvider.overrideWithValue(mockWeekPlanRepository),
          recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
        ],
        child: const MaterialApp(home: Scaffold(body: ShoppingListSection())),
      ),
    );
  }

  testWidgets('shows a loading indicator while upstream data loads', (
    tester,
  ) async {
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) => Future.delayed(const Duration(days: 1)));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) => Future.delayed(const Duration(days: 1)));
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) => Future.delayed(const Duration(days: 1)));
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) => Future.delayed(const Duration(days: 1)));

    await pumpSection(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows a retry-capable error state on load failure', (
    tester,
  ) async {
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => Left(Failure(message: 'No se pudo cargar.')));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([]));
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) async => const Right(WeekPlan(entries: [])));
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    await pumpSection(tester);
    await tester.pumpAndSettle();

    expect(find.text('No se pudo cargar.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('shows an empty-state message when nothing is needed', (
    tester,
  ) async {
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => const Right([]));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([]));
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) async => const Right(WeekPlan(entries: [])));
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    await pumpSection(tester);
    await tester.pumpAndSettle();

    expect(find.text('ya tenés todo lo necesario'), findsOneWidget);
  });

  testWidgets('groups rows by category, mirroring the pantry grouping', (
    tester,
  ) async {
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => const Right([]));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([huevo]));
    when(() => mockWeekPlanRepository.getActive()).thenAnswer(
      (_) async => const Right(
        WeekPlan(
          entries: [
            PlanEntry(
              day: DayOfWeek.lun,
              mealSlot: MealSlot.desayuno,
              recipeId: 'recipe-huevo',
              cooked: false,
            ),
          ],
        ),
      ),
    );
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([recipeHuevo]));

    await pumpSection(tester);
    await tester.pumpAndSettle();

    expect(find.text('Proteína'), findsOneWidget);
    expect(find.text('Huevo'), findsOneWidget);
  });

  testWidgets(
    'shows a skipped-count badge when a per-ingredient calculation fails',
    (tester) async {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([arroz]));
      when(() => mockWeekPlanRepository.getActive()).thenAnswer(
        (_) async => const Right(
          WeekPlan(
            entries: [
              PlanEntry(
                day: DayOfWeek.lun,
                mealSlot: MealSlot.almuerzo,
                recipeId: 'recipe-arroz',
                cooked: false,
              ),
            ],
          ),
        ),
      );
      when(
        () => mockRecipeRepository.list(),
      ).thenAnswer((_) async => const Right([recipeArroz]));

      await pumpSection(tester);
      await tester.pumpAndSettle();

      expect(find.textContaining('1'), findsWidgets);
      expect(find.text('ya tenés todo lo necesario'), findsNothing);
    },
  );
}
