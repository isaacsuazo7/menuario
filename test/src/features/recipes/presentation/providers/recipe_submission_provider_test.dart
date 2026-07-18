import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/features/recipes/presentation/providers/filtered_recipes_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_detail_provider.dart';
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

  test('submit patches an edited recipe into recipeListProvider in '
      'place, without refetching', () async {
    const other = Recipe(id: 'r2', name: 'Filete', bomLines: []);
    const edited = Recipe(id: 'r1', name: 'Avena con miel', bomLines: []);
    when(
      () => mockRepository.save(any()),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => mockRepository.list(),
    ).thenAnswer((_) async => const Right([recipe, other]));

    await container.read(recipeListProvider.future);
    container.listen(recipeListProvider, (_, _) {});
    verify(() => mockRepository.list()).called(1);

    await container.read(recipeSubmissionProvider.notifier).submit(edited);

    // El parche es en sitio: nada que reconstruir después (no invalida).
    expect(container.read(recipeListProvider).value, [edited, other]);
    verifyNever(() => mockRepository.list());
  });

  test('submit appends a newly created recipe to recipeListProvider', () async {
    const created = Recipe(id: 'r9', name: 'Sopa', bomLines: []);
    when(
      () => mockRepository.save(any()),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => mockRepository.list(),
    ).thenAnswer((_) async => const Right([recipe]));

    await container.read(recipeListProvider.future);
    container.listen(recipeListProvider, (_, _) {});

    await container.read(recipeSubmissionProvider.notifier).submit(created);

    expect(container.read(recipeListProvider).value, [recipe, created]);
  });

  test('submit propagates the patch to filteredRecipesProvider', () async {
    const edited = Recipe(id: 'r1', name: 'Avena con miel', bomLines: []);
    when(
      () => mockRepository.save(any()),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => mockRepository.list(),
    ).thenAnswer((_) async => const Right([recipe]));

    await container.read(recipeListProvider.future);
    container.listen(filteredRecipesProvider(null), (_, _) {});

    await container.read(recipeSubmissionProvider.notifier).submit(edited);

    expect(container.read(filteredRecipesProvider(null)).value, [edited]);
  });

  test('submit leaves recipeDetailProvider(id) resolving to the patched '
      'recipe without refetching it', () async {
    const edited = Recipe(id: 'r1', name: 'Avena con miel', bomLines: []);
    when(
      () => mockRepository.save(any()),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => mockRepository.list(),
    ).thenAnswer((_) async => const Right([recipe]));
    when(
      () => mockRepository.getById('r1'),
    ).thenAnswer((_) async => const Right(recipe));

    await container.read(recipeListProvider.future);
    container.listen(recipeListProvider, (_, _) {});
    container.listen(recipeDetailProvider('r1'), (_, _) {});
    await container.read(recipeDetailProvider('r1').future);

    await container.read(recipeSubmissionProvider.notifier).submit(edited);

    expect(await container.read(recipeDetailProvider('r1').future), edited);
    // La lista ya estaba cargada: el detalle la reusa en vez de ir al repo.
    verifyNever(() => mockRepository.getById('r1'));
  });
}
