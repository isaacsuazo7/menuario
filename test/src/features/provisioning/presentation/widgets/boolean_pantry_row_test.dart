import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_boolean_pantry_row.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockPantryRepository extends Mock implements PantryRepository {}

class MockIngredientRepository extends Mock implements IngredientRepository {}

void main() {
  late MockPantryRepository mockPantryRepository;
  late MockIngredientRepository mockIngredientRepository;

  const comino = Ingredient(
    id: 'ing-comino',
    name: 'Comino',
    emoji: '🌿',
    category: Category.condimento,
  );
  const cominoItem = PantryItem.booleanTracked(
    ingredientId: 'ing-comino',
    category: Category.condimento,
    haveIt: false,
  );
  final row = PantryRow(item: cominoItem, ingredient: comino);

  setUpAll(() {
    registerFallbackValue(cominoItem);
  });

  setUp(() {
    mockPantryRepository = MockPantryRepository();
    mockIngredientRepository = MockIngredientRepository();
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => const Right([cominoItem]));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([comino]));
  });

  Future<void> pumpRow(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pantryRepositoryProvider.overrideWithValue(mockPantryRepository),
          ingredientRepositoryProvider.overrideWithValue(
            mockIngredientRepository,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: BooleanPantryRow(row: row)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders emoji, name, a red pill and a toggle', (tester) async {
    await pumpRow(tester);

    expect(find.text('🌿'), findsOneWidget);
    expect(find.text('Comino'), findsOneWidget);
    expect(find.text('🔴 No tengo'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets(
    'tapping the toggle calls toggleHave optimistically and persists',
    (tester) async {
      when(
        () => mockPantryRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      await pumpRow(tester);

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(find.text('🟢 Tengo'), findsOneWidget);

      await tester.pumpAndSettle();

      final captured = verify(
        () => mockPantryRepository.save(captureAny()),
      ).captured;
      final saved = captured.single as BooleanTrackedPantryItem;
      expect(saved.haveIt, isTrue);
    },
  );

  testWidgets('shows a SnackBar and reverts haveIt when save fails', (
    tester,
  ) async {
    final saveCompleter = Completer<Either<Failure, void>>();
    when(
      () => mockPantryRepository.save(any()),
    ).thenAnswer((_) => saveCompleter.future);

    await pumpRow(tester);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(find.text('🟢 Tengo'), findsOneWidget);

    saveCompleter.complete(Left(Failure(message: 'No se pudo guardar.')));
    await tester.pumpAndSettle();

    expect(find.text('🔴 No tengo'), findsOneWidget);
    expect(find.text('No se pudo guardar.'), findsOneWidget);
  });
}
