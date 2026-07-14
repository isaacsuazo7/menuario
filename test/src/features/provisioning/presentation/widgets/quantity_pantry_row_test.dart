import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_quantity_pantry_row.dart';
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
  const avenaItem = PantryItem.quantityTracked(
    ingredientId: 'ing-avena',
    category: Category.cereal,
    presentation: Presentation.package(yieldQty: 454, label: 'bolsa'),
    stock: Quantity(value: 2, unit: Unit.gram),
  );
  final row = PantryRow(item: avenaItem, ingredient: avena);

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

  testWidgets('renders emoji, name, stock+unit and a green pill', (
    tester,
  ) async {
    await pumpRow(tester);

    expect(find.text('🥣'), findsOneWidget);
    expect(find.text('Avena'), findsOneWidget);
    expect(find.text('2 g'), findsOneWidget);
    expect(find.text('🟢 Tengo'), findsOneWidget);
  });

  testWidgets('tapping + calls adjustStock optimistically and persists', (
    tester,
  ) async {
    when(
      () => mockPantryRepository.save(any()),
    ).thenAnswer((_) async => const Right(null));

    await pumpRow(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('3 g'), findsOneWidget);

    await tester.pumpAndSettle();

    final captured = verify(
      () => mockPantryRepository.save(captureAny()),
    ).captured;
    final saved = captured.single as QuantityTrackedPantryItem;
    expect(saved.stock.value, 3);
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
    expect(find.text('3 g'), findsOneWidget);

    saveCompleter.complete(Left(Failure(message: 'No se pudo guardar.')));
    await tester.pumpAndSettle();

    expect(find.text('2 g'), findsOneWidget);
    expect(find.text('No se pudo guardar.'), findsOneWidget);
  });

  testWidgets('tapping - at stock 0 stays at 0 and never calls save', (
    tester,
  ) async {
    const zeroItem = PantryItem.quantityTracked(
      ingredientId: 'ing-avena',
      category: Category.cereal,
      presentation: Presentation.package(yieldQty: 454, label: 'bolsa'),
      stock: Quantity(value: 0, unit: Unit.gram),
    );
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => const Right([zeroItem]));
    final zeroRow = PantryRow(item: zeroItem, ingredient: avena);

    await pumpRow(tester, withRow: zeroRow);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();

    expect(find.text('0 g'), findsOneWidget);
    verifyNever(() => mockPantryRepository.save(any()));
  });
}
