import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/firebase/firebase_providers.dart';
import 'package:menuario/src/shared/data/models/ingredient_dto.dart';
import 'package:menuario/src/shared/data/models/pantry_item_dto.dart';

/// Firestore datasource port that atomically writes the [IngredientDTO] and
/// [PantryItemDTO] pair sharing one id, scoped to `users/{uid}`.
abstract class IngredientCatalogDataSource {
  /// Mints a fresh Firestore-generated id, shared by both the ingredient
  /// and pantry docs of a new aggregate.
  String newId();

  /// Writes [ingredient] to `ingredients/{id}` and [pantryItem] to
  /// `pantry/{id}` in a single [WriteBatch] that commits all-or-nothing.
  Future<Either<Failure, void>> saveWithPantry(
    String id,
    IngredientDTO ingredient,
    PantryItemDTO pantryItem,
  );
}

/// [IngredientCatalogDataSource] backed by a real (or fake, in tests)
/// [FirebaseFirestore] instance.
class IngredientCatalogDataSourceImpl implements IngredientCatalogDataSource {
  final FirebaseFirestore _firestore;
  final String? _uid;

  // The public constructor params are `firestore`/`uid` (per design); an
  // initializing formal would force them to be named `_firestore`/`_uid`.
  IngredientCatalogDataSourceImpl({
    required FirebaseFirestore firestore,
    String? uid,
  }) : _firestore = firestore, // ignore: prefer_initializing_formals
       _uid = uid; // ignore: prefer_initializing_formals

  CollectionReference<Map<String, dynamic>> _ingredientsCollection(String uid) {
    return _firestore.collection('users/$uid/ingredients');
  }

  CollectionReference<Map<String, dynamic>> _pantryCollection(String uid) {
    return _firestore.collection('users/$uid/pantry');
  }

  @override
  String newId() {
    final uid = _uid;
    // Any uid-scoped collection mints an equally valid, unique doc id; the
    // ingredients collection is picked arbitrarily.
    final collection = uid == null
        ? _firestore.collection('users/_/ingredients')
        : _ingredientsCollection(uid);
    return collection.doc().id;
  }

  @override
  Future<Either<Failure, void>> saveWithPantry(
    String id,
    IngredientDTO ingredient,
    PantryItemDTO pantryItem,
  ) async {
    final uid = _uid;
    if (uid == null) {
      return Left(Failure.unauthenticated());
    }
    try {
      final batch = _firestore.batch();
      batch.set(_ingredientsCollection(uid).doc(id), ingredient.toJson());
      batch.set(_pantryCollection(uid).doc(id), pantryItem.toJson());
      await batch.commit();
      return const Right(null);
    } on FirebaseException catch (exception) {
      return Left(
        Failure.firestore(code: exception.code, message: exception.message),
      );
    }
  }
}

/// The [IngredientCatalogDataSource] used app-wide, wired to
/// [firebaseFirestoreProvider] and the currently signed-in
/// [currentUidProvider].
final ingredientCatalogDataSourceProvider =
    Provider<IngredientCatalogDataSource>(
      (ref) => IngredientCatalogDataSourceImpl(
        firestore: ref.watch(firebaseFirestoreProvider),
        uid: ref.watch(currentUidProvider),
      ),
      dependencies: [firebaseFirestoreProvider, currentUidProvider],
    );
