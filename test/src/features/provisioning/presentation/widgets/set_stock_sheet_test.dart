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

  const pollo = Ingredient(
    id: 'ing-pollo',
    name: 'Pollo',
    emoji: '🍗',
    category: Category.proteina,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    conversionFactor: 1,
  );
  const polloItem = PantryItem.quantityTracked(
    ingredientId: 'ing-pollo',
    category: Category.proteina,
    presentation: Presentation.counter(),
    stock: Quantity(value: 793.7, unit: Unit.gram),
  );
  final polloRow = PantryRow(item: polloItem, ingredient: pollo);

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

  testWidgets('prefills the field from current stock in the natural unit '
      '(counter)', (tester) async {
    await pumpSheet(tester, row: polloRow);

    expect(find.widgetWithText(TextField, '1.75'), findsOneWidget);
  });

  testWidgets('prefills the field from current stock in the natural unit '
      '(loose)', (tester) async {
    await pumpSheet(tester, row: huevoRow);

    expect(find.widgetWithText(TextField, '7'), findsOneWidget);
  });

  testWidgets(
    'decimal counter entry converts lb to grams and calls setStock on '
    'confirm',
    (tester) async {
      when(
        () => mockPantryRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      await pumpSheet(tester, row: polloRow);

      await tester.enterText(find.byType(TextField), '2');
      await tester.pump();
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      final captured = verify(
        () => mockPantryRepository.save(captureAny()),
      ).captured;
      final saved = captured.single as QuantityTrackedPantryItem;
      expect(saved.stock.value, closeTo(907.18474, 1e-5));
    },
  );

  testWidgets('an integer-only presentation ignores a typed decimal point', (
    tester,
  ) async {
    await pumpSheet(tester, row: huevoRow);

    await tester.enterText(find.byType(TextField), '3.5');
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isNot(contains('.')));
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
    expect(find.textContaining('454'), findsOneWidget);
  });

  testWidgets('the live preview reflects typed input', (tester) async {
    await pumpSheet(tester, row: polloRow);

    await tester.enterText(find.byType(TextField), '3');
    await tester.pump();

    expect(find.textContaining('1361'), findsOneWidget);
  });

  testWidgets('shows a SnackBar when the controller returns a Failure', (
    tester,
  ) async {
    final saveCompleter = Completer<Either<Failure, void>>();
    when(
      () => mockPantryRepository.save(any()),
    ).thenAnswer((_) => saveCompleter.future);

    await pumpSheet(tester, row: polloRow);

    await tester.enterText(find.byType(TextField), '2');
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
