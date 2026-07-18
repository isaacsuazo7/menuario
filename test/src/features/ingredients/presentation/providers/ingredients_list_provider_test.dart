import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredients_list_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/ingredients_by_id_provider.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockIngredientRepository extends Mock implements IngredientRepository {}

void main() {
  late MockIngredientRepository mockIngredientRepository;

  const huevo = Ingredient(
    id: 'i1',
    name: 'Huevo',
    category: Category.proteina,
  );
  const avena = Ingredient(id: 'i2', name: 'Avena', category: Category.cereal);

  setUp(() {
    mockIngredientRepository = MockIngredientRepository();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        ingredientRepositoryProvider.overrideWithValue(
          mockIngredientRepository,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('resolves to the repository list on success', () async {
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([huevo, avena]));

    final container = makeContainer();

    expect(await container.read(ingredientsListProvider.future), [
      huevo,
      avena,
    ]);
  });

  test('throws a FailureException on failure', () async {
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => Left(Failure(message: 'boom')));

    final container = makeContainer();

    await expectLater(
      container.read(ingredientsListProvider.future),
      throwsA(isA<FailureException>()),
    );
  });

  group('upsertIngredient', () {
    test('replaces an existing ingredient in its current position', () async {
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([huevo, avena]));

      final container = makeContainer();
      await container.read(ingredientsListProvider.future);

      const edited = Ingredient(
        id: 'i1',
        name: 'Huevo de campo',
        category: Category.proteina,
      );
      container
          .read(ingredientsListProvider.notifier)
          .upsertIngredient(edited);

      expect(container.read(ingredientsListProvider).value, [edited, avena]);
    });

    test('appends an ingredient that is not in the list yet', () async {
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([huevo]));

      final container = makeContainer();
      await container.read(ingredientsListProvider.future);

      container.read(ingredientsListProvider.notifier).upsertIngredient(avena);

      expect(container.read(ingredientsListProvider).value, [huevo, avena]);
    });

    test('is a no-op while the list has not loaded yet', () async {
      when(() => mockIngredientRepository.list()).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return const Right([huevo]);
      });

      final container = makeContainer();
      container.listen(ingredientsListProvider, (_, _) {});

      container.read(ingredientsListProvider.notifier).upsertIngredient(avena);

      expect(container.read(ingredientsListProvider).value, isNull);
    });

    test('propagates to the derived ingredientsByIdProvider', () async {
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([huevo]));

      final container = makeContainer();
      await container.read(ingredientsListProvider.future);
      container.listen(ingredientsByIdProvider, (_, _) {});

      container.read(ingredientsListProvider.notifier).upsertIngredient(avena);

      expect(await container.read(ingredientsByIdProvider.future), {
        'i1': huevo,
        'i2': avena,
      });
      // Una sola carga: el mapa deriva de la lista, no refetchea.
      verify(() => mockIngredientRepository.list()).called(1);
    });
  });
}
