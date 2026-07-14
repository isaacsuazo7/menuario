import 'package:google_sign_in/google_sign_in.dart';

/// The Google identity tokens obtained from a successful native sign-in,
/// used to build a Firebase [GoogleAuthProvider] credential.
///
/// [idToken] is the OpenID Connect token Firebase verifies to authenticate
/// the user. [accessToken] is best-effort OAuth2 scope authorization and may
/// be `null` — Firebase credential exchange only strictly requires the ID
/// token.
class GoogleCredentialData {
  const GoogleCredentialData({this.idToken, this.accessToken});

  final String? idToken;
  final String? accessToken;
}

/// Wraps the native `google_sign_in` account-picker flow behind a thin,
/// mockable boundary so [AuthService] stays unit-testable without touching
/// the real platform SDK.
///
/// See design decision 6 reversal: `FirebaseAuth.signInWithProvider` runs a
/// WEB-REDIRECT OAuth flow on Android (opens `<project>.firebaseapp.com` in
/// a browser) which fails on real devices with modern browser storage
/// partitioning ("missing initial state ... signInWithRedirect"). The
/// native account picker via `google_sign_in` replaces it.
abstract class GoogleSignInClient {
  /// Shows the native Google account picker and returns the signed-in
  /// account's tokens, or `null` if the user dismissed the picker without
  /// choosing an account.
  Future<GoogleCredentialData?> signIn();
}

/// Default [GoogleSignInClient] built on top of the `google_sign_in` v7
/// singleton API (`GoogleSignIn.instance`).
class GoogleSignInClientImpl implements GoogleSignInClient {
  GoogleSignInClientImpl({this.serverClientId});

  /// The Firebase project's Web OAuth client ID. See
  /// `lib/src/core/auth/google_sign_in_config.dart` for how this is
  /// resolved and the manual setup step it depends on.
  final String? serverClientId;

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    await GoogleSignIn.instance.initialize(serverClientId: serverClientId);
    _initialized = true;
  }

  @override
  Future<GoogleCredentialData?> signIn() async {
    await _ensureInitialized();
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      final accessToken = await _bestEffortAccessToken(account);
      return GoogleCredentialData(idToken: idToken, accessToken: accessToken);
    } on GoogleSignInException catch (exception) {
      if (exception.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    }
  }

  /// Requests an OAuth2 access token without prompting the user again.
  ///
  /// Best-effort only: any failure here is swallowed and `null` is returned
  /// rather than failing the whole sign-in, since Firebase credential
  /// exchange does not require it.
  Future<String?> _bestEffortAccessToken(GoogleSignInAccount account) async {
    try {
      final authorization = await account.authorizationClient
          .authorizationForScopes(const <String>['email']);
      return authorization?.accessToken;
    } on Object {
      return null;
    }
  }
}
