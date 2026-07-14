import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/auth/auth_service.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/features/auth/presentation/providers/sign_in_submission_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUser extends Mock implements User {}

void main() {
  late MockAuthService mockAuthService;
  late ProviderContainer container;

  setUp(() {
    mockAuthService = MockAuthService();
    container = ProviderContainer(
      overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
    );
    addTearDown(container.dispose);
  });

  test('build returns AsyncData(null) initially', () {
    expect(
      container.read(signInSubmissionProvider),
      const AsyncData<void>(null),
    );
  });

  test('signIn sets state to AsyncData(null) on success', () async {
    // Arrange
    final mockUser = MockUser();
    when(
      () => mockAuthService.signInWithGoogle(),
    ).thenAnswer((_) async => Right(mockUser));

    // Act
    await container.read(signInSubmissionProvider.notifier).signIn();

    // Assert
    expect(
      container.read(signInSubmissionProvider),
      const AsyncData<void>(null),
    );
    verify(() => mockAuthService.signInWithGoogle()).called(1);
  });

  test('signIn sets state to AsyncError on failure', () async {
    // Arrange
    final failure = Failure(message: 'No se pudo iniciar sesión.');
    when(
      () => mockAuthService.signInWithGoogle(),
    ).thenAnswer((_) async => Left(failure));

    // Act
    await container.read(signInSubmissionProvider.notifier).signIn();

    // Assert
    final state = container.read(signInSubmissionProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<FailureException>());
    expect((state.error! as FailureException).failure, failure);
  });

  test('signIn emits AsyncLoading while the sign-in is in flight', () async {
    // Arrange
    final completer = Completer<Either<Failure, User>>();
    when(
      () => mockAuthService.signInWithGoogle(),
    ).thenAnswer((_) => completer.future);

    // Act
    final signInFuture = container
        .read(signInSubmissionProvider.notifier)
        .signIn();

    // Assert (loading)
    expect(container.read(signInSubmissionProvider).isLoading, isTrue);

    // Resolve and assert (settled)
    completer.complete(Right(MockUser()));
    await signInFuture;
    expect(
      container.read(signInSubmissionProvider),
      const AsyncData<void>(null),
    );
  });
}
