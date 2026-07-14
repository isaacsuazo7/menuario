import 'package:dartz/dartz.dart' hide Unit;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/data/datasources/recipe_data_source.dart';
import 'package:menuario/src/shared/data/repositories/recipe_repository_impl.dart';
import 'package:menuario/src/shared/domain/entities/bom_line.dart';
import 'package:menuario/src/shared/domain/entities/recipe.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  group('RecipeRepositoryImpl', () {
    late FakeFirebaseFirestore firestore;
    late RecipeDataSource dataSource;
    late RecipeRepositoryImpl repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      dataSource = RecipeDataSourceImpl(firestore: firestore, uid: 'uid-A');
      repository = RecipeRepositoryImpl(dataSource: dataSource);
    });

    test(
      'save then getById round-trips the Recipe entity, id and BomLines '
      'preserved',
      () async {
        // Arrange
        const recipe = Recipe(
          id: 'recipe-1',
          name: 'Avena con leche',
          bomLines: [
            BomLine(
              recipeId: 'recipe-1',
              ingredientId: 'ingredient-avena',
              quantity: Quantity(value: 2, unit: Unit.gram),
            ),
          ],
        );

        // Act
        final saveResult = await repository.save(recipe);
        final getResult = await repository.getById('recipe-1');

        // Assert
        expect(saveResult, const Right<Failure, void>(null));
        expect(getResult, isA<Right<Failure, Recipe>>());
        getResult.fold(
          (failure) => fail('expected Right, got Left($failure)'),
          (readRecipe) => expect(readRecipe, recipe),
        );
      },
    );

    test('list returns every saved Recipe as entities', () async {
      // Arrange
      const first = Recipe(id: 'recipe-1', name: 'Avena', bomLines: []);
      const second = Recipe(id: 'recipe-2', name: 'Ensalada', bomLines: []);
      await repository.save(first);
      await repository.save(second);

      // Act
      final result = await repository.list();

      // Assert
      expect(result, isA<Right<Failure, List<Recipe>>>());
      result.fold(
        (failure) => fail('expected Right, got Left($failure)'),
        (recipes) => expect(recipes.toSet(), {first, second}),
      );
    });

    test(
      'getById propagates Left(Failure) from the datasource without '
      'throwing',
      () async {
        // Act
        final result = await repository.getById('missing');

        // Assert
        expect(result, isA<Left<Failure, Recipe>>());
      },
    );
  });
}
