import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/core/theme/spacing.dart';

/// Renders an [AsyncValue] as loading / error(+retry) / data, replacing raw
/// `AsyncValue.when` calls across the app.
///
/// [onRetry] is typically `() => ref.invalidate(someProvider)`, kept out of
/// this widget so it stays `ref`-free and trivially testable.
class AppAsyncValueWidget<T> extends StatelessWidget {
  const AppAsyncValueWidget({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
    this.loadingBuilder,
  });

  /// The value driving which state is rendered.
  final AsyncValue<T> value;

  /// Builds the widget tree for the successful [T] payload.
  final Widget Function(BuildContext context, T data) builder;

  /// Invoked when the user taps the error state's retry button. When
  /// `null`, no retry button is shown.
  final VoidCallback? onRetry;

  /// Overrides the default [CircularProgressIndicator] while loading.
  final WidgetBuilder? loadingBuilder;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) => builder(context, data),
      loading: () =>
          loadingBuilder?.call(context) ??
          const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          _AppAsyncErrorView(error: error, onRetry: onRetry),
    );
  }
}

class _AppAsyncErrorView extends StatelessWidget {
  const _AppAsyncErrorView({required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error is FailureException
        ? (error as FailureException).message
        : error.toString();

    return Center(
      child: Padding(
        padding: MenuarioSpacing.paddingAll16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              MenuarioSpacing.gapV16,
              FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ],
        ),
      ),
    );
  }
}
