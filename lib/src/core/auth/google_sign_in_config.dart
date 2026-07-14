/// The Firebase project's Web OAuth client ID, used so the native Android
/// `google_sign_in` flow issues an ID token whose audience Firebase can
/// verify.
///
/// **MANUAL SETUP REQUIRED** — does not block code or tests, only the real
/// Android sign-in flow:
/// 1. Run `flutterfire configure` (generates `lib/firebase_options.dart`
///    and registers `android/app/google-services.json`) if not already done.
/// 2. Look up the "Web client (auto created by Google Service)" OAuth
///    client ID in the Firebase console → Authentication → Sign-in method
///    → Google → Web SDK configuration.
/// 3. Pass it at build/run time instead of hardcoding it here:
///    `fvm flutter run --dart-define=GOOGLE_SIGN_IN_SERVER_CLIENT_ID=<id>`
///    (value is the `<id>.apps.googleusercontent.com` client ID)
///
/// Left `null` until that manual step is done. `GoogleSignIn.initialize`
/// still runs without it as long as `google-services.json` registers a
/// matching OAuth client, but supplying it explicitly is the most reliable
/// way to get an ID token Firebase accepts on Android.
final String? googleSignInServerClientId = _resolveServerClientId();

String? _resolveServerClientId() {
  const raw = String.fromEnvironment('GOOGLE_SIGN_IN_SERVER_CLIENT_ID');
  return raw.isEmpty ? null : raw;
}
