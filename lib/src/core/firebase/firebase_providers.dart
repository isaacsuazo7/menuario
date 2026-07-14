import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/firebase/firebase_bootstrap.dart';

/// The app-wide [FirebaseFirestore] instance, configured for offline-first
/// persistence via [firestorePersistenceSettings].
///
/// Colocated so downstream datasource providers can override it in tests
/// with a `FakeFirebaseFirestore` without touching the real Firebase SDK.
final firebaseFirestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance..settings = firestorePersistenceSettings,
  dependencies: const [],
);
