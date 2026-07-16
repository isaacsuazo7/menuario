import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_edit_provider.dart';
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

  test('a null id resolves to null without hitting the repository', () async {
    final container = makeContainer();

    final result = await container.read(recipeEditProvider(null).future);

    expect(result, isNull);
    verifyNever(() => mockRecipeRepository.getById(any()));
  });

  test('a non-null id resolves to the matching Recipe', () async {
    const recipe = Recipe(id: 'r1', name: 'Avena', bomLines: []);
    when(
      () => mockRecipeRepository.getById('r1'),
    ).thenAnswer((_) async => const Right(recipe));

    final container = makeContainer();

    final result = await container.read(recipeEditProvider('r1').future);

    expect(result, recipe);
  });

  test('throws a FailureException on failure', () async {
    when(
      () => mockRecipeRepository.getById('missing'),
    ).thenAnswer((_) async => Left(Failure(message: 'not found')));

    final container = makeContainer();

    await expectLater(
      container.read(recipeEditProvider('missing').future),
      throwsA(isA<FailureException>()),
    );
  });
}
