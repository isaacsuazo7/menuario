import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/features/recipes/presentation/screens/recipe_detail_screen.dart';
import 'package:menuario/src/features/recipes/presentation/screens/recipe_form_screen.dart';
import 'package:menuario/src/features/recipes/presentation/screens/recipes_screen.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockIngredientRepository extends Mock implements IngredientRepository {}

void main() {
  late MockRecipeRepository mockRecipeRepository;

  setUpAll(() {
    registerFallbackValue(const Recipe(id: 'fallback', name: '', bomLines: []));
  });

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
  const disabledRecipe = Recipe(
    id: 'r5',
    name: 'Vieja receta',
    emoji: '🕰️',
    mealType: MealType.desayuno,
    enabled: false,
    bomLines: [],
  );

  testWidgets('renders as body content without its own AppBar', (tester) async {
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
  });

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

  testWidgets('a card with a 2-line name and a meal chip does not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const longNameRecipes = [
      Recipe(
        id: 'r3',
        name: 'Aderezo mostaza-miel',
        emoji: '🥫',
        mealType: MealType.desayuno,
        bomLines: [],
      ),
      Recipe(
        id: 'r4',
        name: 'Aderezo yogurt-cilantro',
        emoji: '🥫',
        mealType: MealType.cena,
        bomLines: [],
      ),
    ];
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right(longNameRecipes));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a card navigates to its recipe detail route', (
    tester,
  ) async {
    final mockIngredientRepository = MockIngredientRepository();
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([desayunoRecipe]));
    when(
      () => mockRecipeRepository.getById('r1'),
    ).thenAnswer((_) async => const Right(desayunoRecipe));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    final router = GoRouter(
      initialLocation: ShellRoutes.recipes,
      routes: [
        GoRoute(
          path: ShellRoutes.recipes,
          builder: (context, state) => const RecipesScreen(),
          routes: [
            GoRoute(
              path: ':id',
              name: ShellRoutes.recipeDetailName,
              builder: (context, state) =>
                  RecipeDetailScreen(recipeId: state.pathParameters['id']!),
            ),
          ],
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

    await tester.tap(find.text('Avena'));
    await tester.pumpAndSettle();

    expect(find.byType(RecipeDetailScreen), findsOneWidget);
    expect(find.text('Detalle de receta'), findsOneWidget);
  });

  testWidgets('a disabled recipe renders greyed with a Desactivada marker', (
    tester,
  ) async {
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([desayunoRecipe, disabledRecipe]));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Vieja receta'), findsOneWidget);
    expect(find.text('Desactivada'), findsOneWidget);

    final opacity = tester.widget<Opacity>(
      find.ancestor(
        of: find.text('Vieja receta'),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, lessThan(1.0));
  });

  testWidgets(
    'an enabled recipe renders without the Desactivada marker at full '
    'opacity',
    (tester) async {
      when(
        () => mockRecipeRepository.list(),
      ).thenAnswer((_) async => const Right([desayunoRecipe]));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Desactivada'), findsNothing);
      final opacity = tester.widget<Opacity>(
        find.ancestor(of: find.text('Avena'), matching: find.byType(Opacity)),
      );
      expect(opacity.opacity, 1.0);
    },
  );

  testWidgets(
    'tapping a disabled card reactivates it in place without navigating',
    (tester) async {
      when(
        () => mockRecipeRepository.list(),
      ).thenAnswer((_) async => const Right([disabledRecipe]));
      when(
        () => mockRecipeRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      final router = GoRouter(
        initialLocation: ShellRoutes.recipes,
        routes: [
          GoRoute(
            path: ShellRoutes.recipes,
            builder: (context, state) => const RecipesScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: ShellRoutes.recipeDetailName,
                builder: (context, state) =>
                    RecipeDetailScreen(recipeId: state.pathParameters['id']!),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vieja receta'));
      await tester.pumpAndSettle();

      expect(find.byType(RecipeDetailScreen), findsNothing);
      final captured = verify(
        () => mockRecipeRepository.save(captureAny()),
      ).captured;
      expect(captured, hasLength(1));
      expect((captured.single as Recipe).id, disabledRecipe.id);
      expect((captured.single as Recipe).enabled, isTrue);
    },
  );

  testWidgets('tapping the FAB opens the create form', (tester) async {
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    final router = GoRouter(
      initialLocation: ShellRoutes.recipes,
      routes: [
        GoRoute(
          path: ShellRoutes.recipes,
          builder: (context, state) => const RecipesScreen(),
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
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(RecipeFormScreen), findsOneWidget);
    final formScreen = tester.widget<RecipeFormScreen>(
      find.byType(RecipeFormScreen),
    );
    expect(formScreen.recipeId, isNull);
  });
}
