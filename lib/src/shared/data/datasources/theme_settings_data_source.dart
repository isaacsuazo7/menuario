import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/firebase/firebase_providers.dart';
import 'package:menuario/src/shared/data/models/theme_settings_dto.dart';

/// Firestore datasource port for the account's [ThemeSettingsDTO], stored at
/// the fixed document `users/{uid}/settings/theme`.
///
/// [save] always fully overwrites that one document — never an append.
abstract class ThemeSettingsDataSource {
  /// Reads the saved settings, or `Right(null)` when none exist yet.
  Future<Either<Failure, ThemeSettingsDTO?>> getActive();

  /// Overwrites the settings document with [dto].
  Future<Either<Failure, void>> save(ThemeSettingsDTO dto);
}

/// [ThemeSettingsDataSource] backed by a real (or fake, in tests)
/// [FirebaseFirestore] instance.
class ThemeSettingsDataSourceImpl implements ThemeSettingsDataSource {
  final FirebaseFirestore _firestore;
  final String? _uid;

  // The public constructor params are `firestore`/`uid` (per design); an
  // initializing formal would force them to be named `_firestore`/`_uid`.
  ThemeSettingsDataSourceImpl({
    required FirebaseFirestore firestore,
    String? uid,
  }) : _firestore = firestore, // ignore: prefer_initializing_formals
       _uid = uid; // ignore: prefer_initializing_formals

  DocumentReference<Map<String, dynamic>> _doc(String uid) {
    return _firestore.doc('users/$uid/settings/theme');
  }

  @override
  Future<Either<Failure, ThemeSettingsDTO?>> getActive() async {
    final uid = _uid;
    if (uid == null) {
      return Left(Failure.unauthenticated());
    }
    try {
      final snapshot = await _doc(uid).get();
      final data = snapshot.data();
      if (data == null) {
        return const Right(null);
      }
      // `ThemeSettingsDTO.fromJson` is total: unreadable fields decode to
      // `null` and resolve to defaults downstream, so a corrupt document
      // never costs the user their theme.
      return Right(ThemeSettingsDTO.fromJson(data));
    } on FirebaseException catch (exception) {
      return Left(
        Failure.firestore(code: exception.code, message: exception.message),
      );
    } on Object catch (exception, stackTrace) {
      return Left(Failure.malformedData(exception, stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> save(ThemeSettingsDTO dto) async {
    final uid = _uid;
    if (uid == null) {
      return Left(Failure.unauthenticated());
    }
    try {
      await _doc(uid).set(dto.toJson());
      return const Right(null);
    } on FirebaseException catch (exception) {
      return Left(
        Failure.firestore(code: exception.code, message: exception.message),
      );
    }
  }
}

/// The [ThemeSettingsDataSource] used app-wide, wired to
/// [firebaseFirestoreProvider] and the currently signed-in
/// [currentUidProvider].
final themeSettingsDataSourceProvider = Provider<ThemeSettingsDataSource>(
  (ref) => ThemeSettingsDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
    uid: ref.watch(currentUidProvider),
  ),
  dependencies: [firebaseFirestoreProvider, currentUidProvider],
);
