import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/entities/plan_entry.dart';
import 'package:menuario/src/shared/domain/entities/week_plan.dart';
import 'package:menuario/src/shared/domain/repositories/week_plan_repository.dart';
import 'package:menuario/src/shared/domain/value_objects/day_of_week.dart';
import 'package:menuario/src/shared/domain/value_objects/meal_slot.dart';
import 'package:mocktail/mocktail.dart';

class MockWeekPlanRepository extends Mock implements WeekPlanRepository {}

void main() {
  late MockWeekPlanRepository repository;

  const weekPlan = WeekPlan(
    entries: <PlanEntry>[
      PlanEntry(
        day: DayOfWeek.lun,
        mealSlot: MealSlot.almuerzo,
        recipeId: 'recipe-avena',
        cooked: false,
      ),
    ],
  );
  final failure = Failure(message: 'fallo al guardar', code: 'saveFailed');

  setUpAll(() {
    registerFallbackValue(weekPlan);
  });

  setUp(() {
    repository = MockWeekPlanRepository();
  });

  group('WeekPlanRepository contract', () {
    group('getActive', () {
      test('should return Right(WeekPlan) when a plan is active', () async {
        // Arrange
        when(
          () => repository.getActive(),
        ).thenAnswer((_) async => const Right(weekPlan));

        // Act
        final result = await repository.getActive();

        // Assert
        expect(result, const Right<Failure, WeekPlan?>(weekPlan));
        verify(() => repository.getActive()).called(1);
      });

      test(
        'should return Right(null) when no plan has been saved yet',
        () async {
          // Arrange
          when(
            () => repository.getActive(),
          ).thenAnswer((_) async => const Right(null));

          // Act
          final result = await repository.getActive();

          // Assert
          expect(result, const Right<Failure, WeekPlan?>(null));
        },
      );

      test('should return Left(Failure) when the read fails', () async {
        // Arrange
        when(
          () => repository.getActive(),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await repository.getActive();

        // Assert
        expect(result, Left<Failure, WeekPlan?>(failure));
      });
    });

    group('save', () {
      test('should return Right(null) and overwrite whatever plan was active '
          '(single-active-week semantics: no history is kept)', () async {
        // Arrange
        when(
          () => repository.save(weekPlan),
        ).thenAnswer((_) async => const Right(null));

        // Act
        final result = await repository.save(weekPlan);

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(() => repository.save(weekPlan)).called(1);
      });

      test('should return Left(Failure) when saving fails', () async {
        // Arrange
        when(
          () => repository.save(weekPlan),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await repository.save(weekPlan);

        // Assert
        expect(result, Left<Failure, void>(failure));
      });
    });
  });
}
