import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/today/data/datasources/cook_schedule_data_source.dart';
import 'package:menuario/src/features/today/data/models/cook_schedule_dto.dart';
import 'package:menuario/src/features/today/domain/entities/cook_schedule.dart';
import 'package:menuario/src/features/today/domain/repositories/cook_schedule_repository.dart';

/// [CookScheduleRepository] port implementation backed by
/// [CookScheduleDataSource].
///
/// [save] always overwrites the single active schedule document — no
/// history — delegating the actual overwrite mechanics to the datasource.
class CookScheduleRepositoryImpl implements CookScheduleRepository {
  final CookScheduleDataSource _dataSource;

  CookScheduleRepositoryImpl({required CookScheduleDataSource dataSource})
    : _dataSource = dataSource; // ignore: prefer_initializing_formals

  @override
  Future<Either<Failure, CookSchedule?>> getActive() async {
    final result = await _dataSource.getActive();
    try {
      return result.map((dto) => dto?.toEntity());
    } on Object catch (exception, stackTrace) {
      return Left(Failure.malformedData(exception, stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> save(CookSchedule schedule) {
    return _dataSource.save(CookScheduleDTO.fromEntity(schedule));
  }
}

/// The [CookScheduleRepository] port, satisfied by
/// [CookScheduleRepositoryImpl].
final cookScheduleRepositoryProvider = Provider<CookScheduleRepository>(
  (ref) => CookScheduleRepositoryImpl(
    dataSource: ref.watch(cookScheduleDataSourceProvider),
  ),
  dependencies: [cookScheduleDataSourceProvider],
);
