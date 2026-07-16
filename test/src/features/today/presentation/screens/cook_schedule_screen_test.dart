import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/today/data/repositories/cook_schedule_repository_impl.dart';
import 'package:menuario/src/features/today/domain/entities/cook_schedule.dart';
import 'package:menuario/src/features/today/domain/repositories/cook_schedule_repository.dart';
import 'package:menuario/src/features/today/presentation/screens/cook_schedule_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockCookScheduleRepository extends Mock
    implements CookScheduleRepository {}

void main() {
  late MockCookScheduleRepository mockCookScheduleRepository;

  setUp(() {
    mockCookScheduleRepository = MockCookScheduleRepository();
    registerFallbackValue(CookSchedule.seed);
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    Either<Failure, CookSchedule?>? getActiveResult,
    Completer<Either<Failure, CookSchedule?>>? getActiveCompleter,
  }) async {
    when(() => mockCookScheduleRepository.getActive()).thenAnswer((_) async {
      if (getActiveCompleter != null) return getActiveCompleter.future;
      return getActiveResult ?? const Right(null);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cookScheduleRepositoryProvider.overrideWithValue(
            mockCookScheduleRepository,
          ),
        ],
        child: const MaterialApp(home: CookScheduleScreen()),
      ),
    );
    if (getActiveCompleter == null) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  Finder toggleFinder(int weekday, String toggle) =>
      find.byKey(Key('cook-schedule-toggle-$weekday-$toggle'));

  testWidgets('shows a loading indicator while the schedule loads', (
    tester,
  ) async {
    final completer = Completer<Either<Failure, CookSchedule?>>();
    await pumpScreen(tester, getActiveCompleter: completer);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const Right(null));
    await tester.pumpAndSettle();
  });

  testWidgets('shows an error view with a retry action on load failure', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      getActiveResult: Left(Failure(message: 'No se pudo cargar.')),
    );

    expect(find.text('No se pudo cargar.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('renders all 7 days with their toggles', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Lunes'), findsOneWidget);
    expect(find.text('Martes'), findsOneWidget);
    expect(find.text('Miércoles'), findsOneWidget);
    expect(find.text('Jueves'), findsOneWidget);
    expect(find.text('Viernes'), findsOneWidget);
    expect(find.text('Sábado'), findsOneWidget);
    expect(find.text('Domingo'), findsOneWidget);

    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      expect(toggleFinder(weekday, 'cenaHoy'), findsOneWidget);
      expect(toggleFinder(weekday, 'damManana'), findsOneWidget);
      expect(toggleFinder(weekday, 'damHoy'), findsOneWidget);
    }
  });

  testWidgets('Sábado disables the "de mañana" toggle', (tester) async {
    await pumpScreen(tester);

    final tile = tester.widget<SwitchListTile>(
      toggleFinder(DateTime.saturday, 'damManana'),
    );

    expect(tile.onChanged, isNull);
  });

  testWidgets('Domingo disables "cena de hoy" and "de hoy" toggles', (
    tester,
  ) async {
    await pumpScreen(tester);

    final cenaHoyTile = tester.widget<SwitchListTile>(
      toggleFinder(DateTime.sunday, 'cenaHoy'),
    );
    final damHoyTile = tester.widget<SwitchListTile>(
      toggleFinder(DateTime.sunday, 'damHoy'),
    );
    final damMananaTile = tester.widget<SwitchListTile>(
      toggleFinder(DateTime.sunday, 'damManana'),
    );

    expect(cenaHoyTile.onChanged, isNull);
    expect(damHoyTile.onChanged, isNull);
    expect(damMananaTile.onChanged, isNotNull);
  });

  testWidgets('other days offer all three toggles, independently '
      'interactive', (tester) async {
    await pumpScreen(tester);

    final cenaHoyTile = tester.widget<SwitchListTile>(
      toggleFinder(DateTime.wednesday, 'cenaHoy'),
    );
    final damMananaTile = tester.widget<SwitchListTile>(
      toggleFinder(DateTime.wednesday, 'damManana'),
    );
    final damHoyTile = tester.widget<SwitchListTile>(
      toggleFinder(DateTime.wednesday, 'damHoy'),
    );

    expect(cenaHoyTile.onChanged, isNotNull);
    expect(damMananaTile.onChanged, isNotNull);
    expect(damHoyTile.onChanged, isNotNull);
  });

  // Miércoles's seed only turns on cenaHoy/damManana — damHoy starts off,
  // so it's a clean "flips false -> true" toggle to exercise here.
  testWidgets('tapping a toggle flips the local draft', (tester) async {
    await pumpScreen(tester);

    final before = tester.widget<SwitchListTile>(
      toggleFinder(DateTime.wednesday, 'damHoy'),
    );
    expect(before.value, isFalse);

    await tester.ensureVisible(toggleFinder(DateTime.wednesday, 'damHoy'));
    await tester.tap(toggleFinder(DateTime.wednesday, 'damHoy'));
    await tester.pump();

    final after = tester.widget<SwitchListTile>(
      toggleFinder(DateTime.wednesday, 'damHoy'),
    );
    expect(after.value, isTrue);
  });

  testWidgets('the seed prefills the draft: Lunes cenaHoy starts on', (
    tester,
  ) async {
    await pumpScreen(tester);

    final tile = tester.widget<SwitchListTile>(
      toggleFinder(DateTime.monday, 'cenaHoy'),
    );

    expect(tile.value, isTrue);
  });

  testWidgets('Save persists the edited draft via the controller', (
    tester,
  ) async {
    when(
      () => mockCookScheduleRepository.save(any()),
    ).thenAnswer((_) async => const Right(null));

    await pumpScreen(tester);

    await tester.ensureVisible(toggleFinder(DateTime.wednesday, 'damHoy'));
    await tester.tap(toggleFinder(DateTime.wednesday, 'damHoy'));
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const Key('cook-schedule-save-button')),
    );
    await tester.tap(find.byKey(const Key('cook-schedule-save-button')));
    await tester.pumpAndSettle();

    final captured = verify(
      () => mockCookScheduleRepository.save(captureAny()),
    ).captured;
    expect(captured, hasLength(1));
    final saved = captured.single as CookSchedule;
    expect(
      saved
          .targetsFor(DateTime.wednesday)
          .any((t) => t.slot.name == 'desayuno' && t.group.name == 'hoy'),
      isTrue,
    );
  });

  testWidgets('Save failure surfaces an error and keeps the draft', (
    tester,
  ) async {
    when(
      () => mockCookScheduleRepository.save(any()),
    ).thenAnswer((_) async => Left(Failure(message: 'No se pudo guardar.')));

    await pumpScreen(tester);

    await tester.ensureVisible(toggleFinder(DateTime.wednesday, 'damHoy'));
    await tester.tap(toggleFinder(DateTime.wednesday, 'damHoy'));
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const Key('cook-schedule-save-button')),
    );
    await tester.tap(find.byKey(const Key('cook-schedule-save-button')));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo guardar.'), findsOneWidget);
    final stillOn = tester.widget<SwitchListTile>(
      toggleFinder(DateTime.wednesday, 'damHoy'),
    );
    expect(stillOn.value, isTrue);
  });

  testWidgets('Reset restores the seed configuration in the draft', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.ensureVisible(toggleFinder(DateTime.wednesday, 'damHoy'));
    await tester.tap(toggleFinder(DateTime.wednesday, 'damHoy'));
    await tester.pump();
    expect(
      tester
          .widget<SwitchListTile>(toggleFinder(DateTime.wednesday, 'damHoy'))
          .value,
      isTrue,
    );

    await tester.ensureVisible(
      find.byKey(const Key('cook-schedule-reset-button')),
    );
    await tester.tap(find.byKey(const Key('cook-schedule-reset-button')));
    await tester.pump();

    expect(
      tester
          .widget<SwitchListTile>(toggleFinder(DateTime.wednesday, 'damHoy'))
          .value,
      isFalse,
    );
  });
}
