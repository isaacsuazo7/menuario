import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/today/domain/value_objects/cook_target.dart';
import 'package:menuario/src/features/today/presentation/models/day_toggles.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  const allOff = (cenaHoy: false, damManana: false, damHoy: false);
  const allOn = (cenaHoy: true, damManana: true, damHoy: true);
  const onlyCenaHoy = (cenaHoy: true, damManana: false, damHoy: false);
  const onlyDamManana = (cenaHoy: false, damManana: true, damHoy: false);
  const onlyDamHoy = (cenaHoy: false, damManana: false, damHoy: true);

  group('DayToggles round-trip (toTargets -> fromTargets)', () {
    // Every source DateTime.weekday (1=Mon..7=Sun) against every toggle
    // combination reachable for that day — the constrained (forced-off)
    // combinations round-trip back to all-off, everything else survives
    // unchanged.
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      for (final toggles in [allOff, allOn, onlyCenaHoy, onlyDamManana, onlyDamHoy]) {
        test('weekday $weekday, toggles $toggles', () {
          final targets = toTargets(weekday, toggles);
          final roundTripped = fromTargets(weekday, targets);

          DayToggles expected(DayToggles input) {
            if (weekday == DateTime.saturday) {
              return (
                cenaHoy: input.cenaHoy,
                damManana: false,
                damHoy: input.damHoy,
              );
            }
            if (weekday == DateTime.sunday) {
              return (
                cenaHoy: false,
                damManana: input.damManana,
                damHoy: false,
              );
            }
            return input;
          }

          expect(roundTripped, expected(toggles));
        });
      }
    }
  });

  group('non-eating-day constraints', () {
    test('Sábado toTargets never emits a manana target', () {
      final targets = toTargets(DateTime.saturday, allOn);

      expect(targets.where((t) => t.group == CookGroup.manana), isEmpty);
    });

    test('Domingo toTargets never emits an hoy target', () {
      final targets = toTargets(DateTime.sunday, allOn);

      expect(targets.where((t) => t.group == CookGroup.hoy), isEmpty);
    });
  });

  group('exact target mapping (matches the batch-cook seed)', () {
    test('Monday: cenaHoy -> cena lun hoy; damManana -> d/a/m mar manana', () {
      final targets = toTargets(DateTime.monday, allOn);

      expect(targets, [
        (targetDay: DayOfWeek.lun, slot: MealSlot.cena, group: CookGroup.hoy),
        (
          targetDay: DayOfWeek.lun,
          slot: MealSlot.desayuno,
          group: CookGroup.hoy,
        ),
        (
          targetDay: DayOfWeek.lun,
          slot: MealSlot.almuerzo,
          group: CookGroup.hoy,
        ),
        (
          targetDay: DayOfWeek.lun,
          slot: MealSlot.merienda,
          group: CookGroup.hoy,
        ),
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

    test('Friday: only cenaHoy -> cena vie hoy', () {
      final targets = toTargets(DateTime.friday, onlyCenaHoy);

      expect(targets, [
        (targetDay: DayOfWeek.vie, slot: MealSlot.cena, group: CookGroup.hoy),
      ]);
    });

    test(
      'Saturday: cenaHoy+damHoy -> cena sab hoy + d/a/m sab hoy, no manana',
      () {
        final targets = toTargets(
          DateTime.saturday,
          (cenaHoy: true, damManana: false, damHoy: true),
        );

        expect(targets.toSet(), {
          (
            targetDay: DayOfWeek.sab,
            slot: MealSlot.cena,
            group: CookGroup.hoy,
          ),
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
        });
      },
    );

    test('Sunday: only damManana -> d/a/m lun manana', () {
      final targets = toTargets(DateTime.sunday, onlyDamManana);

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
  });
}
