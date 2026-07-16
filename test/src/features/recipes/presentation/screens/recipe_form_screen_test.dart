import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/recipes/presentation/screens/recipe_form_screen.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  late MockRecipeRepository mockRecipeRepository;

  setUpAll(() {
    registerFallbackValue(const Recipe(id: '', name: '', bomLines: []));
  });

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
  });

  overrides() => [
    recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
  ];

  Future<void> pumpScreen(WidgetTester tester, {String? recipeId}) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(home: RecipeFormScreen(recipeId: recipeId)),
      ),
    );
  }

  /// Pumps the form behind a pushable route so pop-on-success is
  /// observable (mirrors `ingredient_form_screen_test.dart`).
  Future<void> pumpPushableScreen(
    WidgetTester tester, {
    String? recipeId,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => RecipeFormScreen(recipeId: recipeId),
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

  testWidgets('shows the edit title when recipeId is provided', (
    tester,
  ) async {
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
      expect(
        find.byKey(const Key('recipe-video-url-field-0')),
        findsOneWidget,
      );
    });

    testWidgets('removing a video row drops its fields', (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Agregar video'));
      await tester.tap(find.text('Agregar video'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('recipe-video-url-field-0')),
        findsOneWidget,
      );

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

    testWidgets(
      'disabling Activa and confirming persists enabled: false',
      (tester) async {
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

      expect(
        find.widgetWithText(TextField, 'Avena con leche'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('recipe-video-url-field-0')),
        findsOneWidget,
      );
    });

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
}
