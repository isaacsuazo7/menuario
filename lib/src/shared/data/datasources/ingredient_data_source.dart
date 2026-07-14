import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/firebase/firebase_providers.dart';
import 'package:menuario/src/shared/data/models/ingredient_dto.dart';

/// Firestore datasource port for [IngredientDTO]s, scoped to
/// `users/{uid}/ingredients`.
abstract class IngredientDataSource {
  /// Reads the ingredient document with [id].
  Future<Either<Failure, IngredientDTO>> getById(String id);

  /// Reads every ingredient document, paired with its doc id.
  Future<Either<Failure, List<(String id, IngredientDTO dto)>>> list();

  /// Writes [dto] to the document at [id] (create or overwrite).
  Future<Either<Failure, void>> save(String id, IngredientDTO dto);
}

/// [IngredientDataSource] backed by a real (or fake, in tests)
/// [FirebaseFirestore] instance.
class IngredientDataSourceImpl implements IngredientDataSource {
  final FirebaseFirestore _firestore;
  final String? _uid;

  // The public constructor params are `firestore`/`uid` (per design); an
  // initializing formal would force them to be named `_firestore`/`_uid`.
  IngredientDataSourceImpl({required FirebaseFirestore firestore, String? uid})
    : _firestore = firestore, // ignore: prefer_initializing_formals
      _uid = uid; // ignore: prefer_initializing_formals

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _firestore.collection('users/$uid/ingredients');
  }

  @override
  Future<Either<Failure, IngredientDTO>> getById(String id) async {
    final uid = _uid;
    if (uid == null) {
      return Left(Failure.unauthenticated());
    }
    try {
      final snapshot = await _collection(uid).doc(id).get();
      final data = snapshot.data();
      if (data == null) {
        return Left(
          Failure(
            message: 'Ingrediente "$id" no encontrado.',
            code: 'notFound',
          ),
        );
      }
      return Right(IngredientDTO.fromJson(data));
    } on FirebaseException catch (exception) {
      return Left(
        Failure.firestore(code: exception.code, message: exception.message),
      );
    } on Object catch (exception, stackTrace) {
      return Left(Failure.malformedData(exception, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<(String, IngredientDTO)>>> list() async {
    final uid = _uid;
    if (uid == null) {
      return Left(Failure.unauthenticated());
    }
    try {
      final snapshot = await _collection(uid).get();
      return Right(
        snapshot.docs
            .map((doc) => (doc.id, IngredientDTO.fromJson(doc.data())))
            .toList(),
      );
    } on FirebaseException catch (exception) {
      return Left(
        Failure.firestore(code: exception.code, message: exception.message),
      );
    } on Object catch (exception, stackTrace) {
      return Left(Failure.malformedData(exception, stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> save(String id, IngredientDTO dto) async {
    final uid = _uid;
    if (uid == null) {
      return Left(Failure.unauthenticated());
    }
    try {
      await _collection(uid).doc(id).set(dto.toJson());
      return const Right(null);
    } on FirebaseException catch (exception) {
      return Left(
        Failure.firestore(code: exception.code, message: exception.message),
      );
    }
  }
}

/// The [IngredientDataSource] used app-wide, wired to
/// [firebaseFirestoreProvider] and the currently signed-in
/// [currentUidProvider].
final ingredientDataSourceProvider = Provider<IngredientDataSource>(
  (ref) => IngredientDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
    uid: ref.watch(currentUidProvider),
  ),
  dependencies: [firebaseFirestoreProvider, currentUidProvider],
);
