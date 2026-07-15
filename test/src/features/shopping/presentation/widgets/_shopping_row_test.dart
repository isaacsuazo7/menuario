import 'package:dartz/dartz.dart' hide Unit, State;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_set_stock_sheet.dart';
import 'package:menuario/src/features/shopping/presentation/models/shopping_row.dart';
import 'package:menuario/src/features/shopping/presentation/widgets/_shopping_row.dart';
import 'package:menuario/src/features/shopping/presentation/widgets/shopping_list_section.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockPantryRepository extends Mock implements PantryRepository {}

class MockIngredientRepository extends Mock implements IngredientRepository {}

class _ToggleHost extends StatefulWidget {
  const _ToggleHost({required this.row});

  final ShoppingRow row;

  @override
  State<_ToggleHost> createState() => _ToggleHostState();
}

class _ToggleHostState extends State<_ToggleHost> {
  bool showRow = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (showRow) ShoppingRowTile(row: widget.row),
          TextButton(
            onPressed: () => setState(() => showRow = !showRow),
            child: const Text('toggle-visibility'),
          ),
        ],
      ),
    );
  }
}

void main() {
  late MockPantryRepository mockPantryRepository;
  late MockIngredientRepository mockIngredientRepository;

  const platano = Ingredient(
    id: 'ing-platano',
    name: 'Plátano',
    emoji: '🍌',
    category: Category.fruta,
    measurementKind: MeasurementKind.unit,
    booleanTracked: false,
  );
  const platanoItem = PantryItem.quantityTracked(
    ingredientId: 'ing-platano',
    category: Category.fruta,
    presentation: Presentation.loose(),
    stock: Quantity(value: 3, unit: Unit.count),
  );
  final platanoRow = ShoppingRow(
    ingredientId: 'ing-platano',
    ingredient: platano,
    category: Category.fruta,
    isBooleanTracked: false,
    pantryItem: platanoItem,
    pantryExists: true,
    quantityDisplay: '6 unidades',
  );

  const comino = Ingredient(
    id: 'ing-comino',
    name: 'Comino',
    emoji: '🌿',
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
  final cominoRow = ShoppingRow(
    ingredientId: 'ing-comino',
    ingredient: comino,
    category: Category.condimento,
    isBooleanTracked: true,
    pantryItem: cominoItem,
    pantryExists: true,
  );

  setUpAll(() {
    registerFallbackValue(cominoItem);
  });

  setUp(() {
    mockPantryRepository = MockPantryRepository();
    mockIngredientRepository = MockIngredientRepository();
  });

  Future<void> pumpRow(WidgetTester tester, ShoppingRow row) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pantryRepositoryProvider.overrideWithValue(mockPantryRepository),
          ingredientRepositoryProvider.overrideWithValue(
            mockIngredientRepository,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: ShoppingRowTile(row: row)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  bool titleHasStrikethrough(WidgetTester tester, String name) {
    final text = tester.widget<Text>(find.text(name));
    return text.style?.decoration == TextDecoration.lineThrough;
  }

  group('quantity-tracked row', () {
    setUp(() {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([platanoItem]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([platano]));
    });

    testWidgets('ticking applies a strikethrough, purely as local state', (
      tester,
    ) async {
      await pumpRow(tester, platanoRow);

      expect(titleHasStrikethrough(tester, 'Plátano'), isFalse);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(titleHasStrikethrough(tester, 'Plátano'), isTrue);
      verifyNever(() => mockPantryRepository.save(any()));
    });

    testWidgets(
      'ticks reset when the row remounts (leaving and returning to Comprar)',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              pantryRepositoryProvider.overrideWithValue(mockPantryRepository),
              ingredientRepositoryProvider.overrideWithValue(
                mockIngredientRepository,
              ),
            ],
            child: MaterialApp(home: _ToggleHost(row: platanoRow)),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();
        expect(titleHasStrikethrough(tester, 'Plátano'), isTrue);

        // Leave Comprar — the row (and its checkoff listener) unmounts.
        await tester.tap(find.text('toggle-visibility'));
        await tester.pumpAndSettle();
        expect(find.byType(Checkbox), findsNothing);

        // Return to Comprar — a fresh row, ticks reset.
        await tester.tap(find.text('toggle-visibility'));
        await tester.pumpAndSettle();

        expect(titleHasStrikethrough(tester, 'Plátano'), isFalse);
      },
    );
  });

  group('boolean-tracked row', () {
    setUp(() {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([cominoItem]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([comino]));
      when(
        () => mockPantryRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));
    });

    testWidgets('renders quantity-less, tick-only', (tester) async {
      await pumpRow(tester, cominoRow);

      expect(find.text('Comino'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('unidades'), findsNothing);
    });

    testWidgets('tapping it calls toggleHave, never SetStockSheet', (
      tester,
    ) async {
      await pumpRow(tester, cominoRow);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      final captured = verify(
        () => mockPantryRepository.save(captureAny()),
      ).captured;
      final saved = captured.single as BooleanTrackedPantryItem;
      expect(saved.haveIt, isTrue);
      expect(find.byType(SetStockSheet), findsNothing);
    });
  });

  group('restock hand-off (quantity-tracked)', () {
    testWidgets(
      'tapping an existing item opens SetStockSheet directly, prefilled '
      'with the real pantry row',
      (tester) async {
        when(
          () => mockPantryRepository.list(),
        ).thenAnswer((_) async => const Right([platanoItem]));
        when(
          () => mockIngredientRepository.list(),
        ).thenAnswer((_) async => const Right([platano]));

        await pumpRow(tester, platanoRow);
        expect(find.byType(SetStockSheet), findsNothing);

        await tester.tap(find.text('6 unidades'));
        await tester.pumpAndSettle();

        expect(find.byType(SetStockSheet), findsOneWidget);
        expect(find.widgetWithText(TextField, '3'), findsOneWidget);
        verifyNever(() => mockPantryRepository.save(any()));
      },
    );

    testWidgets(
      'tapping an assume-zero item persists a stock-0 pantry item before '
      'opening SetStockSheet',
      (tester) async {
        var pantryItems = const <PantryItem>[];
        when(
          () => mockPantryRepository.list(),
        ).thenAnswer((_) async => Right(pantryItems));
        when(
          () => mockIngredientRepository.list(),
        ).thenAnswer((_) async => const Right([platano]));
        when(() => mockPantryRepository.save(any())).thenAnswer((
          invocation,
        ) async {
          final saved = invocation.positionalArguments.first as PantryItem;
          pantryItems = [saved];
          return const Right(null);
        });

        const absentPlatanoItem = PantryItem.quantityTracked(
          ingredientId: 'ing-platano',
          category: Category.fruta,
          presentation: Presentation.loose(),
          stock: Quantity(value: 0, unit: Unit.count),
        );
        final absentRow = ShoppingRow(
          ingredientId: 'ing-platano',
          ingredient: platano,
          category: Category.fruta,
          isBooleanTracked: false,
          pantryItem: absentPlatanoItem,
          pantryExists: false,
          quantityDisplay: '9 unidades',
        );

        await pumpRow(tester, absentRow);
        expect(find.byType(SetStockSheet), findsNothing);

        await tester.tap(find.text('9 unidades'));
        await tester.pumpAndSettle();

        final captured = verify(
          () => mockPantryRepository.save(captureAny()),
        ).captured;
        final saved = captured.single as QuantityTrackedPantryItem;
        expect(saved.ingredientId, 'ing-platano');
        expect(saved.stock.value, 0);
        expect(find.byType(SetStockSheet), findsOneWidget);
      },
    );

    testWidgets(
      'confirming a covering stock via SetStockSheet self-clears the item '
      'once ShoppingListSection recomputes',
      (tester) async {
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
        final mockWeekPlanRepository = _MockWeekPlanRepository();
        final mockRecipeRepository = _MockRecipeRepository();
        var pantryItems = const <PantryItem>[];
        when(
          () => mockPantryRepository.list(),
        ).thenAnswer((_) async => Right(pantryItems));
        when(
          () => mockIngredientRepository.list(),
        ).thenAnswer((_) async => const Right([platano]));
        when(
          () => mockWeekPlanRepository.getActive(),
        ).thenAnswer((_) async => const Right(weekPlan));
        when(
          () => mockRecipeRepository.list(),
        ).thenAnswer((_) async => const Right([recipePlatano]));
        when(() => mockPantryRepository.save(any())).thenAnswer((
          invocation,
        ) async {
          final saved = invocation.positionalArguments.first as PantryItem;
          pantryItems = [
            for (final item in pantryItems)
              if (item.ingredientId != saved.ingredientId) item,
            saved,
          ];
          return const Right(null);
        });

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              pantryRepositoryProvider.overrideWithValue(mockPantryRepository),
              ingredientRepositoryProvider.overrideWithValue(
                mockIngredientRepository,
              ),
              weekPlanRepositoryProvider.overrideWithValue(
                mockWeekPlanRepository,
              ),
              recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
            ],
            child: const MaterialApp(
              home: Scaffold(body: ShoppingListSection()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('9 unidades'), findsOneWidget);

        await tester.tap(find.text('9 unidades'));
        await tester.pumpAndSettle();
        expect(find.byType(SetStockSheet), findsOneWidget);

        await tester.enterText(find.byType(TextField), '9');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        expect(find.byType(SetStockSheet), findsNothing);
        expect(find.text('9 unidades'), findsNothing);
        expect(find.text('ya tenés todo lo necesario'), findsOneWidget);
      },
    );
  });
}

class _MockWeekPlanRepository extends Mock implements WeekPlanRepository {}

class _MockRecipeRepository extends Mock implements RecipeRepository {}
