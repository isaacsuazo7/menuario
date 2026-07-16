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

  group('greetingNameFrom', () {
    test('prefers the display name over the email', () {
      expect(
        greetingNameFrom(displayName: 'Isaac Suazo', email: 'other@x.com'),
        'Isaac',
      );
    });

    test('falls back to the capitalized email local-part token', () {
      expect(
        greetingNameFrom(displayName: null, email: 'isaac.suazo@x.com'),
        'Isaac',
      );
    });

    test('strips the domain from the email', () {
      expect(greetingNameFrom(email: 'bob@example.com'), 'Bob');
    });

    test('splits the local part on "_" and takes the first token', () {
      expect(greetingNameFrom(email: 'john_doe@x.com'), 'John');
    });

    test('splits the local part on "+" and takes the first token', () {
      expect(greetingNameFrom(email: 'jane+promos@x.com'), 'Jane');
    });

    test('keeps a hyphen as part of the name (does not split on "-")', () {
      expect(greetingNameFrom(email: 'dev-claude@cit.hn'), 'Dev-claude');
    });

    test('lowercases the tail when capitalizing an ALL-CAPS local part', () {
      expect(greetingNameFrom(email: 'ISAAC@x.com'), 'Isaac');
    });

    test('falls through a whitespace-only display name to the email', () {
      expect(greetingNameFrom(displayName: '   ', email: 'bob@x.com'), 'Bob');
    });

    test('returns empty when both display name and email are null', () {
      expect(greetingNameFrom(displayName: null, email: null), '');
    });

    test('returns empty when both display name and email are empty', () {
      expect(greetingNameFrom(displayName: '', email: ''), '');
    });

    test('returns empty when the email has an empty local part', () {
      expect(greetingNameFrom(email: '@x.com'), '');
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
