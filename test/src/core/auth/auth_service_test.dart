import 'package:dartz/dartz.dart' hide Unit;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/auth/auth_service.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockFirebaseAuthException extends Mock implements FirebaseAuthException {}

void main() {
  late MockFirebaseAuth mockAuth;
  late AuthService authService;

  setUpAll(() {
    registerFallbackValue(GoogleAuthProvider());
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    authService = AuthService(auth: mockAuth);
  });

  group('signInWithGoogle', () {
    test('should return Right(User) when sign-in succeeds', () async {
      // Arrange
      final mockCredential = MockUserCredential();
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('uid-123');
      when(() => mockCredential.user).thenReturn(mockUser);
      when(
        () => mockAuth.signInWithProvider(any()),
      ).thenAnswer((_) async => mockCredential);

      // Act
      final result = await authService.signInWithGoogle();

      // Assert
      expect(result, isA<Right<Failure, User>>());
      result.fold(
        (failure) => fail('expected Right, got Left($failure)'),
        (user) => expect(user.uid, 'uid-123'),
      );
    });

    test(
      'should return Left(Failure) when the credential has no user',
      () async {
        // Arrange
        final mockCredential = MockUserCredential();
        when(() => mockCredential.user).thenReturn(null);
        when(
          () => mockAuth.signInWithProvider(any()),
        ).thenAnswer((_) async => mockCredential);

        // Act
        final result = await authService.signInWithGoogle();

        // Assert
        expect(result, isA<Left<Failure, User>>());
        result.fold(
          (failure) => expect(failure.code, 'authNoUser'),
          (user) => fail('expected Left, got Right($user)'),
        );
      },
    );

    test(
      'should return Left(Failure) when a FirebaseAuthException is thrown',
      () async {
        // Arrange
        final mockException = MockFirebaseAuthException();
        when(() => mockException.code).thenReturn('account-exists');
        when(
          () => mockException.message,
        ).thenReturn('Account already exists.');
        when(
          () => mockAuth.signInWithProvider(any()),
        ).thenThrow(mockException);

        // Act
        final result = await authService.signInWithGoogle();

        // Assert
        expect(result, isA<Left<Failure, User>>());
        result.fold((failure) {
          expect(failure.code, 'account-exists');
          expect(failure.message, 'Account already exists.');
        }, (user) => fail('expected Left, got Right($user)'));
      },
    );
  });

  group('signOut', () {
    test('should return Right(null) when sign-out succeeds', () async {
      // Arrange
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      // Act
      final result = await authService.signOut();

      // Assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockAuth.signOut()).called(1);
    });

    test(
      'should return Left(Failure) when sign-out throws a '
      'FirebaseAuthException',
      () async {
        // Arrange
        final mockException = MockFirebaseAuthException();
        when(() => mockException.code).thenReturn('network-request-failed');
        when(() => mockException.message).thenReturn('No network.');
        when(() => mockAuth.signOut()).thenThrow(mockException);

        // Act
        final result = await authService.signOut();

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure.code, 'network-request-failed'),
          (_) => fail('expected Left, got Right'),
        );
      },
    );
  });

  group('authStateChanges', () {
    test('should emit the signed-in user', () {
      // Arrange
      final mockUser = MockUser();
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(mockUser));

      // Act & Assert
      expect(authService.authStateChanges, emits(mockUser));
    });

    test('should emit null when signed out', () {
      // Arrange
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(null));

      // Act & Assert
      expect(authService.authStateChanges, emits(isNull));
    });
  });

  group('currentUser / currentUid', () {
    test('currentUser should return the underlying FirebaseAuth user', () {
      // Arrange
      final mockUser = MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      // Act & Assert
      expect(authService.currentUser, mockUser);
    });

    test('currentUid should return null when signed out', () {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(authService.currentUid, isNull);
    });

    test('currentUid should return the uid when signed in', () {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('uid-789');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      // Act & Assert
      expect(authService.currentUid, 'uid-789');
    });
  });
}
