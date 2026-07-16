import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/features/today/data/repositories/cook_schedule_repository_impl.dart';
import 'package:menuario/src/features/today/domain/entities/cook_schedule.dart';
import 'package:menuario/src/features/today/domain/repositories/cook_schedule_repository.dart';
import 'package:menuario/src/features/today/domain/value_objects/cook_target.dart';
import 'package:menuario/src/features/today/presentation/providers/cook_schedule_provider.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockCookScheduleRepository extends Mock
    implements CookScheduleRepository {}

void main() {
  late MockCookScheduleRepository mockCookScheduleRepository;

  const savedSchedule = CookSchedule(
    byWeekday: {
      DateTime.friday: [
        (targetDay: DayOfWeek.vie, slot: MealSlot.cena, group: CookGroup.hoy),
      ],
    },
  );
  final failure = Failure(message: 'no se pudo guardar', code: 'save-fail');

  setUpAll(() {
    registerFallbackValue(CookSchedule.seed);
  });

  setUp(() {
    mockCookScheduleRepository = MockCookScheduleRepository();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        cookScheduleRepositoryProvider.overrideWithValue(
          mockCookScheduleRepository,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('build', () {
    test('falls back to the seed schedule when no doc exists', () async {
      when(
        () => mockCookScheduleRepository.getActive(),
      ).thenAnswer((_) async => const Right(null));

      final container = makeContainer();

      final schedule = await container.read(cookScheduleProvider.future);

      expect(schedule, CookSchedule.seed);
    });

    test('loads the saved schedule when a doc exists', () async {
      when(
        () => mockCookScheduleRepository.getActive(),
      ).thenAnswer((_) async => const Right(savedSchedule));

      final container = makeContainer();

      final schedule = await container.read(cookScheduleProvider.future);

      expect(schedule, savedSchedule);
    });

    test('throws a FailureException when the repository fails', () async {
      when(
        () => mockCookScheduleRepository.getActive(),
      ).thenAnswer((_) async => Left(failure));

      final container = makeContainer();

      await expectLater(
        container.read(cookScheduleProvider.future),
        throwsA(isA<FailureException>()),
      );
    });
  });

  group('save', () {
    test('applies optimistically and persists on success', () async {
      when(
        () => mockCookScheduleRepository.getActive(),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => mockCookScheduleRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      final container = makeContainer();
      await container.read(cookScheduleProvider.future);
      final notifier = container.read(cookScheduleProvider.notifier);

      final result = await notifier.save(savedSchedule);

      expect(result, isNull);
      expect(container.read(cookScheduleProvider).value, savedSchedule);
      verify(() => mockCookScheduleRepository.save(savedSchedule)).called(1);
    });

    test('reverts to the pre-edit snapshot and returns the Failure on save '
        'failure', () async {
      when(
        () => mockCookScheduleRepository.getActive(),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => mockCookScheduleRepository.save(any()),
      ).thenAnswer((_) async => Left(failure));

      final container = makeContainer();
      await container.read(cookScheduleProvider.future);
      final notifier = container.read(cookScheduleProvider.notifier);

      final result = await notifier.save(savedSchedule);

      expect(result, failure);
      expect(container.read(cookScheduleProvider).value, CookSchedule.seed);
    });

    test('applies to state before save() resolves (optimistic)', () async {
      when(
        () => mockCookScheduleRepository.getActive(),
      ).thenAnswer((_) async => const Right(null));
      final saveCompleter = Completer<Either<Failure, void>>();
      when(
        () => mockCookScheduleRepository.save(any()),
      ).thenAnswer((_) => saveCompleter.future);

      final container = makeContainer();
      await container.read(cookScheduleProvider.future);
      final notifier = container.read(cookScheduleProvider.notifier);

      final resultFuture = notifier.save(savedSchedule);

      expect(container.read(cookScheduleProvider).value, savedSchedule);

      saveCompleter.complete(const Right(null));
      await resultFuture;
    });
  });

  group('reset', () {
    test('persists the seed schedule', () async {
      when(
        () => mockCookScheduleRepository.getActive(),
      ).thenAnswer((_) async => const Right(savedSchedule));
      when(
        () => mockCookScheduleRepository.save(any()),
      ).thenAnswer((_) async => const Right(null));

      final container = makeContainer();
      await container.read(cookScheduleProvider.future);
      final notifier = container.read(cookScheduleProvider.notifier);

      final result = await notifier.reset();

      expect(result, isNull);
      expect(container.read(cookScheduleProvider).value, CookSchedule.seed);
      verify(
        () => mockCookScheduleRepository.save(CookSchedule.seed),
      ).called(1);
    });
  });
}
