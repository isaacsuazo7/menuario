import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockAuth = MockFirebaseAuth();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
    );
    addTearDown(container.dispose);
    // A bare ProviderContainer never starts the underlying stream
    // subscription until something listens to the provider — reading
    // `.future` alone does not trigger it. This mirrors how a widget's
    // `ref.watch` would keep it alive in the real app.
    container.listen(authStateProvider, (_, _) {});
    return container;
  }

  group('authStateProvider', () {
    test('should expose the current user from FirebaseAuth', () async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('uid-abc');
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(mockUser));
      final container = makeContainer();

      // Act
      final result = await container.read(authStateProvider.future);

      // Assert
      expect(result, mockUser);
    });

    test('should expose null when FirebaseAuth reports signed out', () async {
      // Arrange
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(null));
      final container = makeContainer();

      // Act
      final result = await container.read(authStateProvider.future);

      // Assert
      expect(result, isNull);
    });
  });

  group('currentUidProvider', () {
    test('should derive the uid once a user is emitted', () async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('uid-def');
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(mockUser));
      final container = makeContainer();
      await container.read(authStateProvider.future);

      // Act
      final uid = container.read(currentUidProvider);

      // Assert
      expect(uid, 'uid-def');
    });

    test('should be null when signed out', () async {
      // Arrange
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(null));
      final container = makeContainer();
      await container.read(authStateProvider.future);

      // Act
      final uid = container.read(currentUidProvider);

      // Assert
      expect(uid, isNull);
    });
  });
}
