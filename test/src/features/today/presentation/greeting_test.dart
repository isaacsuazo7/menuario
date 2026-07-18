import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/today/presentation/greeting.dart';

void main() {
  group('greetingFor', () {
    test('19:00 through 04:59 is the night greeting', () {
      expect(greetingFor(DateTime(2024, 1, 1, 19)).label, 'Buenas noches');
      expect(greetingFor(DateTime(2024, 1, 1, 23, 59)).label, 'Buenas noches');
      expect(greetingFor(DateTime(2024, 1, 1)).label, 'Buenas noches');
      expect(greetingFor(DateTime(2024, 1, 1, 4, 59)).label, 'Buenas noches');
    });

    test('05:00 through 11:59 is the morning greeting', () {
      expect(greetingFor(DateTime(2024, 1, 1, 5)).label, 'Buenos días');
      expect(greetingFor(DateTime(2024, 1, 1, 11, 59)).label, 'Buenos días');
    });

    test('12:00 through 18:59 is the afternoon greeting', () {
      expect(greetingFor(DateTime(2024, 1, 1, 12)).label, 'Buenas tardes');
      expect(greetingFor(DateTime(2024, 1, 1, 18, 59)).label, 'Buenas tardes');
    });

    test('each period carries its own Material icon', () {
      expect(
        greetingFor(DateTime(2024, 1, 1, 9)).icon,
        Icons.wb_sunny_outlined,
      );
      expect(
        greetingFor(DateTime(2024, 1, 1, 15)).icon,
        Icons.wb_twilight_outlined,
      );
      expect(
        greetingFor(DateTime(2024, 1, 1, 21)).icon,
        Icons.dark_mode_outlined,
      );
    });

    test('midnight is night, not morning', () {
      final midnight = greetingFor(DateTime(2024, 1, 1));
      expect(midnight.label, 'Buenas noches');
      expect(midnight.icon, Icons.dark_mode_outlined);
    });
  });

  group('spanishLongDate', () {
    test('formats a Monday with the Spanish weekday and month', () {
      expect(spanishLongDate(DateTime(2024, 1, 1)), 'Lunes 1 de enero');
    });

    test('formats a Wednesday with an accented weekday', () {
      expect(spanishLongDate(DateTime(2024, 1, 3)), 'Miércoles 3 de enero');
    });

    test('formats a Saturday with an accented weekday', () {
      expect(spanishLongDate(DateTime(2024, 1, 6)), 'Sábado 6 de enero');
    });

    test('formats a Sunday in December', () {
      expect(
        spanishLongDate(DateTime(2024, 12, 15)),
        'Domingo 15 de diciembre',
      );
    });
  });
}
