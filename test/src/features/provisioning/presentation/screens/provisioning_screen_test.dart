import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/provisioning/presentation/screens/provisioning_screen.dart';
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
  const comino = Ingredient(
    id: 'ing-comino',
    name: 'Comino',
    emoji: '🌿',
    category: Category.condimento,
    measurementKind: MeasurementKind.unit,
    booleanTracked: true,
  );
  const avenaItem = PantryItem.quantityTracked(
    ingredientId: 'ing-avena',
    category: Category.cereal,
    presentation: Presentation.package(yieldQty: 454, label: 'bolsa'),
    stock: Quantity(value: 2, unit: Unit.gram),
  );
  const cominoItem = PantryItem.booleanTracked(
    ingredientId: 'ing-comino',
    category: Category.condimento,
    presentation: Presentation.loose(),
    haveIt: false,
  );

  setUp(() {
    mockPantryRepository = MockPantryRepository();
    mockIngredientRepository = MockIngredientRepository();
  });

  Future<void> pumpScreen(WidgetTester tester) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          pantryRepositoryProvider.overrideWithValue(mockPantryRepository),
          ingredientRepositoryProvider.overrideWithValue(
            mockIngredientRepository,
          ),
        ],
        child: const MaterialApp(home: ProvisioningScreen()),
      ),
    );
  }

  testWidgets('renders as body content without its own AppBar', (tester) async {
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => const Right([]));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
  });

  testWidgets(
    'renders 3 items across 2 categories as exactly 2 category groups',
    (tester) async {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([avenaItem, cominoItem]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([avena, comino]));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Cereal'), findsOneWidget);
      expect(find.text('Condimento'), findsOneWidget);
      expect(find.text('Avena'), findsOneWidget);
      expect(find.text('Comino'), findsOneWidget);
    },
  );

  testWidgets('shows a friendly empty state for an empty pantry', (
    tester,
  ) async {
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => const Right([]));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Tu despensa está vacía.'), findsOneWidget);
  });

  testWidgets('shows an error message with retry on load failure', (
    tester,
  ) async {
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => Left(Failure(message: 'No se pudo cargar.')));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('No se pudo cargar.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });
}
