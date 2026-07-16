import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_set_stock_sheet.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockPantryRepository extends Mock implements PantryRepository {}

class MockIngredientRepository extends Mock implements IngredientRepository {}

void main() {
  late MockPantryRepository mockPantryRepository;
  late MockIngredientRepository mockIngredientRepository;

  // mass mode: lenses g/lb, default lb. Exactly 2 lb of canonical grams
  // avoids rounding ambiguity in prefill/lens-switch assertions.
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
  const polloItem = PantryItem.quantityTracked(
    ingredientId: 'ing-pollo',
    category: Category.proteina,
    presentation: Presentation.counter(),
    stock: Quantity(value: Mass.gramsPerPound * 2, unit: Unit.gram),
  );
  final polloRow = PantryRow(item: polloItem, ingredient: pollo);

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
  const huevoItem = PantryItem.quantityTracked(
    ingredientId: 'ing-huevo',
    category: Category.proteina,
    presentation: Presentation.loose(),
    stock: Quantity(value: 7, unit: Unit.count),
  );
  final huevoRow = PantryRow(item: huevoItem, ingredient: huevo);

  // packageBase mode: bolsas (yield 1 L) + base-dimension L lens.
  const leche = Ingredient(
    id: 'ing-leche',
    name: 'Leche',
    emoji: '🥛',
    category: Category.lacteo,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    measurementMode: MeasurementMode.packageBase,
    package: PackageSpec(
      label: 'bolsas',
      yieldQty: 1,
      baseDimension: Unit.liter,
    ),
  );
  const lecheItem = PantryItem.quantityTracked(
    ingredientId: 'ing-leche',
    category: Category.lacteo,
    presentation: Presentation.package(yieldQty: 1, label: 'bolsas'),
    stock: Quantity(value: 3.5, unit: Unit.liter),
  );
  final lecheRow = PantryRow(item: lecheItem, ingredient: leche);

  // Starts at 0 L so confirming 3.5 bolsas is a genuine change, not a
  // same-value no-op (`PantryController.setStock` skips saving when the
  // new value equals the current one).
  const zeroLecheItem = PantryItem.quantityTracked(
    ingredientId: 'ing-leche',
    category: Category.lacteo,
    presentation: Presentation.package(yieldQty: 1, label: 'bolsas'),
    stock: Quantity(value: 0, unit: Unit.liter),
  );
  final zeroLecheRow = PantryRow(item: zeroLecheItem, ingredient: leche);

  // packageAbstract mode: a single decimal package lens, no base dimension.
  const lechuga = Ingredient(
    id: 'ing-lechuga',
    name: 'Lechuga',
    emoji: '🥬',
    category: Category.vegetal,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    measurementMode: MeasurementMode.packageAbstract,
    package: PackageSpec(label: 'bolsa'),
  );
  const lechugaItem = PantryItem.quantityTracked(
    ingredientId: 'ing-lechuga',
    category: Category.vegetal,
    presentation: Presentation.package(yieldQty: 1, label: 'bolsa'),
    stock: Quantity(value: 0, unit: Unit.package),
  );
  final lechugaRow = PantryRow(item: lechugaItem, ingredient: lechuga);

  setUpAll(() {
    registerFallbackValue(polloItem);
  });

  setUp(() {
    mockPantryRepository = MockPantryRepository();
    mockIngredientRepository = MockIngredientRepository();
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => const Right([polloItem, huevoItem]));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([pollo, huevo]));
  });

  Future<void> pumpSheet(WidgetTester tester, {required PantryRow row}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pantryRepositoryProvider.overrideWithValue(mockPantryRepository),
          ingredientRepositoryProvider.overrideWithValue(
            mockIngredientRepository,
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              // Watches the controller so its `list()` load resolves
              // BEFORE the sheet opens — mirrors the real app, where
              // `QuantityPantryRow` already watches this provider before a
              // user can tap the stock display to open the sheet.
              body: Consumer(
                builder: (context, ref, _) {
                  ref.watch(pantryControllerProvider);
                  return ElevatedButton(
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => SetStockSheet(row: row),
                    ),
                    child: const Text('open'),
                  );
                },
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

  testWidgets('prefills the field from current stock via the default lens '
      '(mass -> lb)', (tester) async {
    await pumpSheet(tester, row: polloRow);

    expect(find.widgetWithText(TextField, '2'), findsOneWidget);
  });

  testWidgets('prefills the field from current stock via the default lens '
      '(count -> u)', (tester) async {
    await pumpSheet(tester, row: huevoRow);

    expect(find.widgetWithText(TextField, '7'), findsOneWidget);
  });

  testWidgets('prefills the field from current stock via the default lens '
      '(packageBase -> bolsas)', (tester) async {
    await pumpSheet(tester, row: lecheRow);

    expect(find.widgetWithText(TextField, '3.5'), findsOneWidget);
  });

  testWidgets('the lens selector renders every lens for the ingredient '
      '(mass -> g, lb)', (tester) async {
    await pumpSheet(tester, row: polloRow);

    final segmented = find.byType(SegmentedButton<StockLens>);
    expect(segmented, findsOneWidget);
    expect(
      find.descendant(of: segmented, matching: find.text('g')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: segmented, matching: find.text('lb')),
      findsOneWidget,
    );
  });

  testWidgets('a single-lens mode (count) renders no lens selector', (
    tester,
  ) async {
    await pumpSheet(tester, row: huevoRow);

    expect(find.byType(SegmentedButton<StockLens>), findsNothing);
  });

  testWidgets(
    'switching lens re-scales the field to the same canonical value',
    (tester) async {
      await pumpSheet(tester, row: polloRow);

      expect(find.widgetWithText(TextField, '2'), findsOneWidget);

      await tester.tap(find.text('g'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, '907.18'), findsOneWidget);
    },
  );

  testWidgets('typing in g shows the live lb equivalent', (tester) async {
    await pumpSheet(tester, row: polloRow);

    await tester.tap(find.text('g'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '800');
    await tester.pump();

    expect(find.textContaining('1.76 lb'), findsOneWidget);
  });

  testWidgets('typing in bolsas shows the live base-unit (L) equivalent', (
    tester,
  ) async {
    await pumpSheet(tester, row: lecheRow);

    await tester.enterText(find.byType(TextField), '3.5');
    await tester.pump();

    expect(find.textContaining('3.5 L'), findsOneWidget);
  });

  testWidgets('a count-mode lens rejects a typed decimal point', (
    tester,
  ) async {
    await pumpSheet(tester, row: huevoRow);

    await tester.enterText(find.byType(TextField), '3.5');
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isNot(contains('.')));
  });

  testWidgets('fractional package entry is allowed for packageAbstract '
      '(0.5 bolsa)', (tester) async {
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => const Right([lechugaItem]));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([lechuga]));
    when(
      () => mockPantryRepository.save(any()),
    ).thenAnswer((_) async => const Right(null));

    await pumpSheet(tester, row: lechugaRow);

    await tester.enterText(find.byType(TextField), '0.5');
    await tester.pump();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    final captured = verify(
      () => mockPantryRepository.save(captureAny()),
    ).captured;
    final saved = captured.single as QuantityTrackedPantryItem;
    expect(saved.stock.value, 0.5);
  });

  testWidgets(
    'Confirm converts a typed lb value to the canonical grams (1.75 lb '
    '-> ~793.8 g)',
    (tester) async {
      when(
        () => mockPantryRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      await pumpSheet(tester, row: polloRow);

      await tester.enterText(find.byType(TextField), '1.75');
      await tester.pump();
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      final captured = verify(
        () => mockPantryRepository.save(captureAny()),
      ).captured;
      final saved = captured.single as QuantityTrackedPantryItem;
      expect(saved.stock.value, closeTo(793.8, 0.05));
    },
  );

  testWidgets('Confirm converts a typed bolsas value to canonical liters (3.5 '
      'bolsas of 1 L -> 3.5 L)', (tester) async {
    when(
      () => mockPantryRepository.save(any()),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => const Right([zeroLecheItem]));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([leche]));

    await pumpSheet(tester, row: zeroLecheRow);

    await tester.enterText(find.byType(TextField), '3.5');
    await tester.pump();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    final captured = verify(
      () => mockPantryRepository.save(captureAny()),
    ).captured;
    final saved = captured.single as QuantityTrackedPantryItem;
    expect(saved.stock.value, 3.5);
  });

  testWidgets('empty input makes confirm a no-op', (tester) async {
    await pumpSheet(tester, row: polloRow);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    await tester.tap(find.text('Confirmar'), warnIfMissed: false);
    await tester.pumpAndSettle();

    verifyNever(() => mockPantryRepository.save(any()));
  });

  testWidgets('a quick-set chip fills the field and updates the preview', (
    tester,
  ) async {
    await pumpSheet(tester, row: polloRow);

    await tester.tap(find.text('1 lb'));
    await tester.pump();

    expect(find.widgetWithText(TextField, '1'), findsOneWidget);
    expect(find.textContaining('453.59'), findsOneWidget);
  });

  testWidgets('the live preview reflects typed input', (tester) async {
    await pumpSheet(tester, row: polloRow);

    await tester.enterText(find.byType(TextField), '3');
    await tester.pump();

    expect(find.textContaining('1360.78'), findsOneWidget);
  });

  testWidgets('shows a SnackBar when the controller returns a Failure', (
    tester,
  ) async {
    final saveCompleter = Completer<Either<Failure, void>>();
    when(
      () => mockPantryRepository.save(any()),
    ).thenAnswer((_) => saveCompleter.future);

    await pumpSheet(tester, row: polloRow);

    // polloRow already sits at exactly 2 lb; type 3 lb so the value
    // genuinely changes (`PantryController.setStock` no-ops otherwise).
    await tester.enterText(find.byType(TextField), '3');
    await tester.pump();
    await tester.tap(find.text('Confirmar'));
    await tester.pump();

    saveCompleter.complete(Left(Failure(message: 'No se pudo guardar.')));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo guardar.'), findsOneWidget);
  });

  testWidgets(
    'does not overflow and keeps Confirm reachable when the keyboard is up',
    (tester) async {
      tester.view.physicalSize = const Size(400, 500);
      tester.view.devicePixelRatio = 1.0;
      // Simulates a soft keyboard covering roughly the bottom half of the
      // screen, which is the scenario that produced the 53px overflow.
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.reset);

      await pumpSheet(tester, row: polloRow);

      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(find.text('Confirmar'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // The keyboard covers the bottom 300 of the 500-tall screen, so only
      // y < 200 is actually visible above it. Confirm must be reachable
      // there, not rendered past the bottom of the (visible) screen.
      final confirmRect = tester.getRect(find.text('Confirmar'));
      expect(confirmRect.bottom, lessThanOrEqualTo(200));
    },
  );
}
