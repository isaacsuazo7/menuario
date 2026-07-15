import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/ingredients/presentation/screens/ingredient_form_screen.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockIngredientRepository extends Mock implements IngredientRepository {}

void main() {
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

  setUpAll(() {
    registerFallbackValue(avena);
  });

  setUp(() {
    mockIngredientRepository = MockIngredientRepository();
  });

  Future<void> pumpScreen(WidgetTester tester, {String? ingredientId}) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          ingredientRepositoryProvider.overrideWithValue(
            mockIngredientRepository,
          ),
        ],
        child: MaterialApp(
          home: IngredientFormScreen(ingredientId: ingredientId),
        ),
      ),
    );
  }

  testWidgets('renders the 6 ingredient fields with the create title', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Nuevo ingrediente'), findsOneWidget);
    expect(find.byKey(const Key('ingredient-name-field')), findsOneWidget);
    expect(find.byKey(const Key('ingredient-emoji-field')), findsOneWidget);
    expect(find.byKey(const Key('ingredient-category-field')), findsOneWidget);
    expect(
      find.byKey(const Key('ingredient-measurement-kind-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('ingredient-boolean-tracked-field')),
      findsOneWidget,
    );
  });

  testWidgets('shows the edit title when ingredientId is provided', (
    tester,
  ) async {
    when(
      () => mockIngredientRepository.getById('ing-avena'),
    ).thenAnswer((_) async => const Right(avena));

    await pumpScreen(tester, ingredientId: 'ing-avena');
    await tester.pumpAndSettle();

    expect(find.text('Editar ingrediente'), findsOneWidget);
  });

  testWidgets(
    'conversionFactor is hidden for unit and shown for bulk',
    (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      // Default measurementKind is unit — conversionFactor hidden.
      expect(
        find.byKey(const Key('ingredient-conversion-factor-field')),
        findsNothing,
      );

      await tester.tap(find.text('Granel'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('ingredient-conversion-factor-field')),
        findsOneWidget,
      );

      await tester.tap(find.text('Unidad'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('ingredient-conversion-factor-field')),
        findsNothing,
      );
    },
  );

  testWidgets('Confirm is disabled when the name is empty', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    final confirmButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Confirmar'),
    );
    expect(confirmButton.onPressed, isNull);
  });

  testWidgets(
    'Confirm is disabled for a bulk ingredient with an empty conversionFactor',
    (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('ingredient-name-field')),
        'Avena',
      );
      await tester.tap(find.text('Granel'));
      await tester.pumpAndSettle();

      final confirmButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirmar'),
      );
      expect(confirmButton.onPressed, isNull);
    },
  );

  testWidgets('Confirm is enabled for a valid unit ingredient', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('ingredient-name-field')),
      'Huevo',
    );
    await tester.pumpAndSettle();

    final confirmButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Confirmar'),
    );
    expect(confirmButton.onPressed, isNotNull);
  });

  testWidgets('Confirm is enabled for a valid bulk ingredient with a '
      'conversionFactor', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('ingredient-name-field')),
      'Avena',
    );
    await tester.tap(find.text('Granel'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('ingredient-conversion-factor-field')),
      '85',
    );
    await tester.pumpAndSettle();

    final confirmButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Confirmar'),
    );
    expect(confirmButton.onPressed, isNotNull);
  });

  testWidgets('edit mode pre-fills the 6 fields from the existing '
      'ingredient', (tester) async {
    when(
      () => mockIngredientRepository.getById('ing-avena'),
    ).thenAnswer((_) async => const Right(avena));

    await pumpScreen(tester, ingredientId: 'ing-avena');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Avena'), findsOneWidget);
    expect(find.widgetWithText(TextField, '🥣'), findsOneWidget);
    expect(find.widgetWithText(TextField, '85'), findsOneWidget);
    expect(find.text('Cereal'), findsOneWidget);

    final confirmButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Confirmar'),
    );
    expect(confirmButton.onPressed, isNotNull);
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

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo ingrediente'), findsNothing);
    expect(find.text('open'), findsOneWidget);
    verifyNever(() => mockIngredientRepository.save(any()));
  });
}
