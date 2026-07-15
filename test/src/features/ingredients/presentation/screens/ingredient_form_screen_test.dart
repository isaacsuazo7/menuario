import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/ingredients/presentation/screens/ingredient_form_screen.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockIngredientRepository extends Mock implements IngredientRepository {}

class MockPantryRepository extends Mock implements PantryRepository {}

class MockIngredientCatalogRepository extends Mock
    implements IngredientCatalogRepository {}

void main() {
  late MockIngredientRepository mockIngredientRepository;
  late MockPantryRepository mockPantryRepository;
  late MockIngredientCatalogRepository mockIngredientCatalogRepository;

  const avena = Ingredient(
    id: 'ing-avena',
    name: 'Avena',
    emoji: '🥣',
    category: Category.cereal,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    conversionFactor: 85,
  );
  const avenaPantry = PantryItem.quantityTracked(
    ingredientId: 'ing-avena',
    category: Category.cereal,
    presentation: Presentation.package(yieldQty: 454, label: 'bolsa'),
    stock: Quantity(value: 908, unit: Unit.gram),
  );

  const comino = Ingredient(
    id: 'ing-comino',
    name: 'Comino',
    category: Category.condimento,
    measurementKind: MeasurementKind.unit,
    booleanTracked: true,
  );
  const cominoPantry = PantryItem.booleanTracked(
    ingredientId: 'ing-comino',
    category: Category.condimento,
    presentation: Presentation.loose(),
    haveIt: true,
  );

  setUpAll(() {
    registerFallbackValue(avena);
    registerFallbackValue(avenaPantry);
  });

  setUp(() {
    mockIngredientRepository = MockIngredientRepository();
    mockPantryRepository = MockPantryRepository();
    mockIngredientCatalogRepository = MockIngredientCatalogRepository();
  });

  overrides() => [
    ingredientRepositoryProvider.overrideWithValue(mockIngredientRepository),
    pantryRepositoryProvider.overrideWithValue(mockPantryRepository),
    ingredientCatalogRepositoryProvider.overrideWithValue(
      mockIngredientCatalogRepository,
    ),
  ];

  Future<void> pumpScreen(WidgetTester tester, {String? ingredientId}) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          home: IngredientFormScreen(ingredientId: ingredientId),
        ),
      ),
    );
  }

  /// Pumps the form behind a pushable route so pop-on-success is
  /// observable (mirrors the Cancel test's navigator setup).
  Future<void> pumpPushableScreen(
    WidgetTester tester, {
    String? ingredientId,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        IngredientFormScreen(ingredientId: ingredientId),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders the 6 ingredient fields with the create title', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Nuevo ingrediente'), findsOneWidget);
    expect(find.byKey(const Key('ingredient-name-field')), findsOneWidget);
    expect(find.byKey(const Key('ingredient-emoji-field')), findsOneWidget);
    expect(find.byKey(const Key('ingredient-category-field')), findsOneWidget);
    expect(
      find.byKey(const Key('ingredient-measurement-kind-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('ingredient-boolean-tracked-field')),
      findsOneWidget,
    );
  });

  testWidgets('shows the edit title when ingredientId is provided', (
    tester,
  ) async {
    when(
      () => mockIngredientRepository.getById('ing-avena'),
    ).thenAnswer((_) async => const Right(avena));
    when(
      () => mockPantryRepository.getById('ing-avena'),
    ).thenAnswer((_) async => const Right(avenaPantry));

    await pumpScreen(tester, ingredientId: 'ing-avena');
    await tester.pumpAndSettle();

    expect(find.text('Editar ingrediente'), findsOneWidget);
  });

  testWidgets(
    'conversionFactor is hidden for unit and shown for bulk',
    (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      // Default measurementKind is unit — conversionFactor hidden.
      expect(
        find.byKey(const Key('ingredient-conversion-factor-field')),
        findsNothing,
      );

      await tester.tap(find.text('Granel'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('ingredient-conversion-factor-field')),
        findsOneWidget,
      );

      await tester.tap(find.text('Unidad'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('ingredient-conversion-factor-field')),
        findsNothing,
      );
    },
  );

  testWidgets('Confirm is disabled when the name is empty', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    final confirmButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Confirmar'),
    );
    expect(confirmButton.onPressed, isNull);
  });

  testWidgets(
    'Confirm is disabled for a bulk ingredient with an empty conversionFactor',
    (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('ingredient-name-field')),
        'Avena',
      );
      await tester.tap(find.text('Granel'));
      await tester.pumpAndSettle();

      final confirmButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirmar'),
      );
      expect(confirmButton.onPressed, isNull);
    },
  );

  testWidgets('Confirm is enabled for a valid unit ingredient', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('ingredient-name-field')),
      'Huevo',
    );
    await tester.enterText(
      find.byKey(const Key('ingredient-stock-field')),
      '5',
    );
    await tester.pumpAndSettle();

    final confirmButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Confirmar'),
    );
    expect(confirmButton.onPressed, isNotNull);
  });

  testWidgets('Confirm is enabled for a valid bulk ingredient with a '
      'conversionFactor', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('ingredient-name-field')),
      'Avena',
    );
    await tester.tap(find.text('Granel'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('ingredient-conversion-factor-field')),
      '85',
    );
    await tester.enterText(
      find.byKey(const Key('ingredient-stock-field')),
      '10',
    );
    await tester.pumpAndSettle();

    final confirmButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Confirmar'),
    );
    expect(confirmButton.onPressed, isNotNull);
  });

  testWidgets('edit mode pre-fills the 6 fields from the existing '
      'ingredient', (tester) async {
    when(
      () => mockIngredientRepository.getById('ing-avena'),
    ).thenAnswer((_) async => const Right(avena));
    when(
      () => mockPantryRepository.getById('ing-avena'),
    ).thenAnswer((_) async => const Right(avenaPantry));

    await pumpScreen(tester, ingredientId: 'ing-avena');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Avena'), findsOneWidget);
    expect(find.widgetWithText(TextField, '🥣'), findsOneWidget);
    expect(find.widgetWithText(TextField, '85'), findsOneWidget);
    expect(find.text('Cereal'), findsOneWidget);

    final confirmButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Confirmar'),
    );
    expect(confirmButton.onPressed, isNotNull);
  });

  testWidgets('Cancel pops the screen without writing', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ingredientRepositoryProvider.overrideWithValue(
            mockIngredientRepository,
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const IngredientFormScreen(),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo ingrediente'), findsOneWidget);

    await tester.ensureVisible(find.text('Cancelar'));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo ingrediente'), findsNothing);
    expect(find.text('open'), findsOneWidget);
    verifyNever(() => mockIngredientRepository.save(any()));
  });

  group('pantry-adaptive section', () {
    testWidgets(
      'booleanTracked=true shows the have-flag control defaulting to '
      'No tengo, and hides presentation/stock fields',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('ingredient-boolean-tracked-field')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('ingredient-have-it-field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('ingredient-presentation-field')),
          findsNothing,
        );
        expect(find.byKey(const Key('ingredient-stock-field')), findsNothing);

        final haveFlag = tester.widget<SegmentedButton<bool>>(
          find.byKey(const Key('ingredient-have-it-field')),
        );
        expect(haveFlag.selected, {false});
      },
    );

    testWidgets(
      'booleanTracked=false shows the presentation selector and stock '
      'field',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('ingredient-presentation-field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('ingredient-stock-field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('ingredient-have-it-field')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'presentation=package shows the inline yieldQty and label fields',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('ingredient-yield-qty-field')),
          findsNothing,
        );
        expect(find.byKey(const Key('ingredient-label-field')), findsNothing);

        await tester.tap(find.text('Paquete'));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('ingredient-yield-qty-field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('ingredient-label-field')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Confirm is disabled for a package presentation missing yieldQty or '
      'label',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('ingredient-name-field')),
          'Avena',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-stock-field')),
          '10',
        );
        await tester.tap(find.text('Paquete'));
        await tester.pumpAndSettle();

        var confirmButton = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Confirmar'),
        );
        expect(confirmButton.onPressed, isNull);

        await tester.enterText(
          find.byKey(const Key('ingredient-yield-qty-field')),
          '454',
        );
        await tester.pumpAndSettle();

        confirmButton = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Confirmar'),
        );
        expect(confirmButton.onPressed, isNull);

        await tester.enterText(
          find.byKey(const Key('ingredient-label-field')),
          'bolsa',
        );
        await tester.pumpAndSettle();

        confirmButton = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Confirmar'),
        );
        expect(confirmButton.onPressed, isNotNull);
      },
    );
  });

  group('atomic save', () {
    testWidgets(
      'Confirm mints one id, builds the matching Ingredient + PantryItem, '
      'calls saveWithPantry, and pops on success',
      (tester) async {
        when(() => mockIngredientCatalogRepository.newId()).thenReturn(
          'ing-new-id',
        );
        when(
          () => mockIngredientCatalogRepository.saveWithPantry(
            ingredient: any(named: 'ingredient'),
            pantryItem: any(named: 'pantryItem'),
          ),
        ).thenAnswer((_) async => const Right(null));

        await pumpPushableScreen(tester);

        await tester.enterText(
          find.byKey(const Key('ingredient-name-field')),
          'Huevo',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-stock-field')),
          '7',
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Confirmar'));
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        final captured = verify(
          () => mockIngredientCatalogRepository.saveWithPantry(
            ingredient: captureAny(named: 'ingredient'),
            pantryItem: captureAny(named: 'pantryItem'),
          ),
        ).captured;
        final savedIngredient = captured[0] as Ingredient;
        final savedPantryItem = captured[1] as QuantityTrackedPantryItem;

        expect(savedIngredient.id, 'ing-new-id');
        expect(savedPantryItem.ingredientId, 'ing-new-id');
        expect(savedPantryItem.stock.value, 7);
        expect(savedPantryItem.stock.unit, Unit.count);

        expect(find.text('Nuevo ingrediente'), findsNothing);
        expect(find.text('open'), findsOneWidget);
      },
    );

    testWidgets(
      'Confirm shows a SnackBar and stays on the form when saveWithPantry '
      'returns a Failure',
      (tester) async {
        when(() => mockIngredientCatalogRepository.newId()).thenReturn(
          'ing-new-id',
        );
        when(
          () => mockIngredientCatalogRepository.saveWithPantry(
            ingredient: any(named: 'ingredient'),
            pantryItem: any(named: 'pantryItem'),
          ),
        ).thenAnswer(
          (_) async => const Left(Failure(message: 'No se pudo guardar.')),
        );

        await pumpPushableScreen(tester);

        await tester.enterText(
          find.byKey(const Key('ingredient-name-field')),
          'Huevo',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-stock-field')),
          '7',
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Confirmar'));
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        expect(find.text('No se pudo guardar.'), findsOneWidget);
        expect(find.text('Nuevo ingrediente'), findsOneWidget);
      },
    );

    testWidgets(
      'edit mode pre-fills the pantry section from the existing '
      'quantity-tracked PantryItem',
      (tester) async {
        when(
          () => mockIngredientRepository.getById('ing-avena'),
        ).thenAnswer((_) async => const Right(avena));
        when(
          () => mockPantryRepository.getById('ing-avena'),
        ).thenAnswer((_) async => const Right(avenaPantry));

        await pumpScreen(tester, ingredientId: 'ing-avena');
        await tester.pumpAndSettle();

        final presentationField = tester.widget<SegmentedButton<Object?>>(
          find.byKey(const Key('ingredient-presentation-field')),
        );
        expect(presentationField.selected.single.toString(), contains(
          'package',
        ));
        expect(find.widgetWithText(TextField, '454'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'bolsa'), findsOneWidget);
        expect(find.widgetWithText(TextField, '2'), findsOneWidget);
      },
    );

    testWidgets(
      'edit mode pre-fills the have flag for a boolean-tracked PantryItem',
      (tester) async {
        when(
          () => mockIngredientRepository.getById('ing-comino'),
        ).thenAnswer((_) async => const Right(comino));
        when(
          () => mockPantryRepository.getById('ing-comino'),
        ).thenAnswer((_) async => const Right(cominoPantry));

        await pumpScreen(tester, ingredientId: 'ing-comino');
        await tester.pumpAndSettle();

        final haveFlag = tester.widget<SegmentedButton<bool>>(
          find.byKey(const Key('ingredient-have-it-field')),
        );
        expect(haveFlag.selected, {true});
      },
    );

    testWidgets('edit Confirm reuses the existing id and never mints a new '
        'one', (tester) async {
      when(
        () => mockIngredientRepository.getById('ing-avena'),
      ).thenAnswer((_) async => const Right(avena));
      when(
        () => mockPantryRepository.getById('ing-avena'),
      ).thenAnswer((_) async => const Right(avenaPantry));
      when(
        () => mockIngredientCatalogRepository.saveWithPantry(
          ingredient: any(named: 'ingredient'),
          pantryItem: any(named: 'pantryItem'),
        ),
      ).thenAnswer((_) async => const Right(null));

      await pumpPushableScreen(tester, ingredientId: 'ing-avena');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Confirmar'));
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      final captured = verify(
        () => mockIngredientCatalogRepository.saveWithPantry(
          ingredient: captureAny(named: 'ingredient'),
          pantryItem: captureAny(named: 'pantryItem'),
        ),
      ).captured;
      final savedIngredient = captured[0] as Ingredient;
      final savedPantryItem = captured[1] as QuantityTrackedPantryItem;

      expect(savedIngredient.id, 'ing-avena');
      expect(savedPantryItem.ingredientId, 'ing-avena');
      verifyNever(() => mockIngredientCatalogRepository.newId());
    });

    testWidgets(
      'edit Confirm persists a changed field value under the reused id',
      (tester) async {
        when(
          () => mockIngredientRepository.getById('ing-avena'),
        ).thenAnswer((_) async => const Right(avena));
        when(
          () => mockPantryRepository.getById('ing-avena'),
        ).thenAnswer((_) async => const Right(avenaPantry));
        when(
          () => mockIngredientCatalogRepository.saveWithPantry(
            ingredient: any(named: 'ingredient'),
            pantryItem: any(named: 'pantryItem'),
          ),
        ).thenAnswer((_) async => const Right(null));

        await pumpPushableScreen(tester, ingredientId: 'ing-avena');
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('ingredient-name-field')),
          'Avena integral',
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Confirmar'));
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        final captured = verify(
          () => mockIngredientCatalogRepository.saveWithPantry(
            ingredient: captureAny(named: 'ingredient'),
            pantryItem: captureAny(named: 'pantryItem'),
          ),
        ).captured;
        final savedIngredient = captured[0] as Ingredient;

        expect(savedIngredient.name, 'Avena integral');
        expect(savedIngredient.id, 'ing-avena');
      },
    );
  });
}
