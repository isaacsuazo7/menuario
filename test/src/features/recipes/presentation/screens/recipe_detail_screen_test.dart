import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/features/recipes/presentation/screens/recipe_detail_screen.dart';
import 'package:menuario/src/features/recipes/presentation/screens/recipe_form_screen.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockIngredientRepository extends Mock implements IngredientRepository {}

void main() {
  late MockRecipeRepository mockRecipeRepository;
  late MockIngredientRepository mockIngredientRepository;

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
    mockIngredientRepository = MockIngredientRepository();
  });

  Future<void> pumpScreen(WidgetTester tester, {String recipeId = 'r1'}) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
          ingredientRepositoryProvider.overrideWithValue(
            mockIngredientRepository,
          ),
        ],
        child: MaterialApp(home: RecipeDetailScreen(recipeId: recipeId)),
      ),
    );
  }

  const huevo = Ingredient(
    id: 'i1',
    name: 'Huevo',
    emoji: '🥚',
    category: Category.proteina,
    measurementKind: MeasurementKind.unit,
    booleanTracked: false,
  );
  const avena = Ingredient(
    id: 'i2',
    name: 'Avena',
    emoji: '🌾',
    category: Category.cereal,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    conversionFactor: 85,
  );
  const leche = Ingredient(
    id: 'i3',
    name: 'Leche',
    emoji: '🥛',
    category: Category.lacteo,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    conversionFactor: 1,
  );

  const recipeWithThreeIngredients = Recipe(
    id: 'r1',
    name: 'Avena con leche',
    emoji: '🥣',
    mealType: MealType.desayuno,
    bomLines: [
      BomLine(
        recipeId: 'r1',
        ingredientId: 'i1',
        quantity: Quantity(value: 2, unit: Unit.count),
      ),
      BomLine(
        recipeId: 'r1',
        ingredientId: 'i2',
        quantity: Quantity(
          value: 1,
          unit: Unit(symbol: 'taza', dimension: UnitDimension.volume),
        ),
      ),
      BomLine(
        recipeId: 'r1',
        ingredientId: 'i3',
        quantity: Quantity(value: 1, unit: Unit.liter),
      ),
    ],
  );

  testWidgets(
    'shows the header and 3 resolved ingredient rows when all BomLines match',
    (tester) async {
      when(
        () => mockRecipeRepository.getById('r1'),
      ).thenAnswer((_) async => const Right(recipeWithThreeIngredients));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([huevo, avena, leche]));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Avena con leche'), findsOneWidget);
      expect(find.text('Desayuno'), findsOneWidget);
      expect(find.textContaining('Huevo'), findsOneWidget);
      expect(find.textContaining('Avena'), findsWidgets);
      expect(find.textContaining('Leche'), findsOneWidget);
    },
  );

  testWidgets(
    'renders a graceful fallback row for a BomLine with a missing ingredient',
    (tester) async {
      const recipeWithMissingIngredient = Recipe(
        id: 'r1',
        name: 'Misteriosa',
        bomLines: [
          BomLine(
            recipeId: 'r1',
            ingredientId: 'missing',
            quantity: Quantity(value: 1, unit: Unit.count),
          ),
        ],
      );
      when(
        () => mockRecipeRepository.getById('r1'),
      ).thenAnswer((_) async => const Right(recipeWithMissingIngredient));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([]));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Ingrediente no encontrado'), findsOneWidget);
    },
  );

  testWidgets('shows an error message when getById fails', (tester) async {
    when(
      () => mockRecipeRepository.getById('missing'),
    ).thenAnswer((_) async => Left(Failure(message: 'Receta no encontrada.')));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    await pumpScreen(tester, recipeId: 'missing');
    await tester.pumpAndSettle();

    expect(find.text('Receta no encontrada.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('tapping the edit action navigates to the edit form with id', (
    tester,
  ) async {
    when(
      () => mockRecipeRepository.getById('r1'),
    ).thenAnswer((_) async => const Right(recipeWithThreeIngredients));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([huevo, avena, leche]));

    final router = GoRouter(
      initialLocation: '/recipes/r1',
      routes: [
        GoRoute(
          path: '/recipes/:id',
          builder: (context, state) =>
              RecipeDetailScreen(recipeId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: RecipeRoutes.form,
          name: RecipeRoutes.form,
          builder: (context, state) =>
              RecipeFormScreen(recipeId: state.uri.queryParameters['id']),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
          ingredientRepositoryProvider.overrideWithValue(
            mockIngredientRepository,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('recipe-detail-edit-button')));
    await tester.pumpAndSettle();

    expect(find.byType(RecipeFormScreen), findsOneWidget);
    final formScreen = tester.widget<RecipeFormScreen>(
      find.byType(RecipeFormScreen),
    );
    expect(formScreen.recipeId, 'r1');
  });

  testWidgets('renders the video list with a tappable row per video', (
    tester,
  ) async {
    const recipeWithVideos = Recipe(
      id: 'r1',
      name: 'Avena con leche',
      bomLines: [],
      videos: [
        VideoLink(source: VideoSource.youtube, url: 'https://youtu.be/abc'),
        VideoLink(source: VideoSource.tiktok, url: 'https://tiktok.com/xyz'),
      ],
    );
    when(
      () => mockRecipeRepository.getById('r1'),
    ).thenAnswer((_) async => const Right(recipeWithVideos));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Videos'), findsOneWidget);
    expect(find.text('https://youtu.be/abc'), findsOneWidget);
    expect(find.text('https://tiktok.com/xyz'), findsOneWidget);
  });

  testWidgets('an empty video list renders no Videos section', (
    tester,
  ) async {
    when(
      () => mockRecipeRepository.getById('r1'),
    ).thenAnswer((_) async => const Right(recipeWithThreeIngredients));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([huevo, avena, leche]));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Videos'), findsNothing);
  });
}
