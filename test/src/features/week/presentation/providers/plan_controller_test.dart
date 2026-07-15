import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockWeekPlanRepository extends Mock implements WeekPlanRepository {}

void main() {
  late MockWeekPlanRepository mockWeekPlanRepository;

  const lunCena = PlanEntry(
    day: DayOfWeek.lun,
    mealSlot: MealSlot.cena,
    recipeId: 'r-lun-cena',
    cooked: false,
  );
  const jueCenaCooked = PlanEntry(
    day: DayOfWeek.jue,
    mealSlot: MealSlot.cena,
    recipeId: 'r-jue-cena',
    cooked: true,
  );
  const marAlmuerzo = PlanEntry(
    day: DayOfWeek.mar,
    mealSlot: MealSlot.almuerzo,
    recipeId: 'r-mar-almuerzo-a',
    cooked: false,
  );

  final failure = Failure(message: 'no se pudo guardar', code: 'save-fail');

  setUpAll(() {
    registerFallbackValue(const WeekPlan(entries: []));
  });

  setUp(() {
    mockWeekPlanRepository = MockWeekPlanRepository();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        weekPlanRepositoryProvider.overrideWithValue(mockWeekPlanRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('build', () {
    test('loads the active WeekPlan', () async {
      when(
        () => mockWeekPlanRepository.getActive(),
      ).thenAnswer((_) async => const Right(WeekPlan(entries: [lunCena])));

      final container = makeContainer();

      final plan = await container.read(planControllerProvider.future);

      expect(plan.entries, [lunCena]);
    });

    test('returns an empty WeekPlan when no plan doc exists yet', () async {
      when(
        () => mockWeekPlanRepository.getActive(),
      ).thenAnswer((_) async => const Right(null));

      final container = makeContainer();

      final plan = await container.read(planControllerProvider.future);

      expect(plan.entries, isEmpty);
    });

    test('throws a FailureException when the repository fails', () async {
      when(
        () => mockWeekPlanRepository.getActive(),
      ).thenAnswer((_) async => Left(failure));

      final container = makeContainer();

      await expectLater(
        container.read(planControllerProvider.future),
        throwsA(isA<FailureException>()),
      );
    });
  });

  group('assign', () {
    test('creates a new PlanEntry on an empty slot', () async {
      when(
        () => mockWeekPlanRepository.getActive(),
      ).thenAnswer((_) async => const Right(WeekPlan(entries: [])));
      when(
        () => mockWeekPlanRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      final container = makeContainer();
      await container.read(planControllerProvider.future);
      final notifier = container.read(planControllerProvider.notifier);

      final result = await notifier.assign(
        day: DayOfWeek.lun,
        mealSlot: MealSlot.cena,
        recipeId: 'r-lun-cena',
      );

      expect(result, isNull);
      final entries = container.read(planControllerProvider).value!.entries;
      expect(entries, hasLength(1));
      expect(entries.single.day, DayOfWeek.lun);
      expect(entries.single.mealSlot, MealSlot.cena);
      expect(entries.single.recipeId, 'r-lun-cena');
    });

    test(
      'replaces the existing PlanEntry on an occupied slot, not duplicates',
      () async {
        when(() => mockWeekPlanRepository.getActive()).thenAnswer(
          (_) async => const Right(WeekPlan(entries: [marAlmuerzo])),
        );
        when(
          () => mockWeekPlanRepository.save(any()),
        ).thenAnswer((_) async => const Right(null));

        final container = makeContainer();
        await container.read(planControllerProvider.future);
        final notifier = container.read(planControllerProvider.notifier);

        final result = await notifier.assign(
          day: DayOfWeek.mar,
          mealSlot: MealSlot.almuerzo,
          recipeId: 'r-mar-almuerzo-b',
        );

        expect(result, isNull);
        final entries = container.read(planControllerProvider).value!.entries;
        final marAlmuerzoEntries = entries.where(
          (entry) =>
              entry.day == DayOfWeek.mar && entry.mealSlot == MealSlot.almuerzo,
        );
        expect(marAlmuerzoEntries, hasLength(1));
        expect(marAlmuerzoEntries.single.recipeId, 'r-mar-almuerzo-b');
      },
    );

    test('preserves the replaced slot\'s own cooked flag', () async {
      when(() => mockWeekPlanRepository.getActive()).thenAnswer(
        (_) async => const Right(WeekPlan(entries: [jueCenaCooked])),
      );
      when(
        () => mockWeekPlanRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      final container = makeContainer();
      await container.read(planControllerProvider.future);
      final notifier = container.read(planControllerProvider.notifier);

      await notifier.assign(
        day: DayOfWeek.jue,
        mealSlot: MealSlot.cena,
        recipeId: 'r-jue-cena-new',
      );

      final entries = container.read(planControllerProvider).value!.entries;
      expect(entries.single.recipeId, 'r-jue-cena-new');
      expect(entries.single.cooked, isTrue);
    });

    test('preserves other entries and their cooked flags untouched', () async {
      when(() => mockWeekPlanRepository.getActive()).thenAnswer(
        (_) async =>
            const Right(WeekPlan(entries: [jueCenaCooked, marAlmuerzo])),
      );
      when(
        () => mockWeekPlanRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      final container = makeContainer();
      await container.read(planControllerProvider.future);
      final notifier = container.read(planControllerProvider.notifier);

      await notifier.assign(
        day: DayOfWeek.lun,
        mealSlot: MealSlot.cena,
        recipeId: 'r-lun-cena',
      );

      final entries = container.read(planControllerProvider).value!.entries;
      expect(entries, containsAll([jueCenaCooked, marAlmuerzo]));
    });

    test('a new entry defaults cooked to false', () async {
      when(
        () => mockWeekPlanRepository.getActive(),
      ).thenAnswer((_) async => const Right(WeekPlan(entries: [])));
      when(
        () => mockWeekPlanRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      final container = makeContainer();
      await container.read(planControllerProvider.future);
      final notifier = container.read(planControllerProvider.notifier);

      await notifier.assign(
        day: DayOfWeek.lun,
        mealSlot: MealSlot.cena,
        recipeId: 'r-lun-cena',
      );

      final entries = container.read(planControllerProvider).value!.entries;
      expect(entries.single.cooked, isFalse);
    });
  });

  group('clear', () {
    test('removes the PlanEntry for the given slot', () async {
      when(
        () => mockWeekPlanRepository.getActive(),
      ).thenAnswer((_) async => const Right(WeekPlan(entries: [lunCena])));
      when(
        () => mockWeekPlanRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      final container = makeContainer();
      await container.read(planControllerProvider.future);
      final notifier = container.read(planControllerProvider.notifier);

      final result = await notifier.clear(
        day: DayOfWeek.lun,
        mealSlot: MealSlot.cena,
      );

      expect(result, isNull);
      final entries = container.read(planControllerProvider).value!.entries;
      expect(entries, isEmpty);
    });

    test('leaves other entries untouched', () async {
      when(() => mockWeekPlanRepository.getActive()).thenAnswer(
        (_) async => const Right(WeekPlan(entries: [lunCena, jueCenaCooked])),
      );
      when(
        () => mockWeekPlanRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      final container = makeContainer();
      await container.read(planControllerProvider.future);
      final notifier = container.read(planControllerProvider.notifier);

      await notifier.clear(day: DayOfWeek.lun, mealSlot: MealSlot.cena);

      final entries = container.read(planControllerProvider).value!.entries;
      expect(entries, [jueCenaCooked]);
    });

    test(
      'a no-op slot is a no-op that still saves the unchanged plan',
      () async {
        when(
          () => mockWeekPlanRepository.getActive(),
        ).thenAnswer((_) async => const Right(WeekPlan(entries: [lunCena])));
        when(
          () => mockWeekPlanRepository.save(any()),
        ).thenAnswer((_) async => const Right(null));

        final container = makeContainer();
        await container.read(planControllerProvider.future);
        final notifier = container.read(planControllerProvider.notifier);

        final result = await notifier.clear(
          day: DayOfWeek.mar,
          mealSlot: MealSlot.almuerzo,
        );

        expect(result, isNull);
        final entries = container.read(planControllerProvider).value!.entries;
        expect(entries, [lunCena]);
      },
    );
  });

  group('optimistic update', () {
    test('assign applies to state before save() resolves', () async {
      when(
        () => mockWeekPlanRepository.getActive(),
      ).thenAnswer((_) async => const Right(WeekPlan(entries: [])));
      final saveCompleter = Completer<Either<Failure, void>>();
      when(
        () => mockWeekPlanRepository.save(any()),
      ).thenAnswer((_) => saveCompleter.future);

      final container = makeContainer();
      await container.read(planControllerProvider.future);
      final notifier = container.read(planControllerProvider.notifier);

      final resultFuture = notifier.assign(
        day: DayOfWeek.lun,
        mealSlot: MealSlot.cena,
        recipeId: 'r-lun-cena',
      );

      final optimisticEntries = container
          .read(planControllerProvider)
          .value!
          .entries;
      expect(optimisticEntries, hasLength(1));

      saveCompleter.complete(const Right(null));
      await resultFuture;
    });

    test('clear applies to state before save() resolves', () async {
      when(
        () => mockWeekPlanRepository.getActive(),
      ).thenAnswer((_) async => const Right(WeekPlan(entries: [lunCena])));
      final saveCompleter = Completer<Either<Failure, void>>();
      when(
        () => mockWeekPlanRepository.save(any()),
      ).thenAnswer((_) => saveCompleter.future);

      final container = makeContainer();
      await container.read(planControllerProvider.future);
      final notifier = container.read(planControllerProvider.notifier);

      final resultFuture = notifier.clear(
        day: DayOfWeek.lun,
        mealSlot: MealSlot.cena,
      );

      final optimisticEntries = container
          .read(planControllerProvider)
          .value!
          .entries;
      expect(optimisticEntries, isEmpty);

      saveCompleter.complete(const Right(null));
      await resultFuture;
    });
  });

  group('save failure revert', () {
    test(
      'assign reverts to the pre-edit snapshot and returns the Failure',
      () async {
        when(
          () => mockWeekPlanRepository.getActive(),
        ).thenAnswer((_) async => const Right(WeekPlan(entries: [])));
        when(
          () => mockWeekPlanRepository.save(any()),
        ).thenAnswer((_) async => Left(failure));

        final container = makeContainer();
        await container.read(planControllerProvider.future);
        final notifier = container.read(planControllerProvider.notifier);

        final result = await notifier.assign(
          day: DayOfWeek.lun,
          mealSlot: MealSlot.cena,
          recipeId: 'r-lun-cena',
        );

        expect(result, failure);
        final entries = container.read(planControllerProvider).value!.entries;
        expect(entries, isEmpty);
      },
    );

    test(
      'clear reverts to the pre-edit snapshot and returns the Failure',
      () async {
        when(
          () => mockWeekPlanRepository.getActive(),
        ).thenAnswer((_) async => const Right(WeekPlan(entries: [lunCena])));
        when(
          () => mockWeekPlanRepository.save(any()),
        ).thenAnswer((_) async => Left(failure));

        final container = makeContainer();
        await container.read(planControllerProvider.future);
        final notifier = container.read(planControllerProvider.notifier);

        final result = await notifier.clear(
          day: DayOfWeek.lun,
          mealSlot: MealSlot.cena,
        );

        expect(result, failure);
        final entries = container.read(planControllerProvider).value!.entries;
        expect(entries, [lunCena]);
      },
    );
  });
}
