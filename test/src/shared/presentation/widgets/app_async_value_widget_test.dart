import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/shared/presentation/widgets/app_async_value_widget.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required AsyncValue<String> value,
    VoidCallback? onRetry,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: AppAsyncValueWidget<String>(
          value: value,
          onRetry: onRetry,
          builder: (context, data) => Text(data),
        ),
      ),
    );
  }

  testWidgets('shows a loading indicator while loading', (tester) async {
    await pump(tester, value: const AsyncLoading());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Reintentar'), findsNothing);
  });

  testWidgets('renders the data builder on success', (tester) async {
    await pump(tester, value: const AsyncData('hola'));

    expect(find.text('hola'), findsOneWidget);
  });

  testWidgets('shows the failure message and a retry button on error', (
    tester,
  ) async {
    var retried = false;
    final error = FailureException(Failure(message: 'Algo salió mal.'));

    await pump(
      tester,
      value: AsyncError<String>(error, StackTrace.current),
      onRetry: () => retried = true,
    );

    expect(find.text('Algo salió mal.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pump();

    expect(retried, isTrue);
  });
}
