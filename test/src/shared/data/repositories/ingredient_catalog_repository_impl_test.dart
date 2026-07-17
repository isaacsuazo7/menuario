import 'package:dartz/dartz.dart' hide Unit;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/data/datasources/ingredient_catalog_data_source.dart';
import 'package:menuario/src/shared/data/models/ingredient_dto.dart';
import 'package:menuario/src/shared/data/models/pantry_item_dto.dart';
import 'package:menuario/src/shared/data/repositories/ingredient_catalog_repository_impl.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/entities/pantry_item.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';
import 'package:mocktail/mocktail.dart';

class MockIngredientCatalogDataSource extends Mock
    implements IngredientCatalogDataSource {}

void main() {
  group('IngredientCatalogRepositoryImpl (fake_cloud_firestore)', () {
    late FakeFirebaseFirestore firestore;
    late IngredientCatalogDataSource dataSource;
    late IngredientCatalogRepositoryImpl repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      dataSource = IngredientCatalogDataSourceImpl(
        firestore: firestore,
        uid: 'uid-A',
      );
      repository = IngredientCatalogRepositoryImpl(dataSource: dataSource);
    });

    test(
      'saveWithPantry writes both docs for a quantity-tracked entity pair',
      () async {
        // Arrange
        const ingredient = Ingredient(
          id: 'ingredient-avena',
          name: 'Avena',
          category: Category.cereal,
          conversionFactor: 85,
        );
        const pantryItem = PantryItem.quantityTracked(
          ingredientId: 'ingredient-avena',
          category: Category.cereal,
          stock: Quantity(value: 2, unit: Unit.gram),
        );

        // Act
        final result = await repository.saveWithPantry(
          ingredient: ingredient,
          pantryItem: pantryItem,
        );

        // Assert
        expect(result, const Right<Failure, void>(null));
        final ingredientDoc = await firestore
            .collection('users/uid-A/ingredients')
            .doc('ingredient-avena')
            .get();
        final pantryDoc = await firestore
            .collection('users/uid-A/pantry')
            .doc('ingredient-avena')
            .get();
        expect(
          IngredientDTO.fromJson(ingredientDoc.data()!),
          IngredientDTO.fromEntity(ingredient),
        );
        expect(
          PantryItemDTO.fromJson(pantryDoc.data()!),
          PantryItemDTO.fromEntity(pantryItem),
        );
      },
    );

    test(
      'saveWithPantry writes both docs for a boolean-tracked entity pair',
      () async {
        // Arrange
        const ingredient = Ingredient(
          id: 'ingredient-comino',
          name: 'Comino',
          category: Category.condimento,
        );
        const pantryItem = PantryItem.booleanTracked(
          ingredientId: 'ingredient-comino',
          category: Category.condimento,
          haveIt: false,
        );

        // Act
        final result = await repository.saveWithPantry(
          ingredient: ingredient,
          pantryItem: pantryItem,
        );

        // Assert
        expect(result, const Right<Failure, void>(null));
        final pantryDoc = await firestore
            .collection('users/uid-A/pantry')
            .doc('ingredient-comino')
            .get();
        expect(
          PantryItemDTO.fromJson(pantryDoc.data()!),
          PantryItemDTO.fromEntity(pantryItem),
        );
      },
    );

    test('newId delegates to the datasource', () {
      // Act
      final id = repository.newId();

      // Assert
      expect(id, isNotEmpty);
    });
  });

  group('IngredientCatalogRepositoryImpl (mocktail failure path)', () {
    late MockIngredientCatalogDataSource mockDataSource;
    late IngredientCatalogRepositoryImpl repository;

    const ingredient = Ingredient(
      id: 'ingredient-avena',
      name: 'Avena',
      category: Category.cereal,
      conversionFactor: 85,
    );
    const pantryItem = PantryItem.quantityTracked(
      ingredientId: 'ingredient-avena',
      category: Category.cereal,
      stock: Quantity(value: 2, unit: Unit.gram),
    );

    setUpAll(() {
      registerFallbackValue(IngredientDTO.fromEntity(ingredient));
      registerFallbackValue(PantryItemDTO.fromEntity(pantryItem));
    });

    setUp(() {
      mockDataSource = MockIngredientCatalogDataSource();
      repository = IngredientCatalogRepositoryImpl(dataSource: mockDataSource);
    });

    test('saveWithPantry returns Left(Failure) when the batch commit fails, '
        'without writing any partial state', () async {
      // Arrange
      final failure = Failure.firestore(
        code: 'unavailable',
        message: 'commit failed',
      );
      when(
        () => mockDataSource.saveWithPantry(any(), any(), any()),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await repository.saveWithPantry(
        ingredient: ingredient,
        pantryItem: pantryItem,
      );

      // Assert
      expect(result, Left<Failure, void>(failure));
      verify(
        () => mockDataSource.saveWithPantry(
          'ingredient-avena',
          IngredientDTO.fromEntity(ingredient),
          PantryItemDTO.fromEntity(pantryItem),
        ),
      ).called(1);
    });
  });
}
