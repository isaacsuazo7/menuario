import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/today/domain/value_objects/cook_target.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  group('CookGroup', () {
    test('has exactly hoy and manana', () {
      expect(CookGroup.values, [CookGroup.hoy, CookGroup.manana]);
    });
  });

  group('CookTarget', () {
    test('carries a targetDay, slot and group', () {
      const target = (
        targetDay: DayOfWeek.lun,
        slot: MealSlot.cena,
        group: CookGroup.hoy,
      );

      expect(target.targetDay, DayOfWeek.lun);
      expect(target.slot, MealSlot.cena);
      expect(target.group, CookGroup.hoy);
    });
  });
}
