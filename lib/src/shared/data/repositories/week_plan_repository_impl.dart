import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/data/datasources/week_plan_data_source.dart';
import 'package:menuario/src/shared/data/models/week_plan_dto.dart';
import 'package:menuario/src/shared/domain/entities/week_plan.dart';
import 'package:menuario/src/shared/domain/repositories/week_plan_repository.dart';

/// [WeekPlanRepository] port implementation backed by [WeekPlanDataSource].
///
/// [save] always overwrites the single active plan document — no history —
/// delegating the actual overwrite mechanics to the datasource.
class WeekPlanRepositoryImpl implements WeekPlanRepository {
  final WeekPlanDataSource _dataSource;

  WeekPlanRepositoryImpl({required WeekPlanDataSource dataSource})
    : _dataSource = dataSource; // ignore: prefer_initializing_formals

  @override
  Future<Either<Failure, WeekPlan?>> getActive() async {
    final result = await _dataSource.getActive();
    return result.map((dto) => dto?.toEntity());
  }

  @override
  Future<Either<Failure, void>> save(WeekPlan weekPlan) {
    return _dataSource.save(WeekPlanDTO.fromEntity(weekPlan));
  }
}

/// The [WeekPlanRepository] port, satisfied by [WeekPlanRepositoryImpl].
final weekPlanRepositoryProvider = Provider<WeekPlanRepository>(
  (ref) => WeekPlanRepositoryImpl(
    dataSource: ref.watch(weekPlanDataSourceProvider),
  ),
  dependencies: [weekPlanDataSourceProvider],
);
