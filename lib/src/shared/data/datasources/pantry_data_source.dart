import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/firebase/firebase_providers.dart';
import 'package:menuario/src/shared/data/models/pantry_item_dto.dart';

/// Firestore datasource port for [PantryItemDTO]s, scoped to
/// `users/{uid}/pantry`.
abstract class PantryDataSource {
  /// Reads the pantry document at [ingredientId].
  Future<Either<Failure, PantryItemDTO>> getById(String ingredientId);

  /// Reads every pantry document, paired with its doc id (ingredient id).
  Future<Either<Failure, List<(String ingredientId, PantryItemDTO dto)>>>
  list();

  /// Writes [dto] to the document at [ingredientId] (create or overwrite).
  Future<Either<Failure, void>> save(String ingredientId, PantryItemDTO dto);
}

/// [PantryDataSource] backed by a real (or fake, in tests)
/// [FirebaseFirestore] instance.
class PantryDataSourceImpl implements PantryDataSource {
  final FirebaseFirestore _firestore;
  final String? _uid;

  // The public constructor params are `firestore`/`uid` (per design); an
  // initializing formal would force them to be named `_firestore`/`_uid`.
  PantryDataSourceImpl({required FirebaseFirestore firestore, String? uid})
    : _firestore = firestore, // ignore: prefer_initializing_formals
      _uid = uid; // ignore: prefer_initializing_formals

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _firestore.collection('users/$uid/pantry');
  }

  @override
  Future<Either<Failure, PantryItemDTO>> getById(String ingredientId) async {
    final uid = _uid;
    if (uid == null) {
      return Left(Failure.unauthenticated());
    }
    try {
      final snapshot = await _collection(uid).doc(ingredientId).get();
      final data = snapshot.data();
      if (data == null) {
        return Left(
          Failure(
            message: 'Artículo de despensa "$ingredientId" no encontrado.',
            code: 'notFound',
          ),
        );
      }
      return Right(PantryItemDTO.fromJson(data));
    } on FirebaseException catch (exception) {
      return Left(Failure.firestore(exception));
    } on Object catch (exception, stackTrace) {
      return Left(Failure.malformedData(exception, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<(String, PantryItemDTO)>>> list() async {
    final uid = _uid;
    if (uid == null) {
      return Left(Failure.unauthenticated());
    }
    try {
      final snapshot = await _collection(uid).get();
      return Right(
        snapshot.docs
            .map((doc) => (doc.id, PantryItemDTO.fromJson(doc.data())))
            .toList(),
      );
    } on FirebaseException catch (exception) {
      return Left(Failure.firestore(exception));
    } on Object catch (exception, stackTrace) {
      return Left(Failure.malformedData(exception, stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> save(
    String ingredientId,
    PantryItemDTO dto,
  ) async {
    final uid = _uid;
    if (uid == null) {
      return Left(Failure.unauthenticated());
    }
    try {
      await _collection(uid).doc(ingredientId).set(dto.toJson());
      return const Right(null);
    } on FirebaseException catch (exception) {
      return Left(Failure.firestore(exception));
    }
  }
}

/// The [PantryDataSource] used app-wide, wired to [firebaseFirestoreProvider]
/// and the currently signed-in [currentUidProvider].
final pantryDataSourceProvider = Provider<PantryDataSource>(
  (ref) => PantryDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
    uid: ref.watch(currentUidProvider),
  ),
  dependencies: [firebaseFirestoreProvider, currentUidProvider],
);
