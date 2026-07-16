import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/auth/auth_service.dart';
import 'package:menuario/src/core/routing/routing.dart';
import 'package:menuario/src/features/ingredients/presentation/screens/ingredients_list_screen.dart';
import 'package:menuario/src/features/provisioning/presentation/screens/provisioning_screen.dart';
import 'package:menuario/src/features/today/data/repositories/cook_schedule_repository_impl.dart';
import 'package:menuario/src/features/today/domain/repositories/cook_schedule_repository.dart';
import 'package:menuario/src/features/today/presentation/screens/cook_schedule_screen.dart';
import 'package:menuario/src/features/today/presentation/today_screen.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUser extends Mock implements User {}

class MockPantryRepository extends Mock implements PantryRepository {}

class MockIngredientRepository extends Mock implements IngredientRepository {}

class MockWeekPlanRepository extends Mock implements WeekPlanRepository {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockCookScheduleRepository extends Mock
    implements CookScheduleRepository {}

void main() {
  late MockAuthService mockAuthService;
  late MockPantryRepository mockPantryRepository;
  late MockIngredientRepository mockIngredientRepository;
  late MockWeekPlanRepository mockWeekPlanRepository;
  late MockRecipeRepository mockRecipeRepository;
  late MockCookScheduleRepository mockCookScheduleRepository;

  setUp(() {
    mockAuthService = MockAuthService();
    mockPantryRepository = MockPantryRepository();
    mockIngredientRepository = MockIngredientRepository();
    mockWeekPlanRepository = MockWeekPlanRepository();
    mockRecipeRepository = MockRecipeRepository();
    mockCookScheduleRepository = MockCookScheduleRepository();
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => const Right([]));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([]));
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) async => const Right(WeekPlan(entries: [])));
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([]));
    when(
      () => mockCookScheduleRepository.getActive(),
    ).thenAnswer((_) async => const Right(null));
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          pantryRepositoryProvider.overrideWithValue(mockPantryRepository),
          ingredientRepositoryProvider.overrideWithValue(
            mockIngredientRepository,
          ),
          weekPlanRepositoryProvider.overrideWithValue(mockWeekPlanRepository),
          recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
          cookScheduleRepositoryProvider.overrideWithValue(
            mockCookScheduleRepository,
          ),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            return MaterialApp.router(
              routerConfig: ref.watch(appRouterProvider),
            );
          },
        ),
      ),
    );
  }

  testWidgets('shows the splash screen while auth state is loading', (
    tester,
  ) async {
    final neverEmits = StreamController<User?>.broadcast();
    addTearDown(neverEmits.close);
    when(
      () => mockAuthService.authStateChanges,
    ).thenAnswer((_) => neverEmits.stream);

    await pumpApp(tester);
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('redirects to sign-in when signed out', (tester) async {
    when(
      () => mockAuthService.authStateChanges,
    ).thenAnswer((_) => Stream.value(null));

    await pumpApp(tester);
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión con Google'), findsOneWidget);
  });

  testWidgets('shows the four-tab shell when signed in', (tester) async {
    final mockUser = MockUser();
    when(
      () => mockAuthService.authStateChanges,
    ).thenAnswer((_) => Stream.value(mockUser));

    await pumpApp(tester);
    await tester.pumpAndSettle();

    expect(find.byType(TodayScreen), findsOneWidget);
    // Exactly one AppBar for the whole shell — the active tab's title lives
    // there only, never duplicated inside the tab screen itself.
    expect(find.byType(AppBar), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Hoy')),
      findsOneWidget,
    );
    expect(find.text('Semana'), findsOneWidget);
    expect(find.text('Abastecer'), findsOneWidget);
    expect(find.text('Recetario'), findsOneWidget);
  });

  testWidgets(
    'tapping a tab shows its placeholder and keeps the previous one alive',
    (tester) async {
      final mockUser = MockUser();
      when(
        () => mockAuthService.authStateChanges,
      ).thenAnswer((_) => Stream.value(mockUser));

      await pumpApp(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Abastecer'));
      await tester.pumpAndSettle();

      expect(find.byType(ProvisioningScreen), findsOneWidget);
      // The previous branch's widget stays in the tree (not disposed) —
      // this is exactly what StatefulShellRoute.indexedStack guarantees.
      expect(find.byType(TodayScreen, skipOffstage: false), findsOneWidget);
      // The shell's single AppBar title switched to the new active tab.
      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Abastecer'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('drawer sign-out signs out and routes back to sign-in', (
    tester,
  ) async {
    final mockUser = MockUser();
    final authStateController = StreamController<User?>.broadcast();
    addTearDown(authStateController.close);

    when(
      () => mockAuthService.authStateChanges,
    ).thenAnswer((_) => authStateController.stream);
    when(() => mockAuthService.signOut()).thenAnswer((_) async {
      authStateController.add(null);
      return const Right(null);
    });

    await pumpApp(tester);
    authStateController.add(mockUser);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    verify(() => mockAuthService.signOut()).called(1);
    expect(find.text('Iniciar sesión con Google'), findsOneWidget);
  });

  testWidgets('drawer Ingredientes tile opens the ingredients list screen', (
    tester,
  ) async {
    final mockUser = MockUser();
    when(
      () => mockAuthService.authStateChanges,
    ).thenAnswer((_) => Stream.value(mockUser));

    await pumpApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ingredientes'));
    await tester.pumpAndSettle();

    expect(find.byType(IngredientsListScreen), findsOneWidget);
  });

  testWidgets(
    'drawer Calendario de cocina tile opens the cook schedule editor',
    (tester) async {
      final mockUser = MockUser();
      when(
        () => mockAuthService.authStateChanges,
      ).thenAnswer((_) => Stream.value(mockUser));

      await pumpApp(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calendario de cocina'));
      await tester.pumpAndSettle();

      expect(find.byType(CookScheduleScreen), findsOneWidget);
    },
  );
}
