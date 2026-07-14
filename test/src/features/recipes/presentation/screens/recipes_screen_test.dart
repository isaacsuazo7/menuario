import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/recipes/presentation/screens/recipes_screen.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  late MockRecipeRepository mockRecipeRepository;

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
  });

  Future<void> pumpScreen(WidgetTester tester) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
        ],
        child: const MaterialApp(home: RecipesScreen()),
      ),
    );
  }

  const desayunoRecipe = Recipe(
    id: 'r1',
    name: 'Avena',
    emoji: '🥣',
    mealType: MealType.desayuno,
    bomLines: [],
  );
  const untaggedRecipe = Recipe(
    id: 'r2',
    name: 'Misterio',
    emoji: '❓',
    bomLines: [],
  );

  testWidgets('shows a loading indicator while the list loads', (tester) async {
    final completer = Completer<Either<Failure, List<Recipe>>>();
    addTearDown(() {
      if (!completer.isCompleted) completer.complete(const Right([]));
    });
    when(() => mockRecipeRepository.list()).thenAnswer((_) => completer.future);

    await pumpScreen(tester);

    expect(find.text('Reintentar'), findsNothing);
    expect(
      find.text('Aún no tienes recetas. Impórtalas o créalas desde el menú.'),
      findsNothing,
    );
  });

  testWidgets('shows an error message with retry on failure', (tester) async {
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => Left(Failure(message: 'No se pudo cargar.')));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('No se pudo cargar.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('shows a friendly empty state when there are no recipes', (
    tester,
  ) async {
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('Aún no tienes recetas. Impórtalas o créalas desde el menú.'),
      findsOneWidget,
    );
  });

  testWidgets('renders a 2-column grid with a card per recipe', (tester) async {
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([desayunoRecipe, untaggedRecipe]));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('Avena'), findsOneWidget);
    expect(find.text('Misterio'), findsOneWidget);
  });

  testWidgets('filtering by Desayuno narrows the grid', (tester) async {
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([desayunoRecipe, untaggedRecipe]));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Desayuno'));
    await tester.pumpAndSettle();

    expect(find.text('Avena'), findsOneWidget);
    expect(find.text('Misterio'), findsNothing);
  });

  testWidgets('Todas shows everything, including untagged recipes', (
    tester,
  ) async {
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([desayunoRecipe, untaggedRecipe]));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Desayuno'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Todas'));
    await tester.pumpAndSettle();

    expect(find.text('Avena'), findsOneWidget);
    expect(find.text('Misterio'), findsOneWidget);
  });
}
