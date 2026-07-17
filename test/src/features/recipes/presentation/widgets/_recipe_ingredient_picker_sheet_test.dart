import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/recipes/presentation/widgets/_recipe_ingredient_picker_sheet.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockIngredientRepository extends Mock implements IngredientRepository {}

void main() {
  late MockIngredientRepository mockIngredientRepository;

  const huevo = Ingredient(
    id: 'ing-huevo',
    name: 'Huevo',
    emoji: '🥚',
    category: Category.proteina,
    measurementMode: MeasurementMode.count,
  );
  const leche = Ingredient(
    id: 'ing-leche',
    name: 'Leche',
    emoji: '🥛',
    category: Category.lacteo,
    conversionFactor: 1,
    measurementMode: MeasurementMode.mass,
  );
  const sal = Ingredient(
    id: 'ing-sal',
    name: 'Sal',
    emoji: '🧂',
    category: Category.condimento,
    measurementMode: MeasurementMode.boolean,
  );

  setUp(() {
    mockIngredientRepository = MockIngredientRepository();
  });

  /// Pumps a screen with a button that opens [RecipeIngredientPickerSheet]
  /// as a modal bottom sheet capped at ~80% of the screen height (mirrors
  /// `recipe_form_screen.dart`'s `_pickIngredientForBomRow` call) and taps
  /// it open. Returns the [Future] the sheet resolves with on pop.
  Future<Future<String?>> openSheet(WidgetTester tester) async {
    late Future<String?> future;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ingredientRepositoryProvider.overrideWithValue(
            mockIngredientRepository,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  future = showModalBottomSheet<String?>(
                    context: context,
                    isScrollControlled: true,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    builder: (_) => const RecipeIngredientPickerSheet(),
                  );
                },
                child: const Text('open picker'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open picker'));
    await tester.pumpAndSettle();

    return future;
  }

  testWidgets('lists ingredients grouped by category', (tester) async {
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([huevo, leche]));

    await openSheet(tester);

    expect(find.text(Category.proteina.label), findsOneWidget);
    expect(find.text(Category.lacteo.label), findsOneWidget);
    expect(find.text('Huevo'), findsOneWidget);
    expect(find.text('Leche'), findsOneWidget);
  });

  testWidgets('tapping an ingredient pops the sheet with its id', (
    tester,
  ) async {
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([huevo, leche]));

    final future = await openSheet(tester);

    await tester.tap(find.text('Leche'));
    await tester.pumpAndSettle();

    expect(await future, 'ing-leche');
  });

  testWidgets('there is no inline "create ingredient" action', (tester) async {
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([huevo, leche]));

    await openSheet(tester);

    expect(find.text('＋ Nuevo ingrediente'), findsNothing);
    expect(find.byKey(const Key('recipe-bom-create-ingredient')), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets(
    'boolean-mode ingredients are excluded from the selectable list',
    (tester) async {
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([huevo, leche, sal]));

      await openSheet(tester);

      expect(find.text('Huevo'), findsOneWidget);
      expect(find.text('Leche'), findsOneWidget);
      expect(find.text('Sal'), findsNothing);
      expect(find.text(Category.condimento.label), findsNothing);
    },
  );

  testWidgets('opening the sheet does not throw (no invalidate-during-build '
      'regression)', (tester) async {
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([huevo, leche]));

    await openSheet(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('the modal sheet is capped at ~80% of the screen height', (
    tester,
  ) async {
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([huevo, leche]));

    await openSheet(tester);

    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final sheetSize = tester.getSize(find.byType(RecipeIngredientPickerSheet));

    expect(sheetSize.height, lessThanOrEqualTo(screenHeight * 0.8 + 0.5));
  });
}
