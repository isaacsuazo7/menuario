import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' hide Unit;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/data/datasources/theme_settings_data_source.dart';
import 'package:menuario/src/shared/data/models/theme_settings_dto.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  group('ThemeSettingsDataSourceImpl', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    ThemeSettingsDataSourceImpl makeDataSource({String? uid = 'uid-A'}) {
      return ThemeSettingsDataSourceImpl(firestore: firestore, uid: uid);
    }

    test('getActive returns Right(null) when nothing has been saved', () async {
      // Arrange
      final dataSource = makeDataSource();

      // Act
      final result = await dataSource.getActive();

      // Assert
      expect(result, const Right<Failure, ThemeSettingsDTO?>(null));
    });

    test('save then getActive round-trips the saved DTO', () async {
      // Arrange
      final dataSource = makeDataSource();
      const dto = ThemeSettingsDTO(mode: 'light', seed: 0xFF059669);

      // Act
      final saveResult = await dataSource.save(dto);
      final getResult = await dataSource.getActive();

      // Assert
      expect(saveResult, const Right<Failure, void>(null));
      getResult.fold(
        (failure) => fail('expected Right, got Left($failure)'),
        (readDto) => expect(readDto, dto),
      );
    });

    test('save writes to the users/{uid}/settings/theme document', () async {
      // Arrange
      final dataSource = makeDataSource();

      // Act
      await dataSource.save(
        const ThemeSettingsDTO(mode: 'dark', seed: 0xFF4F46E5),
      );
      final snapshot = await firestore.doc('users/uid-A/settings/theme').get();

      // Assert
      expect(snapshot.exists, isTrue);
      expect(snapshot.data(), {'mode': 'dark', 'seed': 0xFF4F46E5});
    });

    test('saving twice overwrites: single doc, no history', () async {
      // Arrange
      final dataSource = makeDataSource();
      const first = ThemeSettingsDTO(mode: 'dark', seed: 0xFF4F46E5);
      const second = ThemeSettingsDTO(mode: 'system', seed: 0xFF059669);

      // Act
      await dataSource.save(first);
      await dataSource.save(second);
      final result = await dataSource.getActive();
      final collection = await firestore
          .collection('users/uid-A/settings')
          .get();

      // Assert
      result.fold(
        (failure) => fail('expected Right, got Left($failure)'),
        (readDto) => expect(readDto, second),
      );
      expect(collection.docs, hasLength(1));
    });

    test('settings written under uid A are not visible to uid B', () async {
      // Arrange
      final dataSourceA = makeDataSource(uid: 'uid-A');
      final dataSourceB = makeDataSource(uid: 'uid-B');
      await dataSourceA.save(
        const ThemeSettingsDTO(mode: 'light', seed: 0xFF059669),
      );

      // Act
      final resultB = await dataSourceB.getActive();

      // Assert
      expect(resultB, const Right<Failure, ThemeSettingsDTO?>(null));
    });

    test(
      'getActive returns Left(Failure.unauthenticated) with no uid',
      () async {
        // Arrange
        final dataSource = makeDataSource(uid: null);

        // Act
        final result = await dataSource.getActive();

        // Assert
        result.fold(
          (failure) => expect(failure.code, 'unauthenticated'),
          (_) => fail('expected Left, got Right'),
        );
      },
    );

    test('save returns Left(Failure.unauthenticated) with no uid', () async {
      // Arrange
      final dataSource = makeDataSource(uid: null);

      // Act
      final result = await dataSource.save(
        const ThemeSettingsDTO(mode: 'dark', seed: 0xFF4F46E5),
      );

      // Assert
      result.fold(
        (failure) => expect(failure.code, 'unauthenticated'),
        (_) => fail('expected Left, got Right'),
      );
    });

    test('save returns Left(Failure) on a FirebaseException', () async {
      // Arrange
      final dataSource = makeDataSource();
      final doc = firestore.doc('users/uid-A/settings/theme');
      whenCalling(Invocation.method(#set, null))
          .on(doc)
          .thenThrow(
            FirebaseException(plugin: 'firestore', code: 'unavailable'),
          );

      // Act
      final result = await dataSource.save(
        const ThemeSettingsDTO(mode: 'dark', seed: 0xFF4F46E5),
      );

      // Assert
      result.fold(
        (failure) => expect(failure.code, 'unavailable'),
        (_) => fail('expected Left, got Right'),
      );
    });

    test('getActive returns Left(Failure) on a FirebaseException', () async {
      // Arrange
      final dataSource = makeDataSource();
      final doc = firestore.doc('users/uid-A/settings/theme');
      whenCalling(Invocation.method(#get, null))
          .on(doc)
          .thenThrow(
            FirebaseException(plugin: 'firestore', code: 'permission-denied'),
          );

      // Act
      final result = await dataSource.getActive();

      // Assert
      result.fold(
        (failure) => expect(failure.code, 'permission-denied'),
        (_) => fail('expected Left, got Right'),
      );
    });

    test(
      'getActive decodes a corrupt document instead of failing on it',
      () async {
        // Arrange — the DTO absorbs junk so the user never loses their theme
        // to a hand-edited document.
        final dataSource = makeDataSource();
        await firestore.doc('users/uid-A/settings/theme').set({
          'mode': 99,
          'seed': 'not-an-int',
        });

        // Act
        final result = await dataSource.getActive();

        // Assert
        result.fold(
          (failure) => fail('expected Right, got Left($failure)'),
          (dto) => expect(dto, const ThemeSettingsDTO()),
        );
      },
    );
  });
}
