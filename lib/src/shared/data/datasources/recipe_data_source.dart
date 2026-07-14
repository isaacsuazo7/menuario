import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/firebase/firebase_providers.dart';
import 'package:menuario/src/shared/data/models/recipe_dto.dart';

/// Firestore datasource port for [RecipeDTO]s, scoped to
/// `users/{uid}/recipes`.
///
/// Pure CRUD over JSON maps: no Entity mapping happens here (that is
/// `RecipeRepositoryImpl`'s job). Every operation catches Firestore/platform
/// exceptions and returns `Either<Failure, T>` — nothing is ever rethrown.
abstract class RecipeDataSource {
  /// Reads the recipe document with [id].
  Future<Either<Failure, RecipeDTO>> getById(String id);

  /// Reads every recipe document, paired with its doc id.
  Future<Either<Failure, List<(String id, RecipeDTO dto)>>> list();

  /// Writes [dto] to the document at [id] (create or overwrite).
  Future<Either<Failure, void>> save(String id, RecipeDTO dto);
}

/// [RecipeDataSource] backed by a real (or fake, in tests) [FirebaseFirestore]
/// instance.
class RecipeDataSourceImpl implements RecipeDataSource {
  final FirebaseFirestore _firestore;
  final String? _uid;

  // The public constructor params are `firestore`/`uid` (per design); an
  // initializing formal would force them to be named `_firestore`/`_uid`.
  RecipeDataSourceImpl({required FirebaseFirestore firestore, String? uid})
    : _firestore = firestore, // ignore: prefer_initializing_formals
      _uid = uid; // ignore: prefer_initializing_formals

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _firestore.collection('users/$uid/recipes');
  }

  @override
  Future<Either<Failure, RecipeDTO>> getById(String id) async {
    final uid = _uid;
    if (uid == null) {
      return Left(Failure.unauthenticated());
    }
    try {
      final snapshot = await _collection(uid).doc(id).get();
      final data = snapshot.data();
      if (data == null) {
        return Left(
          Failure(message: 'Receta "$id" no encontrada.', code: 'notFound'),
        );
      }
      return Right(RecipeDTO.fromJson(data));
    } on FirebaseException catch (exception) {
      return Left(Failure.firestore(exception));
    }
  }

  @override
  Future<Either<Failure, List<(String, RecipeDTO)>>> list() async {
    final uid = _uid;
    if (uid == null) {
      return Left(Failure.unauthenticated());
    }
    try {
      final snapshot = await _collection(uid).get();
      return Right(
        snapshot.docs
            .map((doc) => (doc.id, RecipeDTO.fromJson(doc.data())))
            .toList(),
      );
    } on FirebaseException catch (exception) {
      return Left(Failure.firestore(exception));
    }
  }

  @override
  Future<Either<Failure, void>> save(String id, RecipeDTO dto) async {
    final uid = _uid;
    if (uid == null) {
      return Left(Failure.unauthenticated());
    }
    try {
      await _collection(uid).doc(id).set(dto.toJson());
      return const Right(null);
    } on FirebaseException catch (exception) {
      return Left(Failure.firestore(exception));
    }
  }
}

/// The [RecipeDataSource] used app-wide, wired to [firebaseFirestoreProvider]
/// and the currently signed-in [currentUidProvider].
final recipeDataSourceProvider = Provider<RecipeDataSource>(
  (ref) => RecipeDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
    uid: ref.watch(currentUidProvider),
  ),
  dependencies: [firebaseFirestoreProvider, currentUidProvider],
);
