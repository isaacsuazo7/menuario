import 'package:dartz/dartz.dart' hide Unit;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/data/datasources/week_plan_data_source.dart';
import 'package:menuario/src/shared/data/repositories/week_plan_repository_impl.dart';
import 'package:menuario/src/shared/domain/entities/plan_entry.dart';
import 'package:menuario/src/shared/domain/entities/week_plan.dart';
import 'package:menuario/src/shared/domain/value_objects/day_of_week.dart';
import 'package:menuario/src/shared/domain/value_objects/meal_slot.dart';

void main() {
  group('WeekPlanRepositoryImpl', () {
    late FakeFirebaseFirestore firestore;
    late WeekPlanDataSource dataSource;
    late WeekPlanRepositoryImpl repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      dataSource = WeekPlanDataSourceImpl(firestore: firestore, uid: 'uid-A');
      repository = WeekPlanRepositoryImpl(dataSource: dataSource);
    });

    test(
      'getActive returns Right(null) when no plan has been saved yet',
      () async {
        // Act
        final result = await repository.getActive();

        // Assert
        expect(result, const Right<Failure, WeekPlan?>(null));
      },
    );

    test('save then getActive round-trips the saved WeekPlan', () async {
      // Arrange
      const plan = WeekPlan(
        entries: [
          PlanEntry(
            day: DayOfWeek.lun,
            mealSlot: MealSlot.desayuno,
            recipeId: 'recipe-1',
            cooked: false,
          ),
        ],
      );

      // Act
      final saveResult = await repository.save(plan);
      final getResult = await repository.getActive();

      // Assert
      expect(saveResult, const Right<Failure, void>(null));
      getResult.fold(
        (failure) => fail('expected Right, got Left($failure)'),
        (readPlan) => expect(readPlan, plan),
      );
    });

    test(
      'save overwrites the previously active plan: getActive returns only '
      'the latest, no history',
      () async {
        // Arrange
        const firstPlan = WeekPlan(entries: []);
        const secondPlan = WeekPlan(
          entries: [
            PlanEntry(
              day: DayOfWeek.mar,
              mealSlot: MealSlot.cena,
              recipeId: 'recipe-2',
              cooked: true,
            ),
          ],
        );

        // Act
        await repository.save(firstPlan);
        await repository.save(secondPlan);
        final result = await repository.getActive();

        // Assert
        result.fold(
          (failure) => fail('expected Right, got Left($failure)'),
          (readPlan) => expect(readPlan, secondPlan),
        );
      },
    );
  });
}
