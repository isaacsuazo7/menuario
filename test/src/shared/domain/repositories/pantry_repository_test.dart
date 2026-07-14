import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/entities/pantry_item.dart';
import 'package:menuario/src/shared/domain/repositories/pantry_repository.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/presentation.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';
import 'package:mocktail/mocktail.dart';

class MockPantryRepository extends Mock implements PantryRepository {}

void main() {
  late MockPantryRepository repository;

  const pantryItem = PantryItem.quantityTracked(
    ingredientId: 'ingredient-avena',
    category: Category.cereal,
    presentation: Presentation.package(yieldQty: 454, label: 'bolsa'),
    stock: Quantity(value: 200, unit: Unit.gram),
  );
  final failure = Failure(message: 'no encontrado', code: 'notFound');

  setUpAll(() {
    registerFallbackValue(pantryItem);
  });

  setUp(() {
    repository = MockPantryRepository();
  });

  group('PantryRepository contract', () {
    group('getById', () {
      test('should return Right(PantryItem) when it exists', () async {
        // Arrange
        when(
          () => repository.getById('ingredient-avena'),
        ).thenAnswer((_) async => const Right(pantryItem));

        // Act
        final result = await repository.getById('ingredient-avena');

        // Assert
        expect(result, const Right<Failure, PantryItem>(pantryItem));
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
        expect(result, Left<Failure, PantryItem>(failure));
      });
    });

    group('list', () {
      test(
        'should return Right(List<PantryItem>) with the full pantry',
        () async {
          // Arrange
          when(
            () => repository.list(),
          ).thenAnswer((_) async => const Right(<PantryItem>[pantryItem]));

          // Act
          final result = await repository.list();

          // Assert
          expect(
            result,
            const Right<Failure, List<PantryItem>>(<PantryItem>[pantryItem]),
          );
        },
      );

      test('should return Left(Failure) when listing fails', () async {
        // Arrange
        when(() => repository.list()).thenAnswer((_) async => Left(failure));

        // Act
        final result = await repository.list();

        // Assert
        expect(result, Left<Failure, List<PantryItem>>(failure));
      });
    });

    group('save', () {
      test('should return Right(null) when saving succeeds', () async {
        // Arrange
        when(
          () => repository.save(pantryItem),
        ).thenAnswer((_) async => const Right(null));

        // Act
        final result = await repository.save(pantryItem);

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(() => repository.save(pantryItem)).called(1);
      });

      test('should return Left(Failure) when saving fails', () async {
        // Arrange
        when(
          () => repository.save(pantryItem),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await repository.save(pantryItem);

        // Assert
        expect(result, Left<Failure, void>(failure));
      });
    });
  });
}
