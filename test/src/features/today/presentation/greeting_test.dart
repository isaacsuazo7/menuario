import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/today/presentation/greeting.dart';

void main() {
  group('firstNameFrom', () {
    test('returns the first word of a multi-word display name', () {
      expect(firstNameFrom('Isaac Suazo'), 'Isaac');
    });

    test('returns the whole name when it is a single word', () {
      expect(firstNameFrom('Isaac'), 'Isaac');
    });

    test('returns an empty string when displayName is null', () {
      expect(firstNameFrom(null), '');
    });

    test('returns an empty string when displayName is empty', () {
      expect(firstNameFrom(''), '');
    });

    test('returns an empty string when displayName is only whitespace', () {
      expect(firstNameFrom('   '), '');
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
