import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredient_edit_provider.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredient_pantry_edit_provider.dart';
import 'package:menuario/src/features/ingredients/presentation/screens/ingredient_form_screen.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockIngredientRepository extends Mock implements IngredientRepository {}

class MockPantryRepository extends Mock implements PantryRepository {}

class MockIngredientCatalogRepository extends Mock
    implements IngredientCatalogRepository {}

/// Reads the current text of the text field keyed [key] (a
/// `ReactiveTextField`, which wraps its own internally-managed
/// `TextField`/`EditableText` — reading the `EditableText` descendant's
/// controller works regardless of the wrapper type). Safer than
/// `find.widgetWithText` when the field's own `suffixText` (e.g. a lens
/// label like `'bolsas'`) can collide with another field's typed value.
String _textOf(WidgetTester tester, String key) {
  final editable = tester.widget<EditableText>(
    find.descendant(
      of: find.byKey(Key(key)),
      matching: find.byType(EditableText),
    ),
  );
  return editable.controller.text;
}

void main() {
  late MockIngredientRepository mockIngredientRepository;
  late MockPantryRepository mockPantryRepository;
  late MockIngredientCatalogRepository mockIngredientCatalogRepository;

  // mass mode: lenses g/lb, default lb. Exactly 2 lb of canonical grams
  // avoids rounding ambiguity in prefill assertions.
  const pollo = Ingredient(
    id: 'ing-pollo',
    name: 'Pollo',
    emoji: '🍗',
    category: Category.proteina,
    conversionFactor: 1,
    measurementMode: MeasurementMode.mass,
  );
  const polloPantry = PantryItem.quantityTracked(
    ingredientId: 'ing-pollo',
    category: Category.proteina,
    stock: Quantity(value: Mass.gramsPerPound * 2, unit: Unit.gram),
  );

  // count mode: single integer-only lens u.
  const huevo = Ingredient(
    id: 'ing-huevo',
    name: 'Huevo',
    emoji: '🥚',
    category: Category.proteina,
    measurementMode: MeasurementMode.count,
  );
  const huevoPantry = PantryItem.quantityTracked(
    ingredientId: 'ing-huevo',
    category: Category.proteina,
    stock: Quantity(value: 7, unit: Unit.count),
  );

  // packageBase mode: bolsas (yield 1 L) + base-dimension L lens.
  const leche = Ingredient(
    id: 'ing-leche',
    name: 'Leche',
    emoji: '🥛',
    category: Category.lacteo,
    conversionFactor: 1,
    measurementMode: MeasurementMode.packageBase,
    package: PackageSpec(
      label: 'bolsas',
      yieldQty: 1,
      baseDimension: Unit.liter,
    ),
  );
  const lechePantry = PantryItem.quantityTracked(
    ingredientId: 'ing-leche',
    category: Category.lacteo,
    stock: Quantity(value: 3.5, unit: Unit.liter),
  );

  // packageAbstract mode: a single decimal package lens, no base dimension.
  const lechuga = Ingredient(
    id: 'ing-lechuga',
    name: 'Lechuga',
    emoji: '🥬',
    category: Category.vegetal,
    conversionFactor: 1,
    measurementMode: MeasurementMode.packageAbstract,
    package: PackageSpec(label: 'bolsa'),
  );
  const lechugaPantry = PantryItem.quantityTracked(
    ingredientId: 'ing-lechuga',
    category: Category.vegetal,
    stock: Quantity(value: 0.5, unit: Unit.package),
  );

  // count mode with a set conversionFactor: recipes use taza (volume),
  // pantry counts whole units — optional factor expresses stock-units per
  // recipe-unit.
  const zanahoria = Ingredient(
    id: 'ing-zanahoria',
    name: 'Zanahoria',
    emoji: '🥕',
    category: Category.vegetal,
    conversionFactor: 4,
    measurementMode: MeasurementMode.count,
  );
  const zanahoriaPantry = PantryItem.quantityTracked(
    ingredientId: 'ing-zanahoria',
    category: Category.vegetal,
    stock: Quantity(value: 12, unit: Unit.count),
  );

  // count mode WITH purchase packaging: stocked and consumed in units,
  // bought by the caja (1 caja = 8 bolsas x 3 u). The package exists only
  // so purchases round up to whole cajas — it never becomes the stock unit.
  const salmas = Ingredient(
    id: 'ing-salmas',
    name: 'Salmas',
    emoji: '🍘',
    category: Category.otro,
    measurementMode: MeasurementMode.count,
    package: PackageSpec(
      label: 'caja',
      innerLabel: 'bolsa',
      innerQty: 3,
      innerCount: 8,
    ),
  );
  const salmasPantry = PantryItem.quantityTracked(
    ingredientId: 'ing-salmas',
    category: Category.otro,
    stock: Quantity(value: 12, unit: Unit.count),
  );

  // boolean mode: no numeric stock, just a have/don't-have flag.
  const comino = Ingredient(
    id: 'ing-comino',
    name: 'Comino',
    category: Category.condimento,
    measurementMode: MeasurementMode.boolean,
  );
  const cominoPantry = PantryItem.booleanTracked(
    ingredientId: 'ing-comino',
    category: Category.condimento,
    haveIt: true,
  );

  setUpAll(() {
    registerFallbackValue(pollo);
    registerFallbackValue(polloPantry);
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

  Future<void> expandAdvanced(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Avanzado'));
    await tester.tap(find.text('Avanzado'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders the base fields with the create title', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Nuevo ingrediente'), findsOneWidget);
    expect(find.byKey(const Key('ingredient-name-field')), findsOneWidget);
    expect(find.byKey(const Key('ingredient-emoji-field')), findsOneWidget);
    expect(find.byKey(const Key('ingredient-category-field')), findsOneWidget);
    expect(find.byKey(const Key('ingredient-mode-field')), findsOneWidget);
    expect(find.text('Por peso'), findsOneWidget);
    expect(find.text('Por unidad'), findsOneWidget);
    expect(find.text('Por paquete'), findsOneWidget);
    expect(find.text('Sí-No'), findsOneWidget);
  });

  testWidgets(
    'the "¿Cómo lo medís?" selector fits cleanly on a narrow phone width, '
    'with no overflow',
    (tester) async {
      final originalSize = tester.view.physicalSize;
      final originalRatio = tester.view.devicePixelRatio;
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.physicalSize = originalSize;
        tester.view.devicePixelRatio = originalRatio;
      });

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ingredient-mode-field')), findsOneWidget);
      expect(find.text('Por peso'), findsOneWidget);
      expect(find.text('Por unidad'), findsOneWidget);
      expect(find.text('Por paquete'), findsOneWidget);
      expect(find.text('Sí-No'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'each "¿Cómo lo medís?" option carries a leading icon/emoji, so the '
    '4-way selector reads clearly even compacted',
    (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('⚖️'), findsOneWidget);
      expect(find.text('#️⃣'), findsOneWidget);
      expect(find.text('📦'), findsOneWidget);
      expect(find.text('✓'), findsOneWidget);
    },
  );

  testWidgets('shows the edit title when ingredientId is provided', (
    tester,
  ) async {
    when(
      () => mockIngredientRepository.getById('ing-pollo'),
    ).thenAnswer((_) async => const Right(pollo));
    when(
      () => mockPantryRepository.getById('ing-pollo'),
    ).thenAnswer((_) async => const Right(polloPantry));

    await pumpScreen(tester, ingredientId: 'ing-pollo');
    await tester.pumpAndSettle();

    expect(find.text('Editar ingrediente'), findsOneWidget);
  });

  testWidgets('Confirm is disabled when the name is empty', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    final confirmButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Confirmar'),
    );
    expect(confirmButton.onPressed, isNull);
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

  group('mode selector reveals conditional fields', () {
    testWidgets('Por peso (default) shows no package fields and no '
        'have-flag', (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('ingredient-package-label-field')),
        findsNothing,
      );
      expect(find.byKey(const Key('ingredient-have-it-field')), findsNothing);
      expect(find.byKey(const Key('ingredient-stock-field')), findsOneWidget);
    });

    testWidgets(
      'Por paquete reveals the package name, yield and base-unit fields',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Por paquete'));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('ingredient-package-label-field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('ingredient-package-yield-field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('ingredient-package-base-unit-field')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Por paquete reveals the OPTIONAL inner-pack fields (caja -> bolsas '
      '-> unidades)',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Por paquete'));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('ingredient-package-inner-label-field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('ingredient-package-inner-qty-field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('ingredient-package-inner-count-field')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'the inner-pack fields show the computed total, so the user never '
      'multiplies by hand',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Por paquete'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('ingredient-package-label-field')),
          'caja',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-package-inner-label-field')),
          'bolsa',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-package-inner-qty-field')),
          '3',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-package-inner-count-field')),
          '8',
        );
        await tester.pumpAndSettle();

        expect(find.text('8 bolsas × 3 u = 24 u por caja'), findsOneWidget);
      },
    );

    testWidgets(
      'Sí-No shows only the have-flag, hiding stock and package fields',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sí-No'));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('ingredient-have-it-field')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('ingredient-stock-field')), findsNothing);
        expect(
          find.byKey(const Key('ingredient-package-label-field')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'Por unidad reveals the OPTIONAL purchase-packaging block (stocked in '
      'units, bought by the caja) but no base unit and no have-flag',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Por unidad'));
        await tester.pumpAndSettle();

        expect(find.text('Cómo lo comprás (opcional)'), findsOneWidget);
        expect(
          find.byKey(const Key('ingredient-package-label-field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('ingredient-package-yield-field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('ingredient-package-inner-qty-field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('ingredient-package-inner-count-field')),
          findsOneWidget,
        );
        // The total is already in units — a base dimension is meaningless.
        expect(
          find.byKey(const Key('ingredient-package-base-unit-field')),
          findsNothing,
        );
        expect(find.byKey(const Key('ingredient-have-it-field')), findsNothing);
        expect(find.byKey(const Key('ingredient-stock-field')), findsOneWidget);
      },
    );

    testWidgets(
      'Por unidad shows the computed total for the inner pack (salmas: 1 '
      'caja = 8 bolsas x 3 u)',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Por unidad'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('ingredient-package-label-field')),
          'caja',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-package-inner-label-field')),
          'bolsa',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-package-inner-qty-field')),
          '3',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-package-inner-count-field')),
          '8',
        );
        await tester.pumpAndSettle();

        expect(find.text('8 bolsas × 3 u = 24 u por caja'), findsOneWidget);
      },
    );
  });

  group('conversionFactor behind Avanzado', () {
    testWidgets(
      'Por peso shows a collapsed Avanzado section hiding conversionFactor',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        expect(find.text('Avanzado'), findsOneWidget);
        expect(
          find.byKey(const Key('ingredient-conversion-factor-field')),
          findsNothing,
        );

        await expandAdvanced(tester);

        expect(
          find.byKey(const Key('ingredient-conversion-factor-field')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Por unidad shows a collapsed Avanzado section with an optional '
      'conversionFactor field',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Por unidad'));
        await tester.pumpAndSettle();

        expect(find.text('Avanzado'), findsOneWidget);
        expect(
          find.byKey(const Key('ingredient-conversion-factor-field')),
          findsNothing,
        );

        await expandAdvanced(tester);

        expect(
          find.byKey(const Key('ingredient-conversion-factor-field')),
          findsOneWidget,
        );
        // Matches the conversionFactor helper specifically — several other
        // count-mode labels also carry the word "opcional".
        expect(
          find.textContaining('unidades de stock por unidad'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Por peso: Confirm stays disabled until conversionFactor is filled '
      '(required, unchanged)',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('ingredient-name-field')),
          'Pollo',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-stock-field')),
          '2',
        );
        await tester.pumpAndSettle();

        final confirmButton = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Confirmar'),
        );
        expect(confirmButton.onPressed, isNull);
      },
    );

    testWidgets('Por unidad: Confirm is enabled with an empty conversionFactor '
        '(optional, does not block save)', (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('ingredient-name-field')),
        'Huevo',
      );
      await tester.tap(find.text('Por unidad'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('ingredient-stock-field')),
        '7',
      );
      await tester.pumpAndSettle();

      final confirmButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirmar'),
      );
      expect(confirmButton.onPressed, isNotNull);
    });

    testWidgets(
      'Por unidad: confirming with an empty conversionFactor persists null',
      (tester) async {
        when(
          () => mockIngredientCatalogRepository.newId(),
        ).thenReturn('ing-new-id');
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
        await tester.tap(find.text('Por unidad'));
        await tester.pumpAndSettle();
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

        expect(savedIngredient.conversionFactor, isNull);
      },
    );

    testWidgets(
      'Por unidad: typing a conversionFactor and confirming persists it',
      (tester) async {
        when(
          () => mockIngredientCatalogRepository.newId(),
        ).thenReturn('ing-new-id');
        when(
          () => mockIngredientCatalogRepository.saveWithPantry(
            ingredient: any(named: 'ingredient'),
            pantryItem: any(named: 'pantryItem'),
          ),
        ).thenAnswer((_) async => const Right(null));

        await pumpPushableScreen(tester);

        await tester.enterText(
          find.byKey(const Key('ingredient-name-field')),
          'Zanahoria',
        );
        await tester.tap(find.text('Por unidad'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('ingredient-stock-field')),
          '12',
        );
        await expandAdvanced(tester);
        await tester.enterText(
          find.byKey(const Key('ingredient-conversion-factor-field')),
          '4',
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

        expect(savedIngredient.conversionFactor, 4);
      },
    );

    testWidgets('Sí-No has no Avanzado section at all', (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sí-No'));
      await tester.pumpAndSettle();

      expect(find.text('Avanzado'), findsNothing);
    });

    testWidgets('expanding, editing and confirming persists conversionFactor', (
      tester,
    ) async {
      when(
        () => mockIngredientRepository.getById('ing-pollo'),
      ).thenAnswer((_) async => const Right(pollo));
      when(
        () => mockPantryRepository.getById('ing-pollo'),
      ).thenAnswer((_) async => const Right(polloPantry));
      when(
        () => mockIngredientCatalogRepository.saveWithPantry(
          ingredient: any(named: 'ingredient'),
          pantryItem: any(named: 'pantryItem'),
        ),
      ).thenAnswer((_) async => const Right(null));

      await pumpPushableScreen(tester, ingredientId: 'ing-pollo');
      await tester.pumpAndSettle();

      await expandAdvanced(tester);
      await tester.enterText(
        find.byKey(const Key('ingredient-conversion-factor-field')),
        '2.5',
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

      expect(savedIngredient.conversionFactor, 2.5);
    });
  });

  group('default-lens selector', () {
    testWidgets('Por peso shows g/lb lenses, editable', (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('ingredient-default-lens-field')),
        findsOneWidget,
      );
      final selector = tester.widget<SegmentedButton<StockLens>>(
        find.byKey(const Key('ingredient-default-lens-field')),
      );
      expect(selector.segments.map((s) => s.value.label), ['g', 'lb']);
      expect(selector.selected.single.label, 'lb');
    });

    testWidgets('Por unidad hides the selector (single lens)', (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Por unidad'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('ingredient-default-lens-field')),
        findsNothing,
      );
    });

    testWidgets(
      'switching lens re-scales the stock field to the same quantity',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        // Default lens is lb — type 2.
        await tester.enterText(
          find.byKey(const Key('ingredient-stock-field')),
          '2',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('g'));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(TextField, '907.18'), findsOneWidget);
      },
    );
  });

  group('atomic save', () {
    testWidgets(
      'Por peso: Confirm converts lb entry to canonical grams and saves',
      (tester) async {
        when(
          () => mockIngredientCatalogRepository.newId(),
        ).thenReturn('ing-new-id');
        when(
          () => mockIngredientCatalogRepository.saveWithPantry(
            ingredient: any(named: 'ingredient'),
            pantryItem: any(named: 'pantryItem'),
          ),
        ).thenAnswer((_) async => const Right(null));

        await pumpPushableScreen(tester);

        await tester.enterText(
          find.byKey(const Key('ingredient-name-field')),
          'Pollo',
        );
        await expandAdvanced(tester);
        await tester.enterText(
          find.byKey(const Key('ingredient-conversion-factor-field')),
          '1',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-stock-field')),
          '2',
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
        expect(savedIngredient.measurementMode, MeasurementMode.mass);
        expect(savedIngredient.defaultLensLabel, isNull);
        expect(
          savedPantryItem.stock.value,
          closeTo(Mass.gramsPerPound * 2, 0.01),
        );
        expect(savedPantryItem.stock.unit, Unit.gram);
      },
    );

    testWidgets(
      'Por peso: switching default lens to g persists the override and '
      'canonical grams',
      (tester) async {
        when(
          () => mockIngredientCatalogRepository.newId(),
        ).thenReturn('ing-new-id');
        when(
          () => mockIngredientCatalogRepository.saveWithPantry(
            ingredient: any(named: 'ingredient'),
            pantryItem: any(named: 'pantryItem'),
          ),
        ).thenAnswer((_) async => const Right(null));

        await pumpPushableScreen(tester);

        await tester.enterText(
          find.byKey(const Key('ingredient-name-field')),
          'Pollo',
        );
        await tester.tap(find.text('g'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('ingredient-stock-field')),
          '800',
        );
        await expandAdvanced(tester);
        await tester.enterText(
          find.byKey(const Key('ingredient-conversion-factor-field')),
          '1',
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

        expect(savedIngredient.defaultLensLabel, 'g');
        expect(savedPantryItem.stock.value, 800);
        expect(savedPantryItem.stock.unit, Unit.gram);
      },
    );

    testWidgets('Por unidad: Confirm saves an integer count', (tester) async {
      when(
        () => mockIngredientCatalogRepository.newId(),
      ).thenReturn('ing-new-id');
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
      await tester.tap(find.text('Por unidad'));
      await tester.pumpAndSettle();
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

      expect(savedIngredient.measurementMode, MeasurementMode.count);
      expect(savedIngredient.package, isNull);
      expect(savedPantryItem.stock.value, 7);
      expect(savedPantryItem.stock.unit, Unit.count);
    });

    testWidgets(
      'Por unidad with purchase packaging stays MeasurementMode.count and '
      'carries the package (salmas: stocked in u, bought by the caja)',
      (tester) async {
        when(
          () => mockIngredientCatalogRepository.newId(),
        ).thenReturn('ing-new-id');
        when(
          () => mockIngredientCatalogRepository.saveWithPantry(
            ingredient: any(named: 'ingredient'),
            pantryItem: any(named: 'pantryItem'),
          ),
        ).thenAnswer((_) async => const Right(null));

        await pumpPushableScreen(tester);

        await tester.enterText(
          find.byKey(const Key('ingredient-name-field')),
          'Salmas',
        );
        await tester.tap(find.text('Por unidad'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('ingredient-package-label-field')),
          'caja',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-package-inner-label-field')),
          'bolsa',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-package-inner-qty-field')),
          '3',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-package-inner-count-field')),
          '8',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-stock-field')),
          '12',
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

        expect(savedIngredient.measurementMode, MeasurementMode.count);
        final savedPackage = savedIngredient.package;
        expect(savedPackage, isNotNull);
        expect(savedPackage!.label, 'caja');
        expect(savedPackage.innerLabel, 'bolsa');
        expect(savedPackage.innerQty, 3);
        expect(savedPackage.innerCount, 8);
        expect(savedPackage.effectiveYieldQty, 24);
        expect(savedPackage.baseDimension, isNull);
        // Stock is untouched by the package: still whole units.
        expect(savedPantryItem.stock.value, 12);
        expect(savedPantryItem.stock.unit, Unit.count);
      },
    );

    testWidgets(
      'Por unidad with a half-filled inner pair keeps Confirm disabled',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('ingredient-name-field')),
          'Salmas',
        );
        await tester.tap(find.text('Por unidad'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('ingredient-package-label-field')),
          'caja',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-package-inner-qty-field')),
          '3',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-stock-field')),
          '12',
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Confirmar'));
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull,
        );

        await tester.enterText(
          find.byKey(const Key('ingredient-package-inner-count-field')),
          '8',
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Confirmar'));
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNotNull,
        );
      },
    );

    testWidgets(
      'Por paquete with yield+base unit saves packageBase and canonical L',
      (tester) async {
        when(
          () => mockIngredientCatalogRepository.newId(),
        ).thenReturn('ing-new-id');
        when(
          () => mockIngredientCatalogRepository.saveWithPantry(
            ingredient: any(named: 'ingredient'),
            pantryItem: any(named: 'pantryItem'),
          ),
        ).thenAnswer((_) async => const Right(null));

        await pumpPushableScreen(tester);

        await tester.enterText(
          find.byKey(const Key('ingredient-name-field')),
          'Leche',
        );
        await tester.tap(find.text('Por paquete'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('ingredient-package-label-field')),
          'bolsas',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-package-yield-field')),
          '1',
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.byKey(const Key('ingredient-package-base-unit-field')),
        );
        await tester.tap(
          find.byKey(const Key('ingredient-package-base-unit-field')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Litros (L)').last);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('ingredient-default-lens-field')),
          findsOneWidget,
        );

        await tester.enterText(
          find.byKey(const Key('ingredient-stock-field')),
          '3.5',
        );
        await expandAdvanced(tester);
        await tester.enterText(
          find.byKey(const Key('ingredient-conversion-factor-field')),
          '1',
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

        expect(savedIngredient.measurementMode, MeasurementMode.packageBase);
        expect(
          savedIngredient.package,
          const PackageSpec(
            label: 'bolsas',
            yieldQty: 1,
            baseDimension: Unit.liter,
          ),
        );
        expect(savedPantryItem.stock.value, 3.5);
        expect(savedPantryItem.stock.unit, Unit.liter);
      },
    );

    testWidgets(
      'Por paquete with an inner level persists it, so the total units per '
      'outer pack stay derived (salmas caja = 8 bolsas x 3 u)',
      (tester) async {
        when(
          () => mockIngredientCatalogRepository.newId(),
        ).thenReturn('ing-new-id');
        when(
          () => mockIngredientCatalogRepository.saveWithPantry(
            ingredient: any(named: 'ingredient'),
            pantryItem: any(named: 'pantryItem'),
          ),
        ).thenAnswer((_) async => const Right(null));

        await pumpPushableScreen(tester);

        await tester.enterText(
          find.byKey(const Key('ingredient-name-field')),
          'Salmas',
        );
        await tester.tap(find.text('Por paquete'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('ingredient-package-label-field')),
          'caja',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-package-inner-label-field')),
          'bolsa',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-package-inner-qty-field')),
          '3',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-package-inner-count-field')),
          '8',
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('ingredient-stock-field')),
          '1',
        );
        await expandAdvanced(tester);
        await tester.enterText(
          find.byKey(const Key('ingredient-conversion-factor-field')),
          '1',
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
        final savedPackage = (captured[0] as Ingredient).package!;

        expect(savedPackage.label, 'caja');
        expect(savedPackage.innerLabel, 'bolsa');
        expect(savedPackage.innerQty, 3);
        expect(savedPackage.innerCount, 8);
        expect(savedPackage.effectiveYieldQty, 24);
      },
    );

    testWidgets('Por paquete with no yield saves packageAbstract and canonical '
        'decimal packages', (tester) async {
      when(
        () => mockIngredientCatalogRepository.newId(),
      ).thenReturn('ing-new-id');
      when(
        () => mockIngredientCatalogRepository.saveWithPantry(
          ingredient: any(named: 'ingredient'),
          pantryItem: any(named: 'pantryItem'),
        ),
      ).thenAnswer((_) async => const Right(null));

      await pumpPushableScreen(tester);

      await tester.enterText(
        find.byKey(const Key('ingredient-name-field')),
        'Lechuga',
      );
      await tester.tap(find.text('Por paquete'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('ingredient-package-label-field')),
        'bolsa',
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('ingredient-default-lens-field')),
        findsNothing,
      );

      await tester.enterText(
        find.byKey(const Key('ingredient-stock-field')),
        '0.5',
      );
      await expandAdvanced(tester);
      await tester.enterText(
        find.byKey(const Key('ingredient-conversion-factor-field')),
        '1',
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

      expect(savedIngredient.measurementMode, MeasurementMode.packageAbstract);
      expect(savedIngredient.package, const PackageSpec(label: 'bolsa'));
      expect(savedPantryItem.stock.value, 0.5);
      expect(savedPantryItem.stock.unit, Unit.package);
    });

    testWidgets(
      'Por paquete with only yield (no base unit) keeps Confirm disabled',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('ingredient-name-field')),
          'Leche',
        );
        await tester.tap(find.text('Por paquete'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('ingredient-package-label-field')),
          'bolsas',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-package-yield-field')),
          '1',
        );
        await tester.enterText(
          find.byKey(const Key('ingredient-stock-field')),
          '1',
        );
        await expandAdvanced(tester);
        await tester.enterText(
          find.byKey(const Key('ingredient-conversion-factor-field')),
          '1',
        );
        await tester.pumpAndSettle();

        final confirmButton = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Confirmar'),
        );
        expect(confirmButton.onPressed, isNull);
      },
    );

    testWidgets('Sí-No: Confirm saves a BooleanTrackedPantryItem', (
      tester,
    ) async {
      when(
        () => mockIngredientCatalogRepository.newId(),
      ).thenReturn('ing-new-id');
      when(
        () => mockIngredientCatalogRepository.saveWithPantry(
          ingredient: any(named: 'ingredient'),
          pantryItem: any(named: 'pantryItem'),
        ),
      ).thenAnswer((_) async => const Right(null));

      await pumpPushableScreen(tester);

      await tester.enterText(
        find.byKey(const Key('ingredient-name-field')),
        'Comino',
      );
      await tester.tap(find.text('Sí-No'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tengo'));
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
      final savedPantryItem = captured[1] as BooleanTrackedPantryItem;

      expect(savedIngredient.measurementMode, MeasurementMode.boolean);
      expect(savedPantryItem.haveIt, isTrue);
    });

    testWidgets(
      'Confirm shows a SnackBar and stays on the form when saveWithPantry '
      'returns a Failure',
      (tester) async {
        when(
          () => mockIngredientCatalogRepository.newId(),
        ).thenReturn('ing-new-id');
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
        await tester.tap(find.text('Por unidad'));
        await tester.pumpAndSettle();
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
      'Confirm pops the screen with the saved ingredient id (recipe-crud '
      'BOM inline-add escape hatch relies on this return value)',
      (tester) async {
        when(
          () => mockIngredientCatalogRepository.newId(),
        ).thenReturn('ing-new-id');
        when(
          () => mockIngredientCatalogRepository.saveWithPantry(
            ingredient: any(named: 'ingredient'),
            pantryItem: any(named: 'pantryItem'),
          ),
        ).thenAnswer((_) async => const Right(null));

        String? poppedValue;
        await tester.pumpWidget(
          ProviderScope(
            overrides: overrides(),
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      poppedValue = await Navigator.of(context).push<String?>(
                        MaterialPageRoute<String?>(
                          builder: (_) => const IngredientFormScreen(),
                        ),
                      );
                    },
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

        await tester.enterText(
          find.byKey(const Key('ingredient-name-field')),
          'Huevo',
        );
        await tester.tap(find.text('Por unidad'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('ingredient-stock-field')),
          '7',
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Confirmar'));
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        expect(poppedValue, 'ing-new-id');
      },
    );
  });

  group('edit prefill', () {
    testWidgets('Por peso pre-fills mode, conversionFactor and stock lb', (
      tester,
    ) async {
      when(
        () => mockIngredientRepository.getById('ing-pollo'),
      ).thenAnswer((_) async => const Right(pollo));
      when(
        () => mockPantryRepository.getById('ing-pollo'),
      ).thenAnswer((_) async => const Right(polloPantry));

      await pumpScreen(tester, ingredientId: 'ing-pollo');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Pollo'), findsOneWidget);
      expect(find.widgetWithText(TextField, '2'), findsOneWidget);

      final modeField = tester.widget<SegmentedButton<Object?>>(
        find.byKey(const Key('ingredient-mode-field')),
      );
      expect(modeField.selected.single.toString(), contains('mass'));

      await expandAdvanced(tester);
      expect(find.widgetWithText(TextField, '1'), findsOneWidget);
    });

    testWidgets('still pre-fills when ingredientEditProvider/'
        'ingredientPantryEditProvider are already resolved/cached before the '
        'form mounts (revisit-without-fireImmediately regression guard — '
        'mirrors recipe_form_screen_test.dart)', (tester) async {
      when(
        () => mockIngredientRepository.getById('ing-pollo'),
      ).thenAnswer((_) async => const Right(pollo));
      when(
        () => mockPantryRepository.getById('ing-pollo'),
      ).thenAnswer((_) async => const Right(polloPantry));

      final container = ProviderContainer(overrides: overrides());
      addTearDown(container.dispose);

      // Resolve BOTH family providers to completion BEFORE the form ever
      // mounts — mirrors a real revisit where they're already cached as
      // AsyncData once resolved elsewhere in the session.
      await container.read(ingredientEditProvider('ing-pollo').future);
      await container.read(ingredientPantryEditProvider('ing-pollo').future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: IngredientFormScreen(ingredientId: 'ing-pollo'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Pollo'), findsOneWidget);
      expect(find.widgetWithText(TextField, '2'), findsOneWidget);
      expect(find.text('Editar ingrediente'), findsOneWidget);
    });

    testWidgets('Por paquete pre-fills package fields and pack-lens stock', (
      tester,
    ) async {
      when(
        () => mockIngredientRepository.getById('ing-leche'),
      ).thenAnswer((_) async => const Right(leche));
      when(
        () => mockPantryRepository.getById('ing-leche'),
      ).thenAnswer((_) async => const Right(lechePantry));

      await pumpScreen(tester, ingredientId: 'ing-leche');
      await tester.pumpAndSettle();

      expect(_textOf(tester, 'ingredient-package-label-field'), 'bolsas');
      expect(_textOf(tester, 'ingredient-package-yield-field'), '1');
      expect(_textOf(tester, 'ingredient-stock-field'), '3.5');
    });

    testWidgets(
      'packageAbstract pre-fills the package label and decimal stock',
      (tester) async {
        when(
          () => mockIngredientRepository.getById('ing-lechuga'),
        ).thenAnswer((_) async => const Right(lechuga));
        when(
          () => mockPantryRepository.getById('ing-lechuga'),
        ).thenAnswer((_) async => const Right(lechugaPantry));

        await pumpScreen(tester, ingredientId: 'ing-lechuga');
        await tester.pumpAndSettle();

        expect(_textOf(tester, 'ingredient-package-label-field'), 'bolsa');
        expect(_textOf(tester, 'ingredient-stock-field'), '0.5');
        expect(
          find.byKey(const Key('ingredient-default-lens-field')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'Por unidad pre-fills an existing purchase package (salmas caja = 8 '
      'bolsas x 3 u), so it can be edited instead of re-created',
      (tester) async {
        when(
          () => mockIngredientRepository.getById('ing-salmas'),
        ).thenAnswer((_) async => const Right(salmas));
        when(
          () => mockPantryRepository.getById('ing-salmas'),
        ).thenAnswer((_) async => const Right(salmasPantry));

        await pumpScreen(tester, ingredientId: 'ing-salmas');
        await tester.pumpAndSettle();

        expect(_textOf(tester, 'ingredient-package-label-field'), 'caja');
        expect(
          _textOf(tester, 'ingredient-package-inner-label-field'),
          'bolsa',
        );
        expect(_textOf(tester, 'ingredient-package-inner-qty-field'), '3');
        expect(_textOf(tester, 'ingredient-package-inner-count-field'), '8');
        expect(_textOf(tester, 'ingredient-stock-field'), '12');
        expect(find.text('8 bolsas × 3 u = 24 u por caja'), findsOneWidget);
      },
    );

    testWidgets('Sí-No pre-fills the have flag', (tester) async {
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
    });

    testWidgets(
      'Por unidad pre-fills an existing conversionFactor and does not '
      'wipe it on confirm',
      (tester) async {
        when(
          () => mockIngredientRepository.getById('ing-zanahoria'),
        ).thenAnswer((_) async => const Right(zanahoria));
        when(
          () => mockPantryRepository.getById('ing-zanahoria'),
        ).thenAnswer((_) async => const Right(zanahoriaPantry));
        when(
          () => mockIngredientCatalogRepository.saveWithPantry(
            ingredient: any(named: 'ingredient'),
            pantryItem: any(named: 'pantryItem'),
          ),
        ).thenAnswer((_) async => const Right(null));

        await pumpPushableScreen(tester, ingredientId: 'ing-zanahoria');
        await tester.pumpAndSettle();

        await expandAdvanced(tester);
        expect(_textOf(tester, 'ingredient-conversion-factor-field'), '4');

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

        expect(savedIngredient.conversionFactor, 4);
      },
    );

    testWidgets('edit Confirm reuses the existing id and never mints a '
        'new one', (tester) async {
      when(
        () => mockIngredientRepository.getById('ing-huevo'),
      ).thenAnswer((_) async => const Right(huevo));
      when(
        () => mockPantryRepository.getById('ing-huevo'),
      ).thenAnswer((_) async => const Right(huevoPantry));
      when(
        () => mockIngredientCatalogRepository.saveWithPantry(
          ingredient: any(named: 'ingredient'),
          pantryItem: any(named: 'pantryItem'),
        ),
      ).thenAnswer((_) async => const Right(null));

      await pumpPushableScreen(tester, ingredientId: 'ing-huevo');
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

      expect(savedIngredient.id, 'ing-huevo');
      expect(savedPantryItem.ingredientId, 'ing-huevo');
      verifyNever(() => mockIngredientCatalogRepository.newId());
    });
  });

  group('NeedType selector', () {
    testWidgets('renders the "Tipo de necesidad" selector, defaulting to '
        'recipeDriven ("Por recetas") on create', (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('ingredient-need-type-field')),
        findsOneWidget,
      );
      final selector = tester.widget<SegmentedButton<NeedType>>(
        find.byKey(const Key('ingredient-need-type-field')),
      );
      expect(selector.selected, {NeedType.recipeDriven});
      expect(find.text('Por recetas'), findsOneWidget);
      expect(find.text('1 por semana'), findsOneWidget);
      expect(find.text('Opcional'), findsOneWidget);
    });

    testWidgets('prefills the existing needType on edit (weeklyFixed)', (
      tester,
    ) async {
      const espinaca = Ingredient(
        id: 'ing-espinaca',
        name: 'Espinaca',
        emoji: '🥬',
        category: Category.vegetal,
        conversionFactor: 1,
        measurementMode: MeasurementMode.packageAbstract,
        package: PackageSpec(label: 'bolsa'),
        needType: NeedType.weeklyFixed,
      );
      const espinacaPantry = PantryItem.quantityTracked(
        ingredientId: 'ing-espinaca',
        category: Category.vegetal,
        stock: Quantity(value: 0.5, unit: Unit.package),
      );
      when(
        () => mockIngredientRepository.getById('ing-espinaca'),
      ).thenAnswer((_) async => const Right(espinaca));
      when(
        () => mockPantryRepository.getById('ing-espinaca'),
      ).thenAnswer((_) async => const Right(espinacaPantry));

      await pumpScreen(tester, ingredientId: 'ing-espinaca');
      await tester.pumpAndSettle();

      final selector = tester.widget<SegmentedButton<NeedType>>(
        find.byKey(const Key('ingredient-need-type-field')),
      );
      expect(selector.selected, {NeedType.weeklyFixed});
    });

    testWidgets('selecting "Opcional" and confirming persists needType', (
      tester,
    ) async {
      when(
        () => mockIngredientCatalogRepository.newId(),
      ).thenReturn('ing-new-id');
      when(
        () => mockIngredientCatalogRepository.saveWithPantry(
          ingredient: any(named: 'ingredient'),
          pantryItem: any(named: 'pantryItem'),
        ),
      ).thenAnswer((_) async => const Right(null));

      await pumpPushableScreen(tester);

      await tester.enterText(
        find.byKey(const Key('ingredient-name-field')),
        'Fresas',
      );
      await tester.tap(find.text('Por unidad'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('ingredient-stock-field')),
        '1',
      );
      await tester.ensureVisible(find.text('Opcional'));
      await tester.tap(find.text('Opcional'));
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

      expect(savedIngredient.needType, NeedType.optional);
    });
  });

  group('pantry sync on save', () {
    /// Pumps the form over a pushable route on a caller-owned [container],
    /// so the already-loaded pantry can be inspected after Confirm.
    Future<void> pumpPushableScreenOn(
      WidgetTester tester,
      ProviderContainer container,
    ) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
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
    }

    testWidgets(
      'confirming patches the loaded pantry in place instead of '
      'invalidating it (no second pantry/ingredient refetch)',
      (tester) async {
        when(
          () => mockIngredientCatalogRepository.newId(),
        ).thenReturn('ing-new-id');
        when(
          () => mockIngredientCatalogRepository.saveWithPantry(
            ingredient: any(named: 'ingredient'),
            pantryItem: any(named: 'pantryItem'),
          ),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => mockPantryRepository.list(),
        ).thenAnswer((_) async => const Right([polloPantry]));
        when(
          () => mockIngredientRepository.list(),
        ).thenAnswer((_) async => const Right([pollo]));

        final container = ProviderContainer(overrides: overrides());
        addTearDown(container.dispose);
        await container.read(pantryControllerProvider.future);

        await pumpPushableScreenOn(tester, container);

        await tester.enterText(
          find.byKey(const Key('ingredient-name-field')),
          'Huevo',
        );
        await tester.tap(find.text('Por unidad'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('ingredient-stock-field')),
          '7',
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Confirmar'));
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        // La despensa no se recarga: una sola lectura por repositorio.
        verify(() => mockPantryRepository.list()).called(1);
        verify(() => mockIngredientRepository.list()).called(1);

        final rows = container.read(pantryControllerProvider).value!;
        expect(rows.map((row) => row.item.ingredientId), [
          'ing-pollo',
          'ing-new-id',
        ]);
        expect(rows.last.ingredient.name, 'Huevo');
      },
    );
  });
}
