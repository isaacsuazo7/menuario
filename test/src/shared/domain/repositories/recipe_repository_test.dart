import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/entities/bom_line.dart';
import 'package:menuario/src/shared/domain/entities/recipe.dart';
import 'package:menuario/src/shared/domain/repositories/recipe_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  late MockRecipeRepository repository;

  const recipe = Recipe(
    id: 'recipe-avena',
    name: 'Avena con leche',
    bomLines: <BomLine>[],
  );
  final failure = Failure(message: 'no encontrado', code: 'notFound');

  setUpAll(() {
    registerFallbackValue(recipe);
  });

  setUp(() {
    repository = MockRecipeRepository();
  });

  group('RecipeRepository contract', () {
    group('getById', () {
      test('should return Right(Recipe) when the recipe exists', () async {
        // Arrange
        when(
          () => repository.getById('recipe-avena'),
        ).thenAnswer((_) async => const Right(recipe));

        // Act
        final result = await repository.getById('recipe-avena');

        // Assert
        expect(result, const Right<Failure, Recipe>(recipe));
        verify(() => repository.getById('recipe-avena')).called(1);
      });

      test(
        'should return Left(Failure) when the recipe is not found',
        () async {
          // Arrange
          when(
            () => repository.getById('missing'),
          ).thenAnswer((_) async => Left(failure));

          // Act
          final result = await repository.getById('missing');

          // Assert
          expect(result, Left<Failure, Recipe>(failure));
        },
      );
    });

    group('list', () {
      test('should return Right(List<Recipe>) with all recipes', () async {
        // Arrange
        when(
          () => repository.list(),
        ).thenAnswer((_) async => const Right(<Recipe>[recipe]));

        // Act
        final result = await repository.list();

        // Assert
        expect(result, const Right<Failure, List<Recipe>>(<Recipe>[recipe]));
      });

      test('should return Left(Failure) when listing fails', () async {
        // Arrange
        when(() => repository.list()).thenAnswer((_) async => Left(failure));

        // Act
        final result = await repository.list();

        // Assert
        expect(result, Left<Failure, List<Recipe>>(failure));
      });
    });

    group('save', () {
      test('should return Right(null) when saving succeeds', () async {
        // Arrange
        when(
          () => repository.save(recipe),
        ).thenAnswer((_) async => const Right(null));

        // Act
        final result = await repository.save(recipe);

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(() => repository.save(recipe)).called(1);
      });

      test('should return Left(Failure) when saving fails', () async {
        // Arrange
        when(
          () => repository.save(recipe),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await repository.save(recipe);

        // Assert
        expect(result, Left<Failure, void>(failure));
      });
    });
  });
}
