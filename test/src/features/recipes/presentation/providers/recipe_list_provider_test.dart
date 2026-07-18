import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  late MockRecipeRepository mockRecipeRepository;

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('resolves to the repository list on success', () async {
    const recipe = Recipe(id: 'r1', name: 'Avena', bomLines: []);
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([recipe]));

    final container = makeContainer();

    final result = await container.read(recipeListProvider.future);

    expect(result, [recipe]);
  });

  test('throws a FailureException on failure', () async {
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => Left(Failure(message: 'boom')));

    final container = makeContainer();

    await expectLater(
      container.read(recipeListProvider.future),
      throwsA(isA<FailureException>()),
    );
  });

  group('upsertRecipe', () {
    const avena = Recipe(id: 'r1', name: 'Avena', bomLines: []);
    const filete = Recipe(id: 'r2', name: 'Filete', bomLines: []);

    test('replaces an existing recipe in its current position', () async {
      when(
        () => mockRecipeRepository.list(),
      ).thenAnswer((_) async => const Right([avena, filete]));

      final container = makeContainer();
      await container.read(recipeListProvider.future);

      const edited = Recipe(id: 'r1', name: 'Avena con miel', bomLines: []);
      container.read(recipeListProvider.notifier).upsertRecipe(edited);

      expect(container.read(recipeListProvider).value, [edited, filete]);
    });

    test('appends a recipe that is not in the list yet', () async {
      when(
        () => mockRecipeRepository.list(),
      ).thenAnswer((_) async => const Right([avena]));

      final container = makeContainer();
      await container.read(recipeListProvider.future);

      container.read(recipeListProvider.notifier).upsertRecipe(filete);

      expect(container.read(recipeListProvider).value, [avena, filete]);
    });

    test('is a no-op while the list has not loaded yet', () async {
      when(() => mockRecipeRepository.list()).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return const Right([avena]);
      });

      final container = makeContainer();
      container.listen(recipeListProvider, (_, _) {});

      container.read(recipeListProvider.notifier).upsertRecipe(filete);

      expect(container.read(recipeListProvider).value, isNull);
    });
  });
}
