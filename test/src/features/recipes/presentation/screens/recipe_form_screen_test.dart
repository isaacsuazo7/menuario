import 'package:dartz/dartz.dart' hide State, Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_edit_provider.dart';
import 'package:menuario/src/features/recipes/presentation/screens/recipe_form_screen.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockIngredientRepository extends Mock implements IngredientRepository {}

void main() {
  late MockRecipeRepository mockRecipeRepository;
  late MockIngredientRepository mockIngredientRepository;

  const pollo = Ingredient(
    id: 'i1',
    name: 'Pollo',
    emoji: '🍗',
    category: Category.proteina,
    measurementKind: MeasurementKind.unit,
    booleanTracked: false,
    measurementMode: MeasurementMode.count,
  );
  const huevo = Ingredient(
    id: 'ing-huevo',
    name: 'Huevo',
    emoji: '🥚',
    category: Category.proteina,
    measurementKind: MeasurementKind.unit,
    booleanTracked: false,
    measurementMode: MeasurementMode.count,
  );
  const leche = Ingredient(
    id: 'ing-leche',
    name: 'Leche',
    emoji: '🥛',
    category: Category.lacteo,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    conversionFactor: 0.24,
    measurementMode: MeasurementMode.packageBase,
    package: PackageSpec(
      label: 'bolsa',
      yieldQty: 1,
      baseDimension: Unit.liter,
    ),
  );

  setUpAll(() {
    registerFallbackValue(const Recipe(id: '', name: '', bomLines: []));
  });

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
    mockIngredientRepository = MockIngredientRepository();
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([pollo, huevo, leche]));
  });

  overrides() => [
    recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
    ingredientRepositoryProvider.overrideWithValue(mockIngredientRepository),
  ];

  Future<void> pumpScreen(WidgetTester tester, {String? recipeId}) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(home: RecipeFormScreen(recipeId: recipeId)),
      ),
    );
  }

  /// Pumps the form behind a [GoRouter] so pop-on-success is observable
  /// (mirrors `ingredient_form_screen_test.dart`).
  Future<void> pumpPushableScreen(
    WidgetTester tester, {
    String? recipeId,
  }) async {
    final router = GoRouter(
      initialLocation: '/host',
      routes: [
        GoRoute(
          path: '/host',
          builder: (context, state) => Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => context.pushNamed(
                  RecipeRoutes.form,
                  queryParameters: recipeId == null ? {} : {'id': recipeId},
                ),
                child: const Text('open'),
              ),
            ),
          ),
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
        overrides: overrides(),
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  const existingRecipe = Recipe(
    id: 'r1',
    name: 'Avena con leche',
    emoji: '🥣',
    mealType: MealType.desayuno,
    enabled: true,
    videos: [
      VideoLink(source: VideoSource.youtube, url: 'https://youtu.be/abc'),
    ],
    bomLines: [
      BomLine(
        recipeId: 'r1',
        ingredientId: 'i1',
        quantity: Quantity(value: 2, unit: Unit.count),
      ),
    ],
  );

  testWidgets('renders the create title and core fields', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Nueva receta'), findsOneWidget);
    expect(find.byKey(const Key('recipe-name-field')), findsOneWidget);
    expect(find.byKey(const Key('recipe-emoji-field')), findsOneWidget);
    expect(find.byKey(const Key('recipe-meal-type-field')), findsOneWidget);
    expect(find.byKey(const Key('recipe-enabled-field')), findsOneWidget);
  });

  testWidgets('shows the edit title when recipeId is provided', (tester) async {
    when(
      () => mockRecipeRepository.getById('r1'),
    ).thenAnswer((_) async => const Right(existingRecipe));

    await pumpScreen(tester, recipeId: 'r1');
    await tester.pumpAndSettle();

    expect(find.text('Editar receta'), findsOneWidget);
  });

  testWidgets('Confirm is disabled when the name is empty', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    final confirmButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Confirmar'),
    );
    expect(confirmButton.onPressed, isNull);
  });

  testWidgets('enabled toggle defaults to true (Activa)', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    final toggle = tester.widget<SwitchListTile>(
      find.byKey(const Key('recipe-enabled-field')),
    );
    expect(toggle.value, isTrue);
  });

  testWidgets(
    'entering a name does not throw a setState/markNeedsBuild-during-build '
    'exception (reactive_forms regression guard)',
    (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('recipe-name-field')),
        'Batido',
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.widgetWithText(TextField, 'Batido'), findsOneWidget);
    },
  );

  group('video rows', () {
    testWidgets('Agregar video adds a source selector and url field', (
      tester,
    ) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('recipe-video-url-field-0')), findsNothing);

      await tester.ensureVisible(find.text('Agregar video'));
      await tester.tap(find.text('Agregar video'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('recipe-video-source-field-0')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('recipe-video-url-field-0')), findsOneWidget);
    });

    testWidgets('removing a video row drops its fields', (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Agregar video'));
      await tester.tap(find.text('Agregar video'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('recipe-video-url-field-0')), findsOneWidget);

      await tester.tap(find.byKey(const Key('recipe-video-remove-0')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('recipe-video-url-field-0')), findsNothing);
    });

    testWidgets('an invalid video url disables Confirm', (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('recipe-name-field')),
        'Batido',
      );
      await tester.ensureVisible(find.text('Agregar video'));
      await tester.tap(find.text('Agregar video'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('recipe-video-url-field-0')),
        'not a url',
      );
      await tester.pumpAndSettle();

      final confirmButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirmar'),
      );
      expect(confirmButton.onPressed, isNull);
    });
  });

  group('save', () {
    testWidgets(
      'Confirm mints an id, saves the Recipe with mealType/enabled/videos '
      'and pops',
      (tester) async {
        when(() => mockRecipeRepository.newId()).thenReturn('r-new');
        when(
          () => mockRecipeRepository.save(any()),
        ).thenAnswer((_) async => const Right(null));

        await pumpPushableScreen(tester);

        await tester.enterText(
          find.byKey(const Key('recipe-name-field')),
          'Batido de fresa',
        );
        await tester.tap(find.byKey(const Key('recipe-meal-type-field')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Merienda').last);
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Agregar video'));
        await tester.tap(find.text('Agregar video'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('recipe-video-url-field-0')),
          'https://youtu.be/xyz',
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Confirmar'));
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        final captured = verify(
          () => mockRecipeRepository.save(captureAny()),
        ).captured;
        final saved = captured.single as Recipe;

        expect(saved.id, 'r-new');
        expect(saved.name, 'Batido de fresa');
        expect(saved.mealType, MealType.merienda);
        expect(saved.enabled, isTrue);
        expect(saved.videos, [
          const VideoLink(
            source: VideoSource.youtube,
            url: 'https://youtu.be/xyz',
          ),
        ]);
        expect(saved.bomLines, isEmpty);
        expect(find.byType(RecipeFormScreen), findsNothing);
      },
    );

    testWidgets('disabling Activa and confirming persists enabled: false', (
      tester,
    ) async {
      when(() => mockRecipeRepository.newId()).thenReturn('r-new');
      when(
        () => mockRecipeRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      await pumpPushableScreen(tester);

      await tester.enterText(
        find.byKey(const Key('recipe-name-field')),
        'Aderezo',
      );
      await tester.tap(find.byKey(const Key('recipe-enabled-field')));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Confirmar'));
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      final captured = verify(
        () => mockRecipeRepository.save(captureAny()),
      ).captured;
      final saved = captured.single as Recipe;

      expect(saved.enabled, isFalse);
    });

    testWidgets(
      'reactivating a disabled recipe via the Activa switch on the edit '
      'form persists enabled: true (Bug C follow-up: reactivation only '
      'happens through this switch, never from a grid-card tap)',
      (tester) async {
        const disabledRecipe = Recipe(
          id: 'r-disabled',
          name: 'Vieja receta',
          enabled: false,
          bomLines: [],
        );
        when(
          () => mockRecipeRepository.getById('r-disabled'),
        ).thenAnswer((_) async => const Right(disabledRecipe));
        when(
          () => mockRecipeRepository.save(any()),
        ).thenAnswer((_) async => const Right(null));

        await pumpPushableScreen(tester, recipeId: 'r-disabled');
        await tester.pumpAndSettle();

        final toggleBefore = tester.widget<SwitchListTile>(
          find.byKey(const Key('recipe-enabled-field')),
        );
        expect(toggleBefore.value, isFalse);

        await tester.tap(find.byKey(const Key('recipe-enabled-field')));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Confirmar'));
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        final captured = verify(
          () => mockRecipeRepository.save(captureAny()),
        ).captured;
        final saved = captured.single as Recipe;

        expect(saved.id, 'r-disabled');
        expect(saved.enabled, isTrue);
      },
    );

    testWidgets(
      'shows a SnackBar and stays on the form when save returns a Failure',
      (tester) async {
        when(() => mockRecipeRepository.newId()).thenReturn('r-new');
        when(() => mockRecipeRepository.save(any())).thenAnswer(
          (_) async => const Left(Failure(message: 'No se pudo guardar.')),
        );

        await pumpPushableScreen(tester);

        await tester.enterText(
          find.byKey(const Key('recipe-name-field')),
          'Fallida',
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Confirmar'));
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        expect(find.text('No se pudo guardar.'), findsOneWidget);
        expect(find.text('Nueva receta'), findsOneWidget);

        // The form stays editable: the name field keeps its typed value and
        // Confirm is still enabled (form validity untouched by the failure).
        expect(find.widgetWithText(TextField, 'Fallida'), findsOneWidget);
        final confirmButton = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Confirmar'),
        );
        expect(confirmButton.onPressed, isNotNull);
      },
    );
  });

  group('edit prefill', () {
    testWidgets('pre-fills name, mealType, enabled, videos and bomLines', (
      tester,
    ) async {
      when(
        () => mockRecipeRepository.getById('r1'),
      ).thenAnswer((_) async => const Right(existingRecipe));

      await pumpScreen(tester, recipeId: 'r1');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Avena con leche'), findsOneWidget);
      expect(find.byKey(const Key('recipe-video-url-field-0')), findsOneWidget);
    });

    testWidgets(
      'still pre-fills when recipeEditProvider is already resolved/cached '
      'before the form mounts (revisit-without-fireImmediately regression '
      'guard: recipeEditProvider is NOT autoDispose, so it stays cached '
      'across screens for the session)',
      (tester) async {
        when(
          () => mockRecipeRepository.getById('r1'),
        ).thenAnswer((_) async => const Right(existingRecipe));

        final container = ProviderContainer(overrides: overrides());
        addTearDown(container.dispose);

        // Resolve recipeEditProvider('r1') to completion BEFORE the form
        // ever mounts — mirrors a real revisit: the family provider is
        // already cached as AsyncData once resolved elsewhere in the
        // session (e.g. an earlier visit to this recipe's edit form).
        await container.read(recipeEditProvider('r1').future);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: RecipeFormScreen(recipeId: 'r1')),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.widgetWithText(TextField, 'Avena con leche'),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('recipe-video-url-field-0')),
          findsOneWidget,
        );
        expect(find.text('Editar receta'), findsOneWidget);
      },
    );

    testWidgets(
      'edit Confirm reuses the existing id, never mints a new one, and '
      'preserves the existing bomLines unchanged',
      (tester) async {
        when(
          () => mockRecipeRepository.getById('r1'),
        ).thenAnswer((_) async => const Right(existingRecipe));
        when(
          () => mockRecipeRepository.save(any()),
        ).thenAnswer((_) async => const Right(null));

        await pumpPushableScreen(tester, recipeId: 'r1');
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('recipe-name-field')),
          'Avena con leche y miel',
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Confirmar'));
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        final captured = verify(
          () => mockRecipeRepository.save(captureAny()),
        ).captured;
        final saved = captured.single as Recipe;

        expect(saved.id, 'r1');
        expect(saved.name, 'Avena con leche y miel');
        expect(saved.bomLines, existingRecipe.bomLines);
        verifyNever(() => mockRecipeRepository.newId());
      },
    );
  });

  group('BOM editor', () {
    testWidgets('renders existing BOM lines on edit', (tester) async {
      when(
        () => mockRecipeRepository.getById('r1'),
      ).thenAnswer((_) async => const Right(existingRecipe));

      await pumpScreen(tester, recipeId: 'r1');
      await tester.pumpAndSettle();

      expect(find.textContaining('Pollo'), findsOneWidget);
      expect(find.widgetWithText(TextField, '2'), findsOneWidget);
    });

    testWidgets(
      'Agregar ingrediente opens the picker; picking an ingredient fills '
      'the line',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        expect(find.text('Seleccionar ingrediente'), findsNothing);

        await tester.ensureVisible(find.text('Agregar ingrediente'));
        await tester.tap(find.text('Agregar ingrediente'));
        await tester.pumpAndSettle();

        expect(find.text('Seleccionar ingrediente'), findsOneWidget);

        await tester.tap(
          find.byKey(const Key('recipe-bom-ingredient-field-0')),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Huevo'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Huevo'), findsOneWidget);
        expect(find.text('Seleccionar ingrediente'), findsNothing);
      },
    );

    testWidgets(
      'save persists a new BOM line with the picked ingredient, quantity '
      "and a unit from that ingredient's derived set",
      (tester) async {
        when(() => mockRecipeRepository.newId()).thenReturn('r-new');
        when(
          () => mockRecipeRepository.save(any()),
        ).thenAnswer((_) async => const Right(null));

        await pumpPushableScreen(tester);

        await tester.enterText(
          find.byKey(const Key('recipe-name-field')),
          'Tortilla',
        );

        await tester.ensureVisible(find.text('Agregar ingrediente'));
        await tester.tap(find.text('Agregar ingrediente'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('recipe-bom-ingredient-field-0')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Leche'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('recipe-bom-quantity-field-0')),
          '3',
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('recipe-bom-unit-field-0')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Mililitros (ml)').last);
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Confirmar'));
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        final captured = verify(
          () => mockRecipeRepository.save(captureAny()),
        ).captured;
        final saved = captured.single as Recipe;

        expect(saved.bomLines, [
          const BomLine(
            recipeId: 'r-new',
            ingredientId: 'ing-leche',
            quantity: Quantity(value: 3, unit: Unit.milliliter),
          ),
        ]);
      },
    );

    testWidgets('removing a BOM line drops it from the saved recipe', (
      tester,
    ) async {
      when(
        () => mockRecipeRepository.getById('r1'),
      ).thenAnswer((_) async => const Right(existingRecipe));
      when(
        () => mockRecipeRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      await pumpPushableScreen(tester, recipeId: 'r1');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('recipe-bom-remove-0')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Pollo'), findsNothing);

      await tester.ensureVisible(find.text('Confirmar'));
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      final captured = verify(
        () => mockRecipeRepository.save(captureAny()),
      ).captured;
      final saved = captured.single as Recipe;

      expect(saved.bomLines, isEmpty);
    });

    testWidgets(
      'editing an existing line quantity and unit persists the new values',
      (tester) async {
        // The BOM line's ingredient (leche) has a conversionFactor, so its
        // derived set includes taza/cda in addition to L/ml — pollo/huevo
        // (count-mode, no factor) only ever offer {u}, so they can't cover
        // this "switch to a soft unit" scenario.
        const existingRecipeWithLeche = Recipe(
          id: 'r1',
          name: 'Avena con leche',
          emoji: '🥣',
          mealType: MealType.desayuno,
          enabled: true,
          videos: [
            VideoLink(source: VideoSource.youtube, url: 'https://youtu.be/abc'),
          ],
          bomLines: [
            BomLine(
              recipeId: 'r1',
              ingredientId: 'ing-leche',
              quantity: Quantity(value: 2, unit: Unit.liter),
            ),
          ],
        );

        when(
          () => mockRecipeRepository.getById('r1'),
        ).thenAnswer((_) async => const Right(existingRecipeWithLeche));
        when(
          () => mockRecipeRepository.save(any()),
        ).thenAnswer((_) async => const Right(null));

        await pumpPushableScreen(tester, recipeId: 'r1');
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('recipe-bom-quantity-field-0')),
          '5',
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('recipe-bom-unit-field-0')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Taza').last);
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Confirmar'));
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        final captured = verify(
          () => mockRecipeRepository.save(captureAny()),
        ).captured;
        final saved = captured.single as Recipe;

        expect(saved.bomLines, [
          const BomLine(
            recipeId: 'r1',
            ingredientId: 'ing-leche',
            quantity: Quantity(value: 5, unit: Unit.cup),
          ),
        ]);
      },
    );

    group('validation', () {
      testWidgets('a line with no ingredient selected disables Confirm', (
        tester,
      ) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('recipe-name-field')),
          'Sopa',
        );
        await tester.ensureVisible(find.text('Agregar ingrediente'));
        await tester.tap(find.text('Agregar ingrediente'));
        await tester.pumpAndSettle();

        final confirmButton = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Confirmar'),
        );
        expect(confirmButton.onPressed, isNull);
      });

      testWidgets('a line with an empty quantity disables Confirm', (
        tester,
      ) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('recipe-name-field')),
          'Sopa',
        );
        await tester.ensureVisible(find.text('Agregar ingrediente'));
        await tester.tap(find.text('Agregar ingrediente'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('recipe-bom-ingredient-field-0')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Huevo'));
        await tester.pumpAndSettle();

        final confirmButton = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Confirmar'),
        );
        expect(confirmButton.onPressed, isNull);
      });
    });

    testWidgets('the picker has no inline "create ingredient" action (product '
        'decision: ingredients are created only from the Ingredients screen)', (
      tester,
    ) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Agregar ingrediente'));
      await tester.tap(find.text('Agregar ingrediente'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('recipe-bom-ingredient-field-0')));
      await tester.pumpAndSettle();

      expect(find.text('＋ Nuevo ingrediente'), findsNothing);
    });
  });
}
