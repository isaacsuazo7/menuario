import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/auth/auth_service.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/auth/presentation/sign_in_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUser extends Mock implements User {}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  Future<void> pumpSignInScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        child: const MaterialApp(home: SignInScreen()),
      ),
    );
  }

  testWidgets('renders the Google sign-in button', (tester) async {
    await pumpSignInScreen(tester);

    expect(find.text('Iniciar sesión con Google'), findsOneWidget);
  });

  testWidgets('tapping the button invokes signInWithGoogle once', (
    tester,
  ) async {
    when(
      () => mockAuthService.signInWithGoogle(),
    ).thenAnswer((_) async => Right(MockUser()));

    await pumpSignInScreen(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    verify(() => mockAuthService.signInWithGoogle()).called(1);
  });

  testWidgets('shows a loading indicator while signing in', (tester) async {
    final completer = Completer<Either<Failure, User>>();
    when(
      () => mockAuthService.signInWithGoogle(),
    ).thenAnswer((_) => completer.future);

    await pumpSignInScreen(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);

    completer.complete(Right(MockUser()));
    await tester.pumpAndSettle();
  });

  testWidgets('shows an error message when sign-in fails', (tester) async {
    const failure = Failure(message: 'No se pudo iniciar sesión.');
    when(
      () => mockAuthService.signInWithGoogle(),
    ).thenAnswer((_) async => const Left(failure));

    await pumpSignInScreen(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump();

    expect(find.text(failure.message), findsOneWidget);
  });
}
