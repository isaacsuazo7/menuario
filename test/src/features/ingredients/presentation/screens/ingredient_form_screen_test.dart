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

/// Reads the current text of the [TextField] keyed [key]. Safer than
/// `find.widgetWithText` when the field's own `suffixText` (e.g. a lens
/// label like `'bolsas'`) can collide with another field's typed value.
String _textOf(WidgetTester tester, String key) {
  final field = tester.widget<TextField>(find.byKey(Key(key)));
  return field.controller!.text;
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
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    conversionFactor: 1,
    measurementMode: MeasurementMode.mass,
  );
  const polloPantry = PantryItem.quantityTracked(
    ingredientId: 'ing-pollo',
    category: Category.proteina,
    presentation: Presentation.counter(),
    stock: Quantity(value: Mass.gramsPerPound * 2, unit: Unit.gram),
  );

  // count mode: single integer-only lens u.
  const huevo = Ingredient(
    id: 'ing-huevo',
    name: 'Huevo',
    emoji: '🥚',
    category: Category.proteina,
    measurementKind: MeasurementKind.unit,
    booleanTracked: false,
    measurementMode: MeasurementMode.count,
  );
  const huevoPantry = PantryItem.quantityTracked(
    ingredientId: 'ing-huevo',
    category: Category.proteina,
    presentation: Presentation.loose(),
    stock: Quantity(value: 7, unit: Unit.count),
  );

  // packageBase mode: bolsas (yield 1 L) + base-dimension L lens.
  const leche = Ingredient(
    id: 'ing-leche',
    name: 'Leche',
    emoji: '🥛',
    category: Category.lacteo,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
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
    presentation: Presentation.package(yieldQty: 1, label: 'bolsas'),
    stock: Quantity(value: 3.5, unit: Unit.liter),
  );

  // packageAbstract mode: a single decimal package lens, no base dimension.
  const lechuga = Ingredient(
    id: 'ing-lechuga',
    name: 'Lechuga',
    emoji: '🥬',
    category: Category.vegetal,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    conversionFactor: 1,
    measurementMode: MeasurementMode.packageAbstract,
    package: PackageSpec(label: 'bolsa'),
  );
  const lechugaPantry = PantryItem.quantityTracked(
    ingredientId: 'ing-lechuga',
    category: Category.vegetal,
    presentation: Presentation.package(yieldQty: 1, label: 'bolsa'),
    stock: Quantity(value: 0.5, unit: Unit.package),
  );

  // boolean mode: no numeric stock, just a have/don't-have flag.
  const comino = Ingredient(
    id: 'ing-comino',
    name: 'Comino',
    category: Category.condimento,
    measurementKind: MeasurementKind.unit,
    booleanTracked: true,
    measurementMode: MeasurementMode.boolean,
  );
  const cominoPantry = PantryItem.booleanTracked(
    ingredientId: 'ing-comino',
    category: Category.condimento,
    presentation: Presentation.loose(),
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

    testWidgets('Por unidad shows no package fields and no have-flag', (
      tester,
    ) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Por unidad'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('ingredient-package-label-field')),
        findsNothing,
      );
      expect(find.byKey(const Key('ingredient-have-it-field')), findsNothing);
      expect(find.byKey(const Key('ingredient-stock-field')), findsOneWidget);
    });
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

    testWidgets('Por unidad has no Avanzado section at all', (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Por unidad'));
      await tester.pumpAndSettle();

      expect(find.text('Avanzado'), findsNothing);
    });

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
      expect(savedPantryItem.stock.value, 7);
      expect(savedPantryItem.stock.unit, Unit.count);
    });

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
      expect(savedIngredient.booleanTracked, isTrue);
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
                      poppedValue = await Navigator.of(context)
                          .push<String?>(
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
    testWidgets(
      'renders the "Tipo de necesidad" selector, defaulting to '
      'recipeDriven ("Por recetas") on create',
      (tester) async {
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
      },
    );

    testWidgets('prefills the existing needType on edit (weeklyFixed)', (
      tester,
    ) async {
      const espinaca = Ingredient(
        id: 'ing-espinaca',
        name: 'Espinaca',
        emoji: '🥬',
        category: Category.vegetal,
        measurementKind: MeasurementKind.bulk,
        booleanTracked: false,
        conversionFactor: 1,
        measurementMode: MeasurementMode.packageAbstract,
        package: PackageSpec(label: 'bolsa'),
        needType: NeedType.weeklyFixed,
      );
      const espinacaPantry = PantryItem.quantityTracked(
        ingredientId: 'ing-espinaca',
        category: Category.vegetal,
        presentation: Presentation.package(yieldQty: 1, label: 'bolsa'),
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
}
