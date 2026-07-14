import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';

/// Drives the "sign in with Google" submission, exposing loading/error/
/// success as [AsyncValue].
///
/// `autoDispose` because this only matters while the sign-in screen is
/// mounted; `dependencies: [authServiceProvider]` keeps it overridable in
/// tests without touching Firebase.
final signInSubmissionProvider =
    NotifierProvider.autoDispose<SignInSubmissionNotifier, AsyncValue<void>>(
      SignInSubmissionNotifier.new,
      dependencies: [authServiceProvider],
    );

class SignInSubmissionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Signs the user in with their Google account.
  ///
  /// Sets [state] to [AsyncLoading] while in flight, then to [AsyncData]
  /// on success or [AsyncError] (wrapping a [FailureException]) on
  /// failure.
  Future<void> signIn() async {
    state = const AsyncLoading();

    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.signInWithGoogle();

      if (!ref.mounted) return;

      result.fold(
        (failure) => throw FailureException(failure),
        (_) => state = const AsyncData(null),
      );
    } on FailureException catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    } on Exception catch (e, stackTrace) {
      state = AsyncError(
        FailureException(Failure(message: e.toString())),
        stackTrace,
      );
    }
  }
}
