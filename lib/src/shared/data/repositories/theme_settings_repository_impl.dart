import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/data/datasources/theme_settings_data_source.dart';
import 'package:menuario/src/shared/data/models/theme_settings_dto.dart';
import 'package:menuario/src/shared/domain/entities/theme_settings.dart';
import 'package:menuario/src/shared/domain/repositories/theme_settings_repository.dart';

/// [ThemeSettingsRepository] port implementation backed by
/// [ThemeSettingsDataSource].
class ThemeSettingsRepositoryImpl implements ThemeSettingsRepository {
  final ThemeSettingsDataSource _dataSource;

  ThemeSettingsRepositoryImpl({required ThemeSettingsDataSource dataSource})
    : _dataSource = dataSource; // ignore: prefer_initializing_formals

  @override
  Future<Either<Failure, ThemeSettings?>> getActive() async {
    final result = await _dataSource.getActive();
    return result.map((dto) => dto?.toEntity());
  }

  @override
  Future<Either<Failure, void>> save(ThemeSettings settings) {
    return _dataSource.save(ThemeSettingsDTO.fromEntity(settings));
  }
}

/// The [ThemeSettingsRepository] port, satisfied by
/// [ThemeSettingsRepositoryImpl].
final themeSettingsRepositoryProvider = Provider<ThemeSettingsRepository>(
  (ref) => ThemeSettingsRepositoryImpl(
    dataSource: ref.watch(themeSettingsDataSourceProvider),
  ),
  dependencies: [themeSettingsDataSourceProvider],
);
