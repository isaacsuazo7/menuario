import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/week/presentation/providers/today_provider.dart';
import 'package:menuario/src/features/week/presentation/screens/week_screen.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockWeekPlanRepository extends Mock implements WeekPlanRepository {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  const almuerzoRecipe = Recipe(
    id: 'r-almuerzo',
    name: 'Pollo al horno',
    emoji: '🍗',
    mealType: MealType.almuerzo,
    bomLines: [],
  );
  const almuerzoEntry = PlanEntry(
    day: DayOfWeek.mar,
    mealSlot: MealSlot.almuerzo,
    recipeId: 'r-almuerzo',
    cooked: false,
  );

  late MockWeekPlanRepository mockWeekPlanRepository;
  late MockRecipeRepository mockRecipeRepository;

  setUp(() {
    mockWeekPlanRepository = MockWeekPlanRepository();
    mockRecipeRepository = MockRecipeRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    bool overrideToday = false,
    DayOfWeek? today,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weekPlanRepositoryProvider.overrideWithValue(mockWeekPlanRepository),
          recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
          if (overrideToday) todayProvider.overrideWithValue(today),
        ],
        child: const MaterialApp(home: WeekScreen()),
      ),
    );
  }

  testWidgets('shows a loading indicator while the initial load is pending', (
    tester,
  ) async {
    final planCompleter = Completer<Either<Failure, WeekPlan?>>();
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) => planCompleter.future);
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    await pumpScreen(tester);
    await tester.pump();

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
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('No se pudo cargar.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets(
    'an empty plan renders all 24 cells as empty (6 days x 4 slots)',
    (tester) async {
      when(
        () => mockWeekPlanRepository.getActive(),
      ).thenAnswer((_) async => const Right(WeekPlan(entries: [])));
      when(
        () => mockRecipeRepository.list(),
      ).thenAnswer((_) async => const Right([]));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Agregar'), findsNWidgets(24));
      for (final day in DayOfWeek.values) {
        expect(find.text(day.label), findsOneWidget);
      }
    },
  );

  testWidgets('a populated plan renders the assigned cell and leaves the '
      'rest empty', (tester) async {
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) async => const Right(WeekPlan(entries: [almuerzoEntry])));
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([almuerzoRecipe]));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Pollo al horno'), findsOneWidget);
    expect(find.text('Agregar'), findsNWidgets(23));
  });

  testWidgets('marks only today\'s section with a "Hoy" chip', (tester) async {
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) async => const Right(WeekPlan(entries: [])));
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    await pumpScreen(tester, overrideToday: true, today: DayOfWeek.mar);
    await tester.pumpAndSettle();

    expect(find.text('Hoy'), findsOneWidget);
  });

  testWidgets('on Sunday (today == null) no section is marked', (tester) async {
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) async => const Right(WeekPlan(entries: [])));
    when(
      () => mockRecipeRepository.list(),
    ).thenAnswer((_) async => const Right([]));

    await pumpScreen(tester, overrideToday: true, today: null);
    await tester.pumpAndSettle();

    expect(find.text('Hoy'), findsNothing);
  });
}
