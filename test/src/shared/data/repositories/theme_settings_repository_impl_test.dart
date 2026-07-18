import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/theme/app_seed.dart';
import 'package:menuario/src/shared/data/datasources/theme_settings_data_source.dart';
import 'package:menuario/src/shared/data/models/theme_settings_dto.dart';
import 'package:menuario/src/shared/data/repositories/theme_settings_repository_impl.dart';
import 'package:menuario/src/shared/domain/entities/theme_settings.dart';
import 'package:mocktail/mocktail.dart';

class MockThemeSettingsDataSource extends Mock
    implements ThemeSettingsDataSource {}

void main() {
  late MockThemeSettingsDataSource mockDataSource;
  late ThemeSettingsRepositoryImpl repository;

  final emerald = menuarioSeedOptions[1].color;
  final failure = Failure(message: 'boom', code: 'firestore');

  setUpAll(() {
    registerFallbackValue(const ThemeSettingsDTO());
  });

  setUp(() {
    mockDataSource = MockThemeSettingsDataSource();
    repository = ThemeSettingsRepositoryImpl(dataSource: mockDataSource);
  });

  group('getActive', () {
    test('maps the stored DTO to its entity', () async {
      when(() => mockDataSource.getActive()).thenAnswer(
        (_) async =>
            Right(ThemeSettingsDTO(mode: 'light', seed: emerald.toARGB32())),
      );

      final result = await repository.getActive();

      result.fold(
        (failure) => fail('expected Right, got Left($failure)'),
        (settings) => expect(
          settings,
          ThemeSettings(mode: ThemeMode.light, seed: emerald),
        ),
      );
    });

    test('returns Right(null) when no settings have been saved', () async {
      when(
        () => mockDataSource.getActive(),
      ).thenAnswer((_) async => const Right(null));

      final result = await repository.getActive();

      expect(result, const Right<Failure, ThemeSettings?>(null));
    });

    test('propagates a datasource Failure untouched', () async {
      when(
        () => mockDataSource.getActive(),
      ).thenAnswer((_) async => Left(failure));

      final result = await repository.getActive();

      result.fold(
        (actual) => expect(actual, failure),
        (_) => fail('expected Left, got Right'),
      );
    });
  });

  group('save', () {
    test('maps the entity to its DTO before delegating', () async {
      when(
        () => mockDataSource.save(any()),
      ).thenAnswer((_) async => const Right(null));

      await repository.save(
        ThemeSettings(mode: ThemeMode.system, seed: emerald),
      );

      verify(
        () => mockDataSource.save(
          ThemeSettingsDTO(mode: 'system', seed: emerald.toARGB32()),
        ),
      ).called(1);
    });

    test('propagates a datasource Failure untouched', () async {
      when(
        () => mockDataSource.save(any()),
      ).thenAnswer((_) async => Left(failure));

      final result = await repository.save(ThemeSettings.defaults);

      result.fold(
        (actual) => expect(actual, failure),
        (_) => fail('expected Left, got Right'),
      );
    });
  });
}
