import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/features/ingredients/presentation/screens/ingredient_form_screen.dart';
import 'package:menuario/src/features/ingredients/presentation/screens/ingredients_list_screen.dart';
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
    conversionFactor: 85,
  );
  const comino = Ingredient(
    id: 'ing-comino',
    name: 'Comino',
    emoji: '🌿',
    category: Category.condimento,
  );

  setUp(() {
    mockIngredientRepository = MockIngredientRepository();
  });

  Future<void> pumpScreen(WidgetTester tester) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          ingredientRepositoryProvider.overrideWithValue(
            mockIngredientRepository,
          ),
        ],
        child: const MaterialApp(home: IngredientsListScreen()),
      ),
    );
  }

  testWidgets('renders its own AppBar titled Ingredientes', (tester) async {
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Ingredientes'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'renders 2 ingredients across 2 categories as exactly 2 category groups',
    (tester) async {
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([avena, comino]));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Cereal'), findsOneWidget);
      expect(find.text('Condimento'), findsOneWidget);
      expect(find.text('Avena'), findsOneWidget);
      expect(find.text('Comino'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('category-color-dot')),
        findsNWidgets(2),
      );
    },
  );

  testWidgets('shows a friendly empty state when there are no ingredients', (
    tester,
  ) async {
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('Aún no tienes ingredientes. Créalos con el botón +.'),
      findsOneWidget,
    );
  });

  testWidgets('shows an error message with retry on load failure', (
    tester,
  ) async {
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => Left(Failure(message: 'No se pudo cargar.')));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('No se pudo cargar.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('tapping the FAB opens the create form', (tester) async {
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    final router = GoRouter(
      initialLocation: IngredientRoutes.list,
      routes: [
        GoRoute(
          path: IngredientRoutes.list,
          builder: (context, state) => const IngredientsListScreen(),
        ),
        GoRoute(
          path: IngredientRoutes.form,
          name: IngredientRoutes.form,
          builder: (context, state) => IngredientFormScreen(
            ingredientId: state.uri.queryParameters['id'],
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ingredientRepositoryProvider.overrideWithValue(
            mockIngredientRepository,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(IngredientFormScreen), findsOneWidget);
    final formScreen = tester.widget<IngredientFormScreen>(
      find.byType(IngredientFormScreen),
    );
    expect(formScreen.ingredientId, isNull);
  });

  testWidgets('tapping a row opens the edit form for that ingredient', (
    tester,
  ) async {
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([avena]));

    final router = GoRouter(
      initialLocation: IngredientRoutes.list,
      routes: [
        GoRoute(
          path: IngredientRoutes.list,
          builder: (context, state) => const IngredientsListScreen(),
        ),
        GoRoute(
          path: IngredientRoutes.form,
          name: IngredientRoutes.form,
          builder: (context, state) => IngredientFormScreen(
            ingredientId: state.uri.queryParameters['id'],
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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

    expect(find.byType(IngredientFormScreen), findsOneWidget);
    final formScreen = tester.widget<IngredientFormScreen>(
      find.byType(IngredientFormScreen),
    );
    expect(formScreen.ingredientId, 'ing-avena');
  });
}
