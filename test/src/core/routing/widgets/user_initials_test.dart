import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/routing/widgets/user_initials.dart';

void main() {
  group('userInitials', () {
    test('takes the first letter of the first two words, uppercased', () {
      expect(userInitials(displayName: 'Isaac Suazo', email: null), 'IS');
    });

    test('caps at two letters for names with more than two words', () {
      expect(userInitials(displayName: 'Ana María Pérez', email: null), 'AM');
    });

    test('returns a single letter for a one-word name', () {
      expect(userInitials(displayName: 'Isaac', email: null), 'I');
    });

    test('collapses extra whitespace between words', () {
      expect(userInitials(displayName: '  Isaac   Suazo ', email: null), 'IS');
    });

    test('falls back to the email first letter when the name is null', () {
      expect(userInitials(displayName: null, email: 'dev@cit.hn'), 'D');
    });

    test('falls back to the email first letter when the name is blank', () {
      expect(userInitials(displayName: '   ', email: 'dev@cit.hn'), 'D');
    });

    test('returns a safe placeholder when both name and email are empty', () {
      expect(userInitials(displayName: null, email: null), '?');
      expect(userInitials(displayName: '', email: ''), '?');
    });
  });
}
