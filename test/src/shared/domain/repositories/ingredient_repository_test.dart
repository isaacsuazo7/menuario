import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/repositories/ingredient_repository.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:mocktail/mocktail.dart';

class MockIngredientRepository extends Mock implements IngredientRepository {}

void main() {
  late MockIngredientRepository repository;

  const ingredient = Ingredient(
    id: 'ingredient-avena',
    name: 'Avena',
    category: Category.cereal,
    conversionFactor: 85,
  );
  final failure = Failure(message: 'no encontrado', code: 'notFound');

  setUpAll(() {
    registerFallbackValue(ingredient);
  });

  setUp(() {
    repository = MockIngredientRepository();
  });

  group('IngredientRepository contract', () {
    group('getById', () {
      test('should return Right(Ingredient) when it exists', () async {
        // Arrange
        when(
          () => repository.getById('ingredient-avena'),
        ).thenAnswer((_) async => const Right(ingredient));

        // Act
        final result = await repository.getById('ingredient-avena');

        // Assert
        expect(result, const Right<Failure, Ingredient>(ingredient));
        verify(() => repository.getById('ingredient-avena')).called(1);
      });

      test('should return Left(Failure) when not found', () async {
        // Arrange
        when(
          () => repository.getById('missing'),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await repository.getById('missing');

        // Assert
        expect(result, Left<Failure, Ingredient>(failure));
      });
    });

    group('list', () {
      test(
        'should return Right(List<Ingredient>) with all ingredients',
        () async {
          // Arrange
          when(
            () => repository.list(),
          ).thenAnswer((_) async => const Right(<Ingredient>[ingredient]));

          // Act
          final result = await repository.list();

          // Assert
          expect(
            result,
            const Right<Failure, List<Ingredient>>(<Ingredient>[ingredient]),
          );
        },
      );

      test('should return Left(Failure) when listing fails', () async {
        // Arrange
        when(() => repository.list()).thenAnswer((_) async => Left(failure));

        // Act
        final result = await repository.list();

        // Assert
        expect(result, Left<Failure, List<Ingredient>>(failure));
      });
    });

    group('save', () {
      test('should return Right(null) when saving succeeds', () async {
        // Arrange
        when(
          () => repository.save(ingredient),
        ).thenAnswer((_) async => const Right(null));

        // Act
        final result = await repository.save(ingredient);

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(() => repository.save(ingredient)).called(1);
      });

      test('should return Left(Failure) when saving fails', () async {
        // Arrange
        when(
          () => repository.save(ingredient),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await repository.save(ingredient);

        // Assert
        expect(result, Left<Failure, void>(failure));
      });
    });
  });
}
