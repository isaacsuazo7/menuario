import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockPantryRepository extends Mock implements PantryRepository {}

class MockIngredientRepository extends Mock implements IngredientRepository {}

void main() {
  late MockPantryRepository mockPantryRepository;
  late MockIngredientRepository mockIngredientRepository;

  const avena = Ingredient(
    id: 'ing-avena',
    name: 'Avena',
    emoji: '🥣',
    category: Category.cereal,
    conversionFactor: 85,
  );
  const comino = Ingredient(
    id: 'ing-comino',
    name: 'Comino',
    emoji: '🌿',
    category: Category.condimento,
  );
  const zanahoria = Ingredient(
    id: 'ing-zanahoria',
    name: 'Zanahoria',
    emoji: '🥕',
    category: Category.vegetal,
    conversionFactor: 50,
  );

  const avenaItem = PantryItem.quantityTracked(
    ingredientId: 'ing-avena',
    category: Category.cereal,
    stock: Quantity(value: 2, unit: Unit.gram),
  );
  const cominoItem = PantryItem.booleanTracked(
    ingredientId: 'ing-comino',
    category: Category.condimento,
    haveIt: false,
  );
  const zanahoriaItem = PantryItem.quantityTracked(
    ingredientId: 'ing-zanahoria',
    category: Category.vegetal,
    stock: Quantity(value: 5, unit: Unit.gram),
  );

  final failure = Failure(message: 'no se pudo guardar', code: 'save-fail');

  setUpAll(() {
    registerFallbackValue(avenaItem);
  });

  setUp(() {
    mockPantryRepository = MockPantryRepository();
    mockIngredientRepository = MockIngredientRepository();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        pantryRepositoryProvider.overrideWithValue(mockPantryRepository),
        ingredientRepositoryProvider.overrideWithValue(
          mockIngredientRepository,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('build', () {
    test('resolves pantry items across multiple categories to rows', () async {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([avenaItem, cominoItem]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([avena, comino]));

      final container = makeContainer();

      final rows = await container.read(pantryControllerProvider.future);

      expect(rows, hasLength(2));
      expect(rows[0].item, avenaItem);
      expect(rows[0].ingredient, avena);
      expect(rows[1].item, cominoItem);
      expect(rows[1].ingredient, comino);
    });

    test('resolves to an empty list for an empty pantry', () async {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([]));

      final container = makeContainer();

      final rows = await container.read(pantryControllerProvider.future);

      expect(rows, isEmpty);
    });

    test(
      'throws a FailureException when the pantry repository fails',
      () async {
        when(
          () => mockPantryRepository.list(),
        ).thenAnswer((_) async => Left(failure));
        when(
          () => mockIngredientRepository.list(),
        ).thenAnswer((_) async => const Right([avena]));

        final container = makeContainer();

        await expectLater(
          container.read(pantryControllerProvider.future),
          throwsA(isA<FailureException>()),
        );
      },
    );
  });

  group('adjustStock', () {
    test('optimistically patches stock then persists via save', () async {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([avenaItem]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([avena]));
      when(
        () => mockPantryRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      final container = makeContainer();
      await container.read(pantryControllerProvider.future);
      final notifier = container.read(pantryControllerProvider.notifier);

      final resultFuture = notifier.adjustStock('ing-avena', 1);

      // Optimistic patch is applied synchronously, before save() resolves.
      final optimisticRow = container
          .read(pantryControllerProvider)
          .value!
          .single;
      final optimisticItem = optimisticRow.item as QuantityTrackedPantryItem;
      expect(optimisticItem.stock.value, 3);

      final result = await resultFuture;

      expect(result, isNull);
      final captured = verify(
        () => mockPantryRepository.save(captureAny()),
      ).captured;
      final savedItem = captured.single as QuantityTrackedPantryItem;
      expect(savedItem.stock.value, 3);
    });

    test(
      'reverts only the failed item, preserving a concurrent success',
      () async {
        when(
          () => mockPantryRepository.list(),
        ).thenAnswer((_) async => const Right([avenaItem, zanahoriaItem]));
        when(
          () => mockIngredientRepository.list(),
        ).thenAnswer((_) async => const Right([avena, zanahoria]));

        final avenaCompleter = Completer<Either<Failure, void>>();
        final zanahoriaCompleter = Completer<Either<Failure, void>>();
        when(() => mockPantryRepository.save(any())).thenAnswer((invocation) {
          final item = invocation.positionalArguments.first as PantryItem;
          return item.ingredientId == 'ing-avena'
              ? avenaCompleter.future
              : zanahoriaCompleter.future;
        });

        final container = makeContainer();
        await container.read(pantryControllerProvider.future);
        final notifier = container.read(pantryControllerProvider.notifier);

        final avenaFuture = notifier.adjustStock('ing-avena', 1);
        final zanahoriaFuture = notifier.adjustStock('ing-zanahoria', 1);

        zanahoriaCompleter.complete(const Right(null));
        final zanahoriaResult = await zanahoriaFuture;
        expect(zanahoriaResult, isNull);

        avenaCompleter.complete(Left(failure));
        final avenaResult = await avenaFuture;
        expect(avenaResult, failure);

        final rows = container.read(pantryControllerProvider).value!;
        final avenaRow = rows.firstWhere(
          (row) => row.item.ingredientId == 'ing-avena',
        );
        final zanahoriaRow = rows.firstWhere(
          (row) => row.item.ingredientId == 'ing-zanahoria',
        );
        expect(
          (avenaRow.item as QuantityTrackedPantryItem).stock.value,
          2,
          reason: 'the failed edit must roll back to its pre-edit stock',
        );
        expect(
          (zanahoriaRow.item as QuantityTrackedPantryItem).stock.value,
          6,
          reason: 'the concurrent successful edit must not be clobbered',
        );
      },
    );

    test(
      'stays at 0 and does not call save when decrementing below zero',
      () async {
        const zeroStockItem = PantryItem.quantityTracked(
          ingredientId: 'ing-avena',
          category: Category.cereal,
          stock: Quantity(value: 0, unit: Unit.gram),
        );
        when(
          () => mockPantryRepository.list(),
        ).thenAnswer((_) async => const Right([zeroStockItem]));
        when(
          () => mockIngredientRepository.list(),
        ).thenAnswer((_) async => const Right([avena]));

        final container = makeContainer();
        await container.read(pantryControllerProvider.future);
        final notifier = container.read(pantryControllerProvider.notifier);

        final result = await notifier.adjustStock('ing-avena', -1);

        expect(result, isNull);
        final row = container.read(pantryControllerProvider).value!.single;
        expect((row.item as QuantityTrackedPantryItem).stock.value, 0);
        verifyNever(() => mockPantryRepository.save(any()));
      },
    );

    test(
      'accepts a fractional num delta (counter quarter-pound step)',
      () async {
        const counterItem = PantryItem.quantityTracked(
          ingredientId: 'ing-avena',
          category: Category.cereal,
          stock: Quantity(value: 793.7, unit: Unit.gram),
        );
        when(
          () => mockPantryRepository.list(),
        ).thenAnswer((_) async => const Right([counterItem]));
        when(
          () => mockIngredientRepository.list(),
        ).thenAnswer((_) async => const Right([avena]));
        when(
          () => mockPantryRepository.save(any()),
        ).thenAnswer((_) async => const Right(null));

        final container = makeContainer();
        await container.read(pantryControllerProvider.future);
        final notifier = container.read(pantryControllerProvider.notifier);

        final result = await notifier.adjustStock('ing-avena', 113.398);

        expect(result, isNull);
        final row = container.read(pantryControllerProvider).value!.single;
        expect(
          (row.item as QuantityTrackedPantryItem).stock.value,
          closeTo(907.098, 0.001),
        );
        final captured = verify(
          () => mockPantryRepository.save(captureAny()),
        ).captured;
        final savedItem = captured.single as QuantityTrackedPantryItem;
        expect(savedItem.stock.value, closeTo(907.098, 0.001));
      },
    );
  });

  group('setStock', () {
    test(
      'optimistically sets stock to an absolute value then persists',
      () async {
        when(
          () => mockPantryRepository.list(),
        ).thenAnswer((_) async => const Right([avenaItem]));
        when(
          () => mockIngredientRepository.list(),
        ).thenAnswer((_) async => const Right([avena]));
        when(
          () => mockPantryRepository.save(any()),
        ).thenAnswer((_) async => const Right(null));

        final container = makeContainer();
        await container.read(pantryControllerProvider.future);
        final notifier = container.read(pantryControllerProvider.notifier);

        final resultFuture = notifier.setStock('ing-avena', 908);

        // Optimistic patch is applied synchronously, before save() resolves.
        final optimisticRow = container
            .read(pantryControllerProvider)
            .value!
            .single;
        final optimisticItem = optimisticRow.item as QuantityTrackedPantryItem;
        expect(optimisticItem.stock.value, 908);

        final result = await resultFuture;

        expect(result, isNull);
        final captured = verify(
          () => mockPantryRepository.save(captureAny()),
        ).captured;
        final savedItem = captured.single as QuantityTrackedPantryItem;
        expect(savedItem.stock.value, 908);
      },
    );

    test(
      'reverts only the failed item, preserving a concurrent success',
      () async {
        when(
          () => mockPantryRepository.list(),
        ).thenAnswer((_) async => const Right([avenaItem, zanahoriaItem]));
        when(
          () => mockIngredientRepository.list(),
        ).thenAnswer((_) async => const Right([avena, zanahoria]));

        final avenaCompleter = Completer<Either<Failure, void>>();
        final zanahoriaCompleter = Completer<Either<Failure, void>>();
        when(() => mockPantryRepository.save(any())).thenAnswer((invocation) {
          final item = invocation.positionalArguments.first as PantryItem;
          return item.ingredientId == 'ing-avena'
              ? avenaCompleter.future
              : zanahoriaCompleter.future;
        });

        final container = makeContainer();
        await container.read(pantryControllerProvider.future);
        final notifier = container.read(pantryControllerProvider.notifier);

        final avenaFuture = notifier.setStock('ing-avena', 908);
        final zanahoriaFuture = notifier.setStock('ing-zanahoria', 10);

        zanahoriaCompleter.complete(const Right(null));
        final zanahoriaResult = await zanahoriaFuture;
        expect(zanahoriaResult, isNull);

        avenaCompleter.complete(Left(failure));
        final avenaResult = await avenaFuture;
        expect(avenaResult, failure);

        final rows = container.read(pantryControllerProvider).value!;
        final avenaRow = rows.firstWhere(
          (row) => row.item.ingredientId == 'ing-avena',
        );
        final zanahoriaRow = rows.firstWhere(
          (row) => row.item.ingredientId == 'ing-zanahoria',
        );
        expect(
          (avenaRow.item as QuantityTrackedPantryItem).stock.value,
          2,
          reason: 'the failed edit must roll back to its pre-edit stock',
        );
        expect(
          (zanahoriaRow.item as QuantityTrackedPantryItem).stock.value,
          10,
          reason: 'the concurrent successful edit must not be clobbered',
        );
      },
    );

    test('no-op when the item is not quantity-tracked', () async {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([cominoItem]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([comino]));

      final container = makeContainer();
      await container.read(pantryControllerProvider.future);
      final notifier = container.read(pantryControllerProvider.notifier);

      final result = await notifier.setStock('ing-comino', 5);

      expect(result, isNull);
      verifyNever(() => mockPantryRepository.save(any()));
    });

    test('no-op when newValue equals the current stock value', () async {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([avenaItem]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([avena]));

      final container = makeContainer();
      await container.read(pantryControllerProvider.future);
      final notifier = container.read(pantryControllerProvider.notifier);

      final result = await notifier.setStock('ing-avena', 2);

      expect(result, isNull);
      verifyNever(() => mockPantryRepository.save(any()));
    });

    test('rejects a negative newValue and does not call save', () async {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([avenaItem]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([avena]));

      final container = makeContainer();
      await container.read(pantryControllerProvider.future);
      final notifier = container.read(pantryControllerProvider.notifier);

      final result = await notifier.setStock('ing-avena', -1);

      expect(result, isNull);
      final row = container.read(pantryControllerProvider).value!.single;
      expect((row.item as QuantityTrackedPantryItem).stock.value, 2);
      verifyNever(() => mockPantryRepository.save(any()));
    });
  });

  group('toggleHave', () {
    test('optimistically flips haveIt then persists via save', () async {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([cominoItem]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([comino]));
      when(
        () => mockPantryRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      final container = makeContainer();
      await container.read(pantryControllerProvider.future);
      final notifier = container.read(pantryControllerProvider.notifier);

      final resultFuture = notifier.toggleHave('ing-comino');

      final optimisticRow = container
          .read(pantryControllerProvider)
          .value!
          .single;
      expect((optimisticRow.item as BooleanTrackedPantryItem).haveIt, isTrue);

      final result = await resultFuture;

      expect(result, isNull);
      final captured = verify(
        () => mockPantryRepository.save(captureAny()),
      ).captured;
      final savedItem = captured.single as BooleanTrackedPantryItem;
      expect(savedItem.haveIt, isTrue);
    });

    test('reverts haveIt on Left(Failure)', () async {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([cominoItem]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([comino]));
      when(
        () => mockPantryRepository.save(any()),
      ).thenAnswer((_) async => Left(failure));

      final container = makeContainer();
      await container.read(pantryControllerProvider.future);
      final notifier = container.read(pantryControllerProvider.notifier);

      final result = await notifier.toggleHave('ing-comino');

      expect(result, failure);
      final row = container.read(pantryControllerProvider).value!.single;
      expect((row.item as BooleanTrackedPantryItem).haveIt, isFalse);
    });
  });

  group('upsertRow', () {
    test('replaces an existing row in place, keeping its position', () async {
      when(() => mockPantryRepository.list()).thenAnswer(
        (_) async => const Right([avenaItem, cominoItem, zanahoriaItem]),
      );
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([avena, comino, zanahoria]));

      final container = makeContainer();
      await container.read(pantryControllerProvider.future);

      const renamedComino = Ingredient(
        id: 'ing-comino',
        name: 'Comino molido',
        emoji: '🌿',
        category: Category.condimento,
      );
      const updatedItem = PantryItem.booleanTracked(
        ingredientId: 'ing-comino',
        category: Category.condimento,
        haveIt: true,
      );

      container
          .read(pantryControllerProvider.notifier)
          .upsertRow(ingredient: renamedComino, item: updatedItem);

      final rows = container.read(pantryControllerProvider).value!;
      expect(rows, hasLength(3));
      expect(rows[0].item, avenaItem);
      expect(rows[1].item, updatedItem);
      expect(rows[1].ingredient, renamedComino);
      expect(rows[2].item, zanahoriaItem);
    });

    test('appends a newly created ingredient at the end', () async {
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) async => const Right([avenaItem]));
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([avena]));

      final container = makeContainer();
      await container.read(pantryControllerProvider.future);

      container
          .read(pantryControllerProvider.notifier)
          .upsertRow(ingredient: zanahoria, item: zanahoriaItem);

      final rows = container.read(pantryControllerProvider).value!;
      expect(rows, hasLength(2));
      expect(rows[0].item, avenaItem);
      expect(rows[1].item, zanahoriaItem);
      expect(rows[1].ingredient, zanahoria);
    });

    test('no-ops while the pantry has never loaded', () async {
      final listCompleter = Completer<Either<Failure, List<PantryItem>>>();
      when(
        () => mockPantryRepository.list(),
      ).thenAnswer((_) => listCompleter.future);
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([avena]));

      final container = makeContainer();
      unawaited(container.read(pantryControllerProvider.future));

      container
          .read(pantryControllerProvider.notifier)
          .upsertRow(ingredient: zanahoria, item: zanahoriaItem);

      expect(container.read(pantryControllerProvider).value, isNull);

      listCompleter.complete(const Right([avenaItem]));
      final rows = await container.read(pantryControllerProvider.future);
      expect(rows.map((row) => row.item), [avenaItem]);
    });
  });
}
