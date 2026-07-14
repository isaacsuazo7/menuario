import 'package:dartz/dartz.dart' hide Unit;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:menuario/src/core/error/failure.dart';

/// Wraps [FirebaseAuth] behind the project's `Either<Failure, T>`
/// boundary so callers never handle native Firebase exceptions directly.
///
/// Google sign-in uses the native
/// `FirebaseAuth.signInWithProvider(GoogleAuthProvider())` flow — no
/// `google_sign_in` dependency required (see design decision 6).
class AuthService {
  final FirebaseAuth _auth;

  // The public parameter is `auth` (per design), assigned to the private
  // `_auth` field — an initializing formal would force the parameter
  // itself to be named `_auth`.
  // ignore: prefer_initializing_formals
  AuthService({required FirebaseAuth auth}) : _auth = auth;

  /// Signs the user in with their Google account via the native Firebase
  /// provider flow.
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final credential = await _auth.signInWithProvider(GoogleAuthProvider());
      final user = credential.user;
      if (user == null) {
        return Left(Failure.authNoUser());
      }
      return Right(user);
    } on FirebaseAuthException catch (exception) {
      return Left(_mapAuthException(exception));
    }
  }

  /// Signs the current user out.
  Future<Either<Failure, void>> signOut() async {
    try {
      await _auth.signOut();
      return const Right(null);
    } on FirebaseAuthException catch (exception) {
      return Left(_mapAuthException(exception));
    }
  }

  /// Emits the current [User] whenever the authentication state changes
  /// (sign-in, sign-out, token refresh), and `null` when signed out.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// The currently signed-in user, or `null` when signed out.
  User? get currentUser => _auth.currentUser;

  /// The currently signed-in user's uid, or `null` when signed out.
  String? get currentUid => _auth.currentUser?.uid;

  Failure _mapAuthException(FirebaseAuthException exception) {
    return Failure(
      message: exception.message ?? 'Error de autenticación con Firebase.',
      code: exception.code,
      exception: exception,
    );
  }
}
