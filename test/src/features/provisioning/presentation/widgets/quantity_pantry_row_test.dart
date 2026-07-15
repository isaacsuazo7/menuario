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

  const avena = Ingredient(
    id: 'ing-avena',
    name: 'Avena',
    emoji: '🥣',
    category: Category.cereal,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    conversionFactor: 85,
  );
  // Exactly one pack, so the purchase-unit display is a clean "1 bolsa".
  const avenaItem = PantryItem.quantityTracked(
    ingredientId: 'ing-avena',
    category: Category.cereal,
    presentation: Presentation.package(yieldQty: 454, label: 'bolsa'),
    stock: Quantity(value: 454, unit: Unit.gram),
  );
  final row = PantryRow(item: avenaItem, ingredient: avena);

  // Empty stock, so tapping "+" proves the smart step (whole pack, 454 g)
  // rather than a hardcoded delta of 1.
  const zeroAvenaItem = PantryItem.quantityTracked(
    ingredientId: 'ing-avena',
    category: Category.cereal,
    presentation: Presentation.package(yieldQty: 454, label: 'bolsa'),
    stock: Quantity(value: 0, unit: Unit.gram),
  );
  final zeroRow = PantryRow(item: zeroAvenaItem, ingredient: avena);

  const pollo = Ingredient(
    id: 'ing-pollo',
    name: 'Pollo',
    emoji: '🍗',
    category: Category.proteina,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    conversionFactor: 1,
  );
  const polloDisplayItem = PantryItem.quantityTracked(
    ingredientId: 'ing-pollo',
    category: Category.proteina,
    presentation: Presentation.counter(),
    stock: Quantity(value: 793.7, unit: Unit.gram),
  );
  final polloDisplayRow = PantryRow(item: polloDisplayItem, ingredient: pollo);

  // Exactly 1.75 lb, so the post-step value lands on a clean 2.00 lb.
  const polloStepItem = PantryItem.quantityTracked(
    ingredientId: 'ing-pollo',
    category: Category.proteina,
    presentation: Presentation.counter(),
    stock: Quantity(value: 793.7866475, unit: Unit.gram),
  );
  final polloStepRow = PantryRow(item: polloStepItem, ingredient: pollo);

  const huevo = Ingredient(
    id: 'ing-huevo',
    name: 'Huevo',
    emoji: '🥚',
    category: Category.proteina,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    conversionFactor: 1,
  );
  const huevoItem = PantryItem.quantityTracked(
    ingredientId: 'ing-huevo',
    category: Category.proteina,
    presentation: Presentation.loose(),
    stock: Quantity(value: 7, unit: Unit.count),
  );
  final huevoRow = PantryRow(item: huevoItem, ingredient: huevo);

  setUpAll(() {
    registerFallbackValue(avenaItem);
  });

  setUp(() {
    mockPantryRepository = MockPantryRepository();
    mockIngredientRepository = MockIngredientRepository();
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => const Right([avenaItem]));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([avena]));
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
          home: Scaffold(body: QuantityPantryRow(row: withRow ?? row)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'renders emoji, name, purchase-unit stock display and a green pill',
    (tester) async {
      await pumpRow(tester);

      expect(find.text('🥣'), findsOneWidget);
      expect(find.text('Avena'), findsOneWidget);
      expect(find.text('1 bolsa'), findsOneWidget);
      expect(find.text('🟢 Tengo'), findsOneWidget);
    },
  );

  testWidgets('renders a counter item as decimal pounds, not raw grams', (
    tester,
  ) async {
    await pumpRow(tester, withRow: polloDisplayRow);

    expect(find.text('1.75 lb'), findsOneWidget);
    expect(find.text('793.7 g'), findsNothing);
  });

  testWidgets('renders a loose item as a whole-unit count', (tester) async {
    await pumpRow(tester, withRow: huevoRow);

    expect(find.text('7 u'), findsOneWidget);
  });

  testWidgets(
    'tapping + steps a package item by a whole pack (454 g), not by 1',
    (tester) async {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([zeroAvenaItem]));
      when(
        () => mockPantryRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      await pumpRow(tester, withRow: zeroRow);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('1 bolsa'), findsOneWidget);

      await tester.pumpAndSettle();

      final captured = verify(
        () => mockPantryRepository.save(captureAny()),
      ).captured;
      final saved = captured.single as QuantityTrackedPantryItem;
      expect(saved.stock.value, 454);
    },
  );

  testWidgets(
    'tapping - on a package item at 0 stays at 0 and never calls save',
    (tester) async {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([zeroAvenaItem]));

      await pumpRow(tester, withRow: zeroRow);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(find.text('0 bolsa'), findsOneWidget);
      verifyNever(() => mockPantryRepository.save(any()));
    },
  );

  testWidgets(
    'tapping + on a counter item advances by a quarter pound, not 1 gram',
    (tester) async {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([polloStepItem]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([pollo]));
      when(
        () => mockPantryRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      await pumpRow(tester, withRow: polloStepRow);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('2.00 lb'), findsOneWidget);

      await tester.pumpAndSettle();

      final captured = verify(
        () => mockPantryRepository.save(captureAny()),
      ).captured;
      final saved = captured.single as QuantityTrackedPantryItem;
      expect(saved.stock.value, closeTo(907.1847400, 1e-6));
    },
  );

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
    expect(find.text('2 bolsa'), findsOneWidget);

    saveCompleter.complete(Left(Failure(message: 'No se pudo guardar.')));
    await tester.pumpAndSettle();

    expect(find.text('1 bolsa'), findsOneWidget);
    expect(find.text('No se pudo guardar.'), findsOneWidget);
  });

  testWidgets(
    'tapping the stock display opens the real SetStockSheet, prefilled',
    (tester) async {
      await pumpRow(tester);

      expect(find.byType(SetStockSheet), findsNothing);

      await tester.tap(find.text('1 bolsa'));
      await tester.pumpAndSettle();

      expect(find.byType(SetStockSheet), findsOneWidget);
      expect(find.widgetWithText(TextField, '1'), findsOneWidget);
    },
  );
}
