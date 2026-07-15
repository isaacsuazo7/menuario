import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/week/presentation/providers/today_provider.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  group('dayOfWeekFromWeekday', () {
    test('maps Mon-Sat (1..6) to their DayOfWeek', () {
      expect(dayOfWeekFromWeekday(DateTime.monday), DayOfWeek.lun);
      expect(dayOfWeekFromWeekday(DateTime.tuesday), DayOfWeek.mar);
      expect(dayOfWeekFromWeekday(DateTime.wednesday), DayOfWeek.mie);
      expect(dayOfWeekFromWeekday(DateTime.thursday), DayOfWeek.jue);
      expect(dayOfWeekFromWeekday(DateTime.friday), DayOfWeek.vie);
      expect(dayOfWeekFromWeekday(DateTime.saturday), DayOfWeek.sab);
    });

    test('maps Sunday (7) to null — Domingo is excluded from the plan', () {
      expect(dayOfWeekFromWeekday(DateTime.sunday), isNull);
    });
  });
}
