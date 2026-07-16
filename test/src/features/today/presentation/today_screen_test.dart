import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/today/data/repositories/cook_schedule_repository_impl.dart';
import 'package:menuario/src/features/today/domain/repositories/cook_schedule_repository.dart';
import 'package:menuario/src/features/today/presentation/providers/now_provider.dart';
import 'package:menuario/src/features/today/presentation/today_screen.dart';
import 'package:menuario/src/features/week/presentation/providers/today_provider.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockWeekPlanRepository extends Mock implements WeekPlanRepository {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockCookScheduleRepository extends Mock
    implements CookScheduleRepository {}

class MockUser extends Mock implements User {}

void main() {
  late MockWeekPlanRepository mockWeekPlanRepository;
  late MockRecipeRepository mockRecipeRepository;
  late MockCookScheduleRepository mockCookScheduleRepository;

  setUp(() {
    mockWeekPlanRepository = MockWeekPlanRepository();
    mockRecipeRepository = MockRecipeRepository();
    mockCookScheduleRepository = MockCookScheduleRepository();
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

  Future<void> pumpScreen(
    WidgetTester tester, {
    DayOfWeek? today = DayOfWeek.mar,
    bool settle = true,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weekPlanRepositoryProvider.overrideWithValue(mockWeekPlanRepository),
          recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
          cookScheduleRepositoryProvider.overrideWithValue(
            mockCookScheduleRepository,
          ),
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          nowProvider.overrideWithValue(DateTime(2024, 1, 2)),
          todayProvider.overrideWithValue(today),
        ],
        child: const MaterialApp(home: TodayScreen()),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  testWidgets('defaults to Cocinar visible, Comer hidden, with no AppBar', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Cocinar'), findsOneWidget);
    expect(find.text('Comer'), findsOneWidget);
    expect(find.text('Nada para cocinar hoy'), findsOneWidget);
    expect(find.text('Nada planeado — planificá en Semana'), findsNothing);
  });

  testWidgets('tapping Comer shows Comer content and hides Cocinar', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Comer'));
    await tester.pumpAndSettle();

    expect(find.text('Nada planeado — planificá en Semana'), findsOneWidget);
    expect(find.text('Nada para cocinar hoy'), findsNothing);

    await tester.tap(find.text('Cocinar'));
    await tester.pumpAndSettle();

    expect(find.text('Nada para cocinar hoy'), findsOneWidget);
    expect(find.text('Nada planeado — planificá en Semana'), findsNothing);
  });

  testWidgets('shows a loading indicator while the plan is loading', (
    tester,
  ) async {
    final planCompleter = Completer<Either<Failure, WeekPlan?>>();
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) => planCompleter.future);

    await pumpScreen(tester, settle: false);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    planCompleter.complete(const Right(WeekPlan(entries: [])));
    await tester.pumpAndSettle();
  });

  testWidgets('shows an error view with a retry action on load failure', (
    tester,
  ) async {
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) async => Left(Failure(message: 'No se pudo cargar.')));

    await pumpScreen(tester);

    expect(find.text('No se pudo cargar.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });
}
