import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/features/recipes/presentation/providers/ingredients_by_id_provider.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockIngredientRepository extends Mock implements IngredientRepository {}

void main() {
  late MockIngredientRepository mockIngredientRepository;

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

  test('resolves to a map keyed by ingredient id', () async {
    const huevo = Ingredient(
      id: 'i1',
      name: 'Huevo',
      category: Category.proteina,
    );
    const avena = Ingredient(
      id: 'i2',
      name: 'Avena',
      category: Category.cereal,
      conversionFactor: 85,
    );
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([huevo, avena]));

    final container = makeContainer();

    final result = await container.read(ingredientsByIdProvider.future);

    expect(result, {'i1': huevo, 'i2': avena});
  });

  test('throws a FailureException on failure', () async {
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => Left(Failure(message: 'boom')));

    final container = makeContainer();

    await expectLater(
      container.read(ingredientsByIdProvider.future),
      throwsA(isA<FailureException>()),
    );
  });
}
