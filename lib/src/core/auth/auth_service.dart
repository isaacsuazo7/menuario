import 'package:dartz/dartz.dart' hide Unit;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignInException;
import 'package:menuario/src/core/auth/google_sign_in_client.dart';
import 'package:menuario/src/core/error/failure.dart';

/// Wraps [FirebaseAuth] behind the project's `Either<Failure, T>` boundary
/// so callers never handle native Firebase/Google exceptions directly.
///
/// Google sign-in uses the NATIVE account-picker flow: [GoogleSignInClient]
/// (`google_sign_in` package) obtains the signed-in account's tokens, which
/// are exchanged for a Firebase credential via
/// [GoogleAuthProvider.credential] → `FirebaseAuth.signInWithCredential`.
///
/// This reverses design decision 6
/// (`FirebaseAuth.signInWithProvider(GoogleAuthProvider())`): that call
/// runs a WEB-REDIRECT OAuth flow on Android, opening
/// `<project>.firebaseapp.com` in a browser, which fails on real devices
/// with modern browser storage partitioning ("Unable to process request
/// due to missing initial state ... signInWithRedirect in a
/// storage-partitioned browser environment").
class AuthService {
  // The public parameters are `auth`/`googleSignInClient` (per design),
  // assigned to private fields — initializing formals would force the
  // parameters themselves to be private.
  AuthService({
    required FirebaseAuth auth,
    required GoogleSignInClient googleSignInClient,
    // ignore: prefer_initializing_formals
  }) : _auth = auth,
       // ignore: prefer_initializing_formals
       _googleSignInClient = googleSignInClient;

  final FirebaseAuth _auth;
  final GoogleSignInClient _googleSignInClient;

  /// Signs the user in with their Google account via the native account
  /// picker, then exchanges the resulting tokens for a Firebase credential.
  ///
  /// Returns `Left(Failure.authCancelled())` if the user dismisses the
  /// account picker without choosing an account — an expected outcome,
  /// never an uncaught throw.
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final credentialData = await _googleSignInClient.signIn();
      if (credentialData == null) {
        return Left(Failure.authCancelled());
      }

      final credential = GoogleAuthProvider.credential(
        idToken: credentialData.idToken,
        accessToken: credentialData.accessToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        return Left(Failure.authNoUser());
      }
      return Right(user);
    } on FirebaseAuthException catch (exception) {
      return Left(_mapAuthException(exception));
    } on GoogleSignInException catch (exception) {
      return Left(_mapGoogleSignInException(exception));
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

  Failure _mapGoogleSignInException(GoogleSignInException exception) {
    return Failure(
      message: exception.description ?? 'Error al iniciar sesión con Google.',
      code: exception.code.name,
      exception: exception,
    );
  }
}
