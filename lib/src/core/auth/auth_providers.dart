import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/auth/auth_service.dart';

/// The app-wide [FirebaseAuth] instance.
///
/// Colocated so downstream providers can override it in tests without
/// touching the real Firebase SDK.
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
  dependencies: const [],
);

/// The [AuthService] built on top of [firebaseAuthProvider].
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(auth: ref.watch(firebaseAuthProvider)),
  dependencies: [firebaseAuthProvider],
);

/// Streams the current authenticated [User], or `null` when signed out.
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges,
  dependencies: [authServiceProvider],
);

/// Derives the current uid from [authStateProvider].
///
/// Consumed later by uid-scoped Firestore datasources — `null` while
/// signed out or before the first auth-state emission.
final currentUidProvider = Provider<String?>(
  (ref) => ref.watch(authStateProvider).value?.uid,
  dependencies: [authStateProvider],
);
