import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_quantity_pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_set_stock_sheet.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockPantryRepository extends Mock implements PantryRepository {}

class MockIngredientRepository extends Mock implements IngredientRepository {}

void main() {
  late MockPantryRepository mockPantryRepository;
  late MockIngredientRepository mockIngredientRepository;

  // mass mode, no clean-fraction match: pinned "1.76 lb" (800 g), same
  // pinned value as `stock_lens_service_test.dart`'s own formatStock case.
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
    stock: Quantity(value: 800, unit: Unit.gram),
  );
  final polloRow = PantryRow(item: polloItem, ingredient: pollo);

  // Exactly 1.75 lb, so a quarter-lb step lands on a clean 2 lb.
  const polloStepItem = PantryItem.quantityTracked(
    ingredientId: 'ing-pollo',
    category: Category.proteina,
    presentation: Presentation.counter(),
    stock: Quantity(value: 793.7866475, unit: Unit.gram),
  );
  final polloStepRow = PantryRow(item: polloStepItem, ingredient: pollo);

  // count mode: a single integer-only lens u, steps by exactly 1.
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

  const zeroHuevoItem = PantryItem.quantityTracked(
    ingredientId: 'ing-huevo',
    category: Category.proteina,
    presentation: Presentation.loose(),
    stock: Quantity(value: 0, unit: Unit.count),
  );
  final zeroHuevoRow = PantryRow(item: zeroHuevoItem, ingredient: huevo);

  // packageBase mode: bolsas (yield 1 L) + base-dimension L lens, steps by
  // a QUARTER pack (0.25 L) — not a whole pack, per the new lens-driven
  // stockStep (replaces the old whole-presentation-unit step).
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
  const zeroLecheItem = PantryItem.quantityTracked(
    ingredientId: 'ing-leche',
    category: Category.lacteo,
    presentation: Presentation.package(yieldQty: 1, label: 'bolsas'),
    stock: Quantity(value: 0, unit: Unit.liter),
  );
  final zeroLecheRow = PantryRow(item: zeroLecheItem, ingredient: leche);

  // packageAbstract mode: an exact-half canonical value renders the "½"
  // glyph.
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
    stock: Quantity(value: 0.5, unit: Unit.package),
  );
  final lechugaRow = PantryRow(item: lechugaItem, ingredient: lechuga);

  // packageAbstract mode: a value with no clean-fraction match renders a
  // percent instead.
  const requeson = Ingredient(
    id: 'ing-requeson',
    name: 'Requesón',
    emoji: '🧀',
    category: Category.lacteo,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    measurementMode: MeasurementMode.packageAbstract,
    package: PackageSpec(label: 'pana'),
  );
  const requesonItem = PantryItem.quantityTracked(
    ingredientId: 'ing-requeson',
    category: Category.lacteo,
    presentation: Presentation.package(yieldQty: 1, label: 'pana'),
    stock: Quantity(value: 0.37, unit: Unit.package),
  );
  final requesonRow = PantryRow(item: requesonItem, ingredient: requeson);

  setUpAll(() {
    registerFallbackValue(polloItem);
  });

  setUp(() {
    mockPantryRepository = MockPantryRepository();
    mockIngredientRepository = MockIngredientRepository();
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => const Right([polloItem]));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([pollo]));
  });

  Future<void> pumpRow(WidgetTester tester, {PantryRow? withRow}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pantryRepositoryProvider.overrideWithValue(mockPantryRepository),
          ingredientRepositoryProvider.overrideWithValue(
            mockIngredientRepository,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: QuantityPantryRow(row: withRow ?? polloRow)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'renders emoji, name and smart-formatted stock display, with no error '
    'tint on the row',
    (tester) async {
      await pumpRow(tester);

      expect(find.text('🍗'), findsOneWidget);
      expect(find.text('Pollo'), findsOneWidget);
      expect(find.text('1.76 lb'), findsOneWidget);
      expect(find.text('🟢 Tengo'), findsNothing);
      final tile = tester.widget<ListTile>(find.byType(ListTile));
      expect(tile.tileColor, isNull);
    },
  );

  testWidgets('renders a count item as a whole-unit count (7 u)', (
    tester,
  ) async {
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => const Right([huevoItem]));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([huevo]));

    await pumpRow(tester, withRow: huevoRow);

    expect(find.text('7 u'), findsOneWidget);
  });

  testWidgets(
    'renders a packageAbstract item with a clean-fraction glyph (½ bolsa)',
    (tester) async {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([lechugaItem]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([lechuga]));

      await pumpRow(tester, withRow: lechugaRow);

      expect(find.text('½ bolsa'), findsOneWidget);
    },
  );

  testWidgets(
    'renders a packageAbstract item with no clean-fraction match as a '
    'percent (37% pana)',
    (tester) async {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([requesonItem]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([requeson]));

      await pumpRow(tester, withRow: requesonRow);

      expect(find.text('37% pana'), findsOneWidget);
    },
  );

  testWidgets('tapping + on a mass item steps by a quarter pound, landing on a '
      'clean whole value (trimmed, no trailing zeros)', (tester) async {
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => const Right([polloStepItem]));
    when(
      () => mockPantryRepository.save(any()),
    ).thenAnswer((_) async => const Right(null));

    await pumpRow(tester, withRow: polloStepRow);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('2 lb'), findsOneWidget);

    await tester.pumpAndSettle();

    final captured = verify(
      () => mockPantryRepository.save(captureAny()),
    ).captured;
    final saved = captured.single as QuantityTrackedPantryItem;
    expect(saved.stock.value, closeTo(907.1847400, 1e-6));
  });

  testWidgets(
    'tapping + on a packageBase item steps by a QUARTER pack (0.25 L), '
    'not a whole pack',
    (tester) async {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([zeroLecheItem]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([leche]));
      when(
        () => mockPantryRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      await pumpRow(tester, withRow: zeroLecheRow);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('¼ bolsas'), findsOneWidget);

      await tester.pumpAndSettle();

      final captured = verify(
        () => mockPantryRepository.save(captureAny()),
      ).captured;
      final saved = captured.single as QuantityTrackedPantryItem;
      expect(saved.stock.value, closeTo(0.25, 1e-9));
    },
  );

  testWidgets(
    'tapping - on a count item at 0 stays at 0 and never calls save',
    (tester) async {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([zeroHuevoItem]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([huevo]));

      await pumpRow(tester, withRow: zeroHuevoRow);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(find.text('0 u'), findsOneWidget);
      verifyNever(() => mockPantryRepository.save(any()));
    },
  );

  testWidgets('tapping + on a count item advances by exactly 1', (
    tester,
  ) async {
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => const Right([huevoItem]));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([huevo]));
    when(
      () => mockPantryRepository.save(any()),
    ).thenAnswer((_) async => const Right(null));

    await pumpRow(tester, withRow: huevoRow);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('8 u'), findsOneWidget);

    await tester.pumpAndSettle();

    final captured = verify(
      () => mockPantryRepository.save(captureAny()),
    ).captured;
    final saved = captured.single as QuantityTrackedPantryItem;
    expect(saved.stock.value, 8);
  });

  testWidgets('shows a SnackBar and reverts the stock when save fails', (
    tester,
  ) async {
    // A Completer keeps save() pending until we explicitly resolve it, so
    // the transient optimistic frame is deterministic rather than racing
    // against the mock's own microtask resolution.
    final saveCompleter = Completer<Either<Failure, void>>();
    when(
      () => mockPantryRepository.save(any()),
    ).thenAnswer((_) => saveCompleter.future);

    await pumpRow(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('2.01 lb'), findsOneWidget);

    saveCompleter.complete(Left(Failure(message: 'No se pudo guardar.')));
    await tester.pumpAndSettle();

    expect(find.text('1.76 lb'), findsOneWidget);
    expect(find.text('No se pudo guardar.'), findsOneWidget);
  });

  testWidgets(
    'tapping the stock display opens the real SetStockSheet, prefilled',
    (tester) async {
      await pumpRow(tester);

      expect(find.byType(SetStockSheet), findsNothing);

      await tester.tap(find.text('1.76 lb'));
      await tester.pumpAndSettle();

      expect(find.byType(SetStockSheet), findsOneWidget);
      expect(find.widgetWithText(TextField, '1.76'), findsOneWidget);
    },
  );

  testWidgets(
    'a sub-display residual stock ("0 lb") tints the row instead of '
    'showing a red No tengo pill (effective-zero overrides raw positivity)',
    (tester) async {
      // 1 g is nonzero raw stock, but rounds to zero at the mass-mode
      // default lens's 2dp display precision — `formatStock` trims that
      // "0.00" down to a bare "0" (see `_trimTrailingZeros`).
      const residualItem = PantryItem.quantityTracked(
        ingredientId: 'ing-pollo',
        category: Category.proteina,
        presentation: Presentation.counter(),
        stock: Quantity(value: 1, unit: Unit.gram),
      );
      final residualRow = PantryRow(item: residualItem, ingredient: pollo);

      // Overrides the default (unrelated) 800 g `polloItem` fixture, which
      // shares this same ingredient id and would otherwise shadow
      // `residualItem` once the controller's live state resolves.
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([residualItem]));

      await pumpRow(tester, withRow: residualRow);

      expect(find.text('0 lb'), findsOneWidget);
      expect(find.text('🔴 No tengo'), findsNothing);
      expect(find.text('🟢 Tengo'), findsNothing);
      final tile = tester.widget<ListTile>(find.byType(ListTile));
      expect(tile.tileColor, isNotNull);
    },
  );

  testWidgets(
    'tapping - on an item whose stock is below the step floors it to '
    'exactly 0, instead of no-op-ing above zero (pollo 57 g, step ~113.4 g)',
    (tester) async {
      const lowStockItem = PantryItem.quantityTracked(
        ingredientId: 'ing-pollo',
        category: Category.proteina,
        presentation: Presentation.counter(),
        stock: Quantity(value: 57, unit: Unit.gram),
      );
      final lowStockRow = PantryRow(item: lowStockItem, ingredient: pollo);

      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([lowStockItem]));
      when(
        () => mockPantryRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      await pumpRow(tester, withRow: lowStockRow);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('0 lb'), findsOneWidget);

      await tester.pumpAndSettle();

      final captured = verify(
        () => mockPantryRepository.save(captureAny()),
      ).captured;
      final saved = captured.single as QuantityTrackedPantryItem;
      expect(saved.stock.value, 0);
    },
  );
}
