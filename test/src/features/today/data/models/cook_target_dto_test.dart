import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/today/data/models/cook_target_dto.dart';
import 'package:menuario/src/features/today/domain/value_objects/cook_target.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  group('CookTargetDTO', () {
    const dto = CookTargetDTO(
      weekday: DateTime.monday,
      targetDay: 'lun',
      slot: 'cena',
      group: 'hoy',
    );

    test('fromJson/toJson round-trips', () {
      final json = dto.toJson();
      final result = CookTargetDTO.fromJson(json);

      expect(result, dto);
    });

    test('fromEntity/toEntity round-trips using .name/.byName mapping', () {
      const weekday = DateTime.friday;
      const target = (
        targetDay: DayOfWeek.vie,
        slot: MealSlot.cena,
        group: CookGroup.hoy,
      );

      final result = CookTargetDTO.fromEntity(
        weekday: weekday,
        target: target,
      );

      expect(result.weekday, DateTime.friday);
      expect(result.targetDay, 'vie');
      expect(result.slot, 'cena');
      expect(result.group, 'hoy');
      expect(result.toEntity(), target);
    });
  });
}
