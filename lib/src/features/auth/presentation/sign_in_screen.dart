import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/core/theme/theme.dart';
import 'package:menuario/src/features/auth/presentation/providers/sign_in_submission_provider.dart';

/// Entry screen shown when there is no authenticated user.
///
/// Offers a single "Sign in with Google" action backed by
/// [signInSubmissionProvider]. Loading is reflected on the button itself;
/// failures surface as a non-crashing [SnackBar].
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionState = ref.watch(signInSubmissionProvider);
    final isLoading = submissionState.isLoading;

    ref.listen<AsyncValue<void>>(signInSubmissionProvider, (previous, next) {
      final error = next.error;
      if (next.hasError && error is FailureException) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    });

    return Scaffold(
      body: Center(
        child: Padding(
          padding: MenuarioSpacing.paddingAll24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Menuario', style: MenuarioTypography.h2),
              MenuarioSpacing.gapV8,
              const Text('Organiza tu semana de comidas.'),
              MenuarioSpacing.gapV32,
              FilledButton.icon(
                onPressed: isLoading
                    ? null
                    : () =>
                          ref.read(signInSubmissionProvider.notifier).signIn(),
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: const Text('Iniciar sesión con Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
