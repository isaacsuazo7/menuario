import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/firebase/firebase_providers.dart';
import 'package:menuario/src/shared/data/models/week_plan_dto.dart';

/// Firestore datasource port for the single active [WeekPlanDTO], stored at
/// the fixed document `users/{uid}/weekPlan/current`.
///
/// Single-active-week semantics live here: [save] always fully overwrites
/// whatever is stored at that one document — never an append.
abstract class WeekPlanDataSource {
  /// Reads the active plan, or `Right(null)` when none has been saved yet.
  Future<Either<Failure, WeekPlanDTO?>> getActive();

  /// Overwrites the active plan document with [dto].
  Future<Either<Failure, void>> save(WeekPlanDTO dto);
}

/// [WeekPlanDataSource] backed by a real (or fake, in tests)
/// [FirebaseFirestore] instance.
class WeekPlanDataSourceImpl implements WeekPlanDataSource {
  final FirebaseFirestore _firestore;
  final String? _uid;

  // The public constructor params are `firestore`/`uid` (per design); an
  // initializing formal would force them to be named `_firestore`/`_uid`.
  WeekPlanDataSourceImpl({required FirebaseFirestore firestore, String? uid})
    : _firestore = firestore, // ignore: prefer_initializing_formals
      _uid = uid; // ignore: prefer_initializing_formals

  DocumentReference<Map<String, dynamic>> _doc(String uid) {
    return _firestore.doc('users/$uid/weekPlan/current');
  }

  @override
  Future<Either<Failure, WeekPlanDTO?>> getActive() async {
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
      return Right(WeekPlanDTO.fromJson(data));
    } on FirebaseException catch (exception) {
      return Left(Failure.firestore(exception));
    }
  }

  @override
  Future<Either<Failure, void>> save(WeekPlanDTO dto) async {
    final uid = _uid;
    if (uid == null) {
      return Left(Failure.unauthenticated());
    }
    try {
      await _doc(uid).set(dto.toJson());
      return const Right(null);
    } on FirebaseException catch (exception) {
      return Left(Failure.firestore(exception));
    }
  }
}

/// The [WeekPlanDataSource] used app-wide, wired to
/// [firebaseFirestoreProvider] and the currently signed-in
/// [currentUidProvider].
final weekPlanDataSourceProvider = Provider<WeekPlanDataSource>(
  (ref) => WeekPlanDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
    uid: ref.watch(currentUidProvider),
  ),
  dependencies: [firebaseFirestoreProvider, currentUidProvider],
);
