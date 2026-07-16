import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_detail_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_edit_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_submission_provider.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  late MockRecipeRepository mockRepository;
  late ProviderContainer container;

  const recipe = Recipe(id: 'r1', name: 'Avena', bomLines: []);

  setUpAll(() {
    registerFallbackValue(const Recipe(id: '', name: '', bomLines: []));
  });

  setUp(() {
    mockRepository = MockRecipeRepository();
    container = ProviderContainer(
      overrides: [recipeRepositoryProvider.overrideWithValue(mockRepository)],
    );
    addTearDown(container.dispose);
  });

  test('build returns AsyncData(null) initially', () {
    expect(
      container.read(recipeSubmissionProvider),
      const AsyncData<void>(null),
    );
  });

  test('submit sets state to AsyncData(null) on success', () async {
    when(
      () => mockRepository.save(any()),
    ).thenAnswer((_) async => const Right(null));

    await container.read(recipeSubmissionProvider.notifier).submit(recipe);

    expect(
      container.read(recipeSubmissionProvider),
      const AsyncData<void>(null),
    );
    verify(() => mockRepository.save(recipe)).called(1);
  });

  test('submit sets state to AsyncError on failure', () async {
    final failure = Failure(message: 'No se pudo guardar.');
    when(
      () => mockRepository.save(any()),
    ).thenAnswer((_) async => Left(failure));

    await container.read(recipeSubmissionProvider.notifier).submit(recipe);

    final state = container.read(recipeSubmissionProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<FailureException>());
    expect((state.error! as FailureException).failure, failure);
  });

  test(
    'submit invalidates the list/filtered/ingredients providers on success',
    () async {
      when(
        () => mockRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => mockRepository.list(),
      ).thenAnswer((_) async => const Right([recipe]));

      // First read primes the provider's cache.
      await container.read(recipeListProvider.future);
      verify(() => mockRepository.list()).called(1);

      await container.read(recipeSubmissionProvider.notifier).submit(recipe);

      // A second read after invalidation must hit the repository again.
      await container.read(recipeListProvider.future);
      verify(() => mockRepository.list()).called(1);
    },
  );

  test(
    'submit invalidates recipeDetailProvider(id) so an open detail refreshes',
    () async {
      when(
        () => mockRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => mockRepository.getById('r1'),
      ).thenAnswer((_) async => const Right(recipe));

      await container.read(recipeDetailProvider('r1').future);
      verify(() => mockRepository.getById('r1')).called(1);

      await container.read(recipeSubmissionProvider.notifier).submit(recipe);

      await container.read(recipeDetailProvider('r1').future);
      verify(() => mockRepository.getById('r1')).called(1);
    },
  );

  test('submit invalidates recipeEditProvider(id) so a re-opened edit form '
      'refetches', () async {
    when(
      () => mockRepository.save(any()),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => mockRepository.getById('r1'),
    ).thenAnswer((_) async => const Right(recipe));

    await container.read(recipeEditProvider('r1').future);
    verify(() => mockRepository.getById('r1')).called(1);

    await container.read(recipeSubmissionProvider.notifier).submit(recipe);

    await container.read(recipeEditProvider('r1').future);
    verify(() => mockRepository.getById('r1')).called(1);
  });
}
