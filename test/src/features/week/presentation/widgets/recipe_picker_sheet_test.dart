import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';
import 'package:menuario/src/features/week/presentation/widgets/_recipe_picker_sheet.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockWeekPlanRepository extends Mock implements WeekPlanRepository {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  const desayunoRecipe = Recipe(
    id: 'r-desayuno',
    name: 'Avena',
    emoji: '🥣',
    mealType: MealType.desayuno,
    bomLines: [],
  );
  const almuerzoRecipeA = Recipe(
    id: 'r-almuerzo-a',
    name: 'Pollo al horno',
    emoji: '🍗',
    mealType: MealType.almuerzo,
    bomLines: [],
  );
  const almuerzoRecipeB = Recipe(
    id: 'r-almuerzo-b',
    name: 'Pasta',
    emoji: '🍝',
    mealType: MealType.almuerzo,
    bomLines: [],
  );
  const aderezoRecipe = Recipe(
    id: 'r-aderezo',
    name: 'Vinagreta',
    emoji: '🫙',
    mealType: MealType.aderezo,
    bomLines: [],
  );

  const existingEntry = PlanEntry(
    day: DayOfWeek.mar,
    mealSlot: MealSlot.almuerzo,
    recipeId: 'r-almuerzo-a',
    cooked: false,
  );

  late MockWeekPlanRepository mockWeekPlanRepository;
  late MockRecipeRepository mockRecipeRepository;

  setUpAll(() {
    registerFallbackValue(const WeekPlan(entries: []));
  });

  setUp(() {
    mockWeekPlanRepository = MockWeekPlanRepository();
    mockRecipeRepository = MockRecipeRepository();
    when(() => mockRecipeRepository.list()).thenAnswer(
      (_) async => const Right([
        desayunoRecipe,
        almuerzoRecipeA,
        almuerzoRecipeB,
        aderezoRecipe,
      ]),
    );
  });

  Future<void> pumpSheet(
    WidgetTester tester, {
    required MealSlot mealSlot,
    PlanEntry? currentEntry,
    WeekPlan initialPlan = const WeekPlan(entries: []),
  }) async {
    when(
      () => mockWeekPlanRepository.getActive(),
    ).thenAnswer((_) async => Right(initialPlan));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weekPlanRepositoryProvider.overrideWithValue(
            mockWeekPlanRepository,
          ),
          recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  ref.watch(planControllerProvider);
                  return ElevatedButton(
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      builder: (_) => RecipePickerSheet(
                        day: DayOfWeek.mar,
                        mealSlot: mealSlot,
                        currentEntry: currentEntry,
                      ),
                    ),
                    child: const Text('open'),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists only recipes matching the slot mealType', (
    tester,
  ) async {
    await pumpSheet(tester, mealSlot: MealSlot.almuerzo);

    expect(find.text('Pollo al horno'), findsOneWidget);
    expect(find.text('Pasta'), findsOneWidget);
    expect(find.text('Avena'), findsNothing);
  });

  testWidgets('never shows an aderezo recipe', (tester) async {
    await pumpSheet(tester, mealSlot: MealSlot.almuerzo);

    expect(find.text('Vinagreta'), findsNothing);
  });

  testWidgets('picking a recipe calls assign() with its id', (tester) async {
    when(
      () => mockWeekPlanRepository.save(any()),
    ).thenAnswer((_) async => const Right(null));

    await pumpSheet(tester, mealSlot: MealSlot.almuerzo);

    await tester.tap(find.text('Pasta'));
    await tester.pumpAndSettle();

    final captured = verify(
      () => mockWeekPlanRepository.save(captureAny()),
    ).captured;
    final savedPlan = captured.single as WeekPlan;
    expect(savedPlan.entries.single.recipeId, 'r-almuerzo-b');
    expect(savedPlan.entries.single.day, DayOfWeek.mar);
    expect(savedPlan.entries.single.mealSlot, MealSlot.almuerzo);
  });

  testWidgets('shows a "Quitar" action only when the slot is occupied', (
    tester,
  ) async {
    await pumpSheet(
      tester,
      mealSlot: MealSlot.almuerzo,
      currentEntry: existingEntry,
      initialPlan: const WeekPlan(entries: [existingEntry]),
    );

    expect(find.text('Quitar'), findsOneWidget);
  });

  testWidgets('an empty slot shows no "Quitar" action', (tester) async {
    await pumpSheet(tester, mealSlot: MealSlot.almuerzo);

    expect(find.text('Quitar'), findsNothing);
  });

  testWidgets('tapping "Quitar" calls clear()', (tester) async {
    when(
      () => mockWeekPlanRepository.save(any()),
    ).thenAnswer((_) async => const Right(null));

    await pumpSheet(
      tester,
      mealSlot: MealSlot.almuerzo,
      currentEntry: existingEntry,
      initialPlan: const WeekPlan(entries: [existingEntry]),
    );

    await tester.tap(find.text('Quitar'));
    await tester.pumpAndSettle();

    final captured = verify(
      () => mockWeekPlanRepository.save(captureAny()),
    ).captured;
    final savedPlan = captured.single as WeekPlan;
    expect(savedPlan.entries, isEmpty);
  });

  testWidgets('shows a SnackBar when assign() returns a Failure', (
    tester,
  ) async {
    final saveCompleter = Completer<Either<Failure, void>>();
    when(
      () => mockWeekPlanRepository.save(any()),
    ).thenAnswer((_) => saveCompleter.future);

    await pumpSheet(tester, mealSlot: MealSlot.almuerzo);

    await tester.tap(find.text('Pasta'));
    await tester.pump();

    saveCompleter.complete(Left(Failure(message: 'No se pudo guardar.')));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo guardar.'), findsOneWidget);
  });
}
