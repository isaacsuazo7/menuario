import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/today/presentation/models/cook_item.dart';
import 'package:menuario/src/features/today/presentation/providers/cook_schedule_provider.dart';
import 'package:menuario/src/features/today/presentation/providers/now_provider.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  List<CookTarget> targetsFor(DateTime now) {
    final container = ProviderContainer(
      overrides: [nowProvider.overrideWithValue(now)],
    );
    addTearDown(container.dispose);

    final resolvedNow = container.read(nowProvider);
    final schedule = container.read(cookScheduleProvider);
    return schedule[resolvedNow.weekday] ?? const [];
  }

  test('Monday: hoy=cena, mañana=Martes d/a/m', () {
    final targets = targetsFor(DateTime(2024, 1, 1)); // Monday

    expect(targets, [
      (targetDay: DayOfWeek.lun, slot: MealSlot.cena, group: CookGroup.hoy),
      (
        targetDay: DayOfWeek.mar,
        slot: MealSlot.desayuno,
        group: CookGroup.manana,
      ),
      (
        targetDay: DayOfWeek.mar,
        slot: MealSlot.almuerzo,
        group: CookGroup.manana,
      ),
      (
        targetDay: DayOfWeek.mar,
        slot: MealSlot.merienda,
        group: CookGroup.manana,
      ),
    ]);
  });

  test('Tuesday: hoy=cena, mañana=Miércoles d/a/m', () {
    final targets = targetsFor(DateTime(2024, 1, 2)); // Tuesday

    expect(targets, [
      (targetDay: DayOfWeek.mar, slot: MealSlot.cena, group: CookGroup.hoy),
      (
        targetDay: DayOfWeek.mie,
        slot: MealSlot.desayuno,
        group: CookGroup.manana,
      ),
      (
        targetDay: DayOfWeek.mie,
        slot: MealSlot.almuerzo,
        group: CookGroup.manana,
      ),
      (
        targetDay: DayOfWeek.mie,
        slot: MealSlot.merienda,
        group: CookGroup.manana,
      ),
    ]);
  });

  test('Wednesday: hoy=cena, mañana=Jueves d/a/m', () {
    final targets = targetsFor(DateTime(2024, 1, 3)); // Wednesday

    expect(targets, [
      (targetDay: DayOfWeek.mie, slot: MealSlot.cena, group: CookGroup.hoy),
      (
        targetDay: DayOfWeek.jue,
        slot: MealSlot.desayuno,
        group: CookGroup.manana,
      ),
      (
        targetDay: DayOfWeek.jue,
        slot: MealSlot.almuerzo,
        group: CookGroup.manana,
      ),
      (
        targetDay: DayOfWeek.jue,
        slot: MealSlot.merienda,
        group: CookGroup.manana,
      ),
    ]);
  });

  test('Thursday: hoy=cena, mañana=Viernes d/a/m', () {
    final targets = targetsFor(DateTime(2024, 1, 4)); // Thursday

    expect(targets, [
      (targetDay: DayOfWeek.jue, slot: MealSlot.cena, group: CookGroup.hoy),
      (
        targetDay: DayOfWeek.vie,
        slot: MealSlot.desayuno,
        group: CookGroup.manana,
      ),
      (
        targetDay: DayOfWeek.vie,
        slot: MealSlot.almuerzo,
        group: CookGroup.manana,
      ),
      (
        targetDay: DayOfWeek.vie,
        slot: MealSlot.merienda,
        group: CookGroup.manana,
      ),
    ]);
  });

  test('Friday: hoy=cena only, no mañana', () {
    final targets = targetsFor(DateTime(2024, 1, 5)); // Friday

    expect(targets, [
      (targetDay: DayOfWeek.vie, slot: MealSlot.cena, group: CookGroup.hoy),
    ]);
  });

  test('Saturday: hoy=d/a/m/cena, no mañana', () {
    final targets = targetsFor(DateTime(2024, 1, 6)); // Saturday

    expect(targets, [
      (
        targetDay: DayOfWeek.sab,
        slot: MealSlot.desayuno,
        group: CookGroup.hoy,
      ),
      (
        targetDay: DayOfWeek.sab,
        slot: MealSlot.almuerzo,
        group: CookGroup.hoy,
      ),
      (
        targetDay: DayOfWeek.sab,
        slot: MealSlot.merienda,
        group: CookGroup.hoy,
      ),
      (targetDay: DayOfWeek.sab, slot: MealSlot.cena, group: CookGroup.hoy),
    ]);
  });

  test('Sunday: mañana=Lunes d/a/m only, no hoy', () {
    final targets = targetsFor(DateTime(2024, 1, 7)); // Sunday

    expect(targets, [
      (
        targetDay: DayOfWeek.lun,
        slot: MealSlot.desayuno,
        group: CookGroup.manana,
      ),
      (
        targetDay: DayOfWeek.lun,
        slot: MealSlot.almuerzo,
        group: CookGroup.manana,
      ),
      (
        targetDay: DayOfWeek.lun,
        slot: MealSlot.merienda,
        group: CookGroup.manana,
      ),
    ]);
  });
}
