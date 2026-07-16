import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/auth/auth_service.dart';
import 'package:menuario/src/core/routing/widgets/app_drawer.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUser extends Mock implements User {}

/// Minimal transparent PNG so [NetworkImage] loads deterministically in
/// widget tests instead of hitting the network (which the test HttpClient
/// rejects with a 400).
const _kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x62, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = _MockHttpClient();
    final request = _MockHttpClientRequest();
    final response = _MockHttpClientResponse();
    final headers = _MockHttpHeaders();
    when(() => client.getUrl(any())).thenAnswer((_) async => request);
    when(() => request.headers).thenReturn(headers);
    when(request.close).thenAnswer((_) async => response);
    when(() => response.contentLength).thenReturn(_kTransparentImage.length);
    when(() => response.statusCode).thenReturn(HttpStatus.ok);
    when(() => response.compressionState)
        .thenReturn(HttpClientResponseCompressionState.notCompressed);
    when(
      () => response.listen(
        any(),
        onError: any(named: 'onError'),
        onDone: any(named: 'onDone'),
        cancelOnError: any(named: 'cancelOnError'),
      ),
    ).thenAnswer((invocation) {
      final onData =
          invocation.positionalArguments[0] as void Function(List<int>);
      final onDone = invocation.namedArguments[#onDone] as void Function()?;
      return Stream<List<int>>.fromIterable([_kTransparentImage])
          .listen(onData, onDone: onDone);
    });
    return client;
  }
}

class _MockHttpClient extends Mock implements HttpClient {}

class _MockHttpClientRequest extends Mock implements HttpClientRequest {}

class _MockHttpClientResponse extends Mock implements HttpClientResponse {}

class _MockHttpHeaders extends Mock implements HttpHeaders {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
  });

  Future<void> pumpDrawer(
    WidgetTester tester, {
    User? user,
    AuthService? service,
    bool loading = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (service != null) authServiceProvider.overrideWithValue(service),
          authStateProvider.overrideWith(
            (ref) => loading ? const Stream.empty() : Stream.value(user),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(appBar: AppBar(), drawer: const AppDrawer()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
  }

  MockUser buildUser({String? displayName, String? email, String? photoURL}) {
    final user = MockUser();
    when(() => user.displayName).thenReturn(displayName);
    when(() => user.email).thenReturn(email);
    when(() => user.photoURL).thenReturn(photoURL);
    return user;
  }

  testWidgets('renders the display name and email in the header', (
    tester,
  ) async {
    final user = buildUser(
      displayName: 'Isaac Suazo',
      email: 'isaac@cit.hn',
    );

    await pumpDrawer(tester, user: user);

    expect(find.text('Isaac Suazo'), findsOneWidget);
    expect(find.text('isaac@cit.hn'), findsOneWidget);
  });

  testWidgets('shows initials when the user has no photoURL', (tester) async {
    final user = buildUser(displayName: 'Isaac Suazo', email: 'isaac@cit.hn');

    await pumpDrawer(tester, user: user);

    expect(find.text('IS'), findsOneWidget);
  });

  testWidgets('shows the photo avatar (no initials) when photoURL is set', (
    tester,
  ) async {
    await HttpOverrides.runZoned(() async {
      final user = buildUser(
        displayName: 'Isaac Suazo',
        email: 'isaac@cit.hn',
        photoURL: 'https://example.com/avatar.png',
      );

      await pumpDrawer(tester, user: user);

      expect(find.text('IS'), findsNothing);
      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.backgroundImage, isNotNull);
    }, createHttpClient: _FakeHttpOverrides().createHttpClient);
  });

  testWidgets('falls back to email when the display name is null', (
    tester,
  ) async {
    final user = buildUser(displayName: null, email: 'dev@cit.hn');

    await pumpDrawer(tester, user: user);

    expect(find.text('dev@cit.hn'), findsWidgets);
    expect(find.text('D'), findsOneWidget);
    expect(find.textContaining('null'), findsNothing);
  });

  testWidgets('does not crash while auth state is loading', (tester) async {
    await pumpDrawer(tester, loading: true);

    expect(find.byType(AppDrawer), findsOneWidget);
    expect(find.textContaining('null'), findsNothing);
    expect(find.text('Ingredientes'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('keeps the Ingredientes navigation item', (tester) async {
    final user = buildUser(displayName: 'Isaac Suazo', email: 'isaac@cit.hn');

    await pumpDrawer(tester, user: user);

    expect(find.text('Ingredientes'), findsOneWidget);
  });

  testWidgets('pins "Cerrar sesión" below the Ingredientes item', (
    tester,
  ) async {
    final user = buildUser(displayName: 'Isaac Suazo', email: 'isaac@cit.hn');

    await pumpDrawer(tester, user: user);

    final ingredientsY = tester.getCenter(find.text('Ingredientes')).dy;
    final signOutY = tester.getCenter(find.text('Cerrar sesión')).dy;
    expect(signOutY, greaterThan(ingredientsY));
  });

  testWidgets('tapping "Cerrar sesión" calls signOut', (tester) async {
    final mockAuthService = MockAuthService();
    final user = buildUser(displayName: 'Isaac Suazo', email: 'isaac@cit.hn');
    when(
      () => mockAuthService.signOut(),
    ).thenAnswer((_) async => const Right(null));

    await pumpDrawer(tester, user: user, service: mockAuthService);

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    verify(() => mockAuthService.signOut()).called(1);
  });
}
