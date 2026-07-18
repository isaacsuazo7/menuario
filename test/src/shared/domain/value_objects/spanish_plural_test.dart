import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/value_objects/spanish_plural.dart';

void main() {
  group('pluralizeEs', () {
    group('count', () {
      test('leaves the word untouched for exactly one', () {
        expect(pluralizeEs('unidad', 1), 'unidad');
        expect(pluralizeEs('bolsa', 1), 'bolsa');
      });

      test('pluralizes zero, per Spanish usage ("0 unidades")', () {
        expect(pluralizeEs('unidad', 0), 'unidades');
        expect(pluralizeEs('bolsa', 0), 'bolsas');
      });

      test('pluralizes a decimal count that is not exactly one', () {
        expect(pluralizeEs('bolsa', 3.5), 'bolsas');
        expect(pluralizeEs('bolsa', 1.0), 'bolsa');
      });
    });

    group('vowel endings', () {
      test('appends s after an unaccented vowel', () {
        expect(pluralizeEs('bolsa', 3), 'bolsas');
        expect(pluralizeEs('caja', 3), 'cajas');
        expect(pluralizeEs('paquete', 3), 'paquetes');
        expect(pluralizeEs('bote', 2), 'botes');
        expect(pluralizeEs('panita', 2), 'panitas');
      });
    });

    group('consonant endings', () {
      test('appends es after a consonant', () {
        expect(pluralizeEs('unidad', 3), 'unidades');
        expect(pluralizeEs('pack', 3), 'packes');
      });

      test('turns a final z into ces', () {
        expect(pluralizeEs('nuez', 3), 'nueces');
        expect(pluralizeEs('lapiz', 2), 'lapices');
      });

      test('drops the written accent on a stressed final syllable', () {
        // "cartón" -> "cartones", no "cartónes".
        expect(pluralizeEs('cartón', 3), 'cartones');
        expect(pluralizeEs('almidón', 2), 'almidones');
      });
    });

    group('casing', () {
      test('inspects the last letter case-insensitively without '
          'altering the original casing', () {
        expect(pluralizeEs('Bolsa', 3), 'Bolsas');
        expect(pluralizeEs('BOLSA', 3), 'BOLSAs');
        expect(pluralizeEs('Unidad', 3), 'Unidades');
        expect(pluralizeEs('NUEZ', 3), 'NUEces');
      });
    });

    group('compound labels (real seed data)', () {
      test('pluralizes only the head noun, keeping the qualifier intact', () {
        // Los labels reales traen la medida pegada: "bolsa 1 L".
        expect(pluralizeEs('bolsa 1 L', 3), 'bolsas 1 L');
        expect(pluralizeEs('bolsa 1 lb', 2), 'bolsas 1 lb');
        expect(pluralizeEs('bolsa 13 u', 4), 'bolsas 13 u');
        expect(pluralizeEs('pana 500 g', 2), 'panas 500 g');
        expect(pluralizeEs('panita 125 g', 3), 'panitas 125 g');
      });

      test('leaves a compound label untouched for a single pack', () {
        expect(pluralizeEs('bolsa 1 L', 1), 'bolsa 1 L');
      });
    });

    group('degenerate input', () {
      test('returns an empty word unchanged', () {
        expect(pluralizeEs('', 3), '');
      });

      test('returns a whitespace-only word unchanged', () {
        expect(pluralizeEs('   ', 3), '   ');
      });
    });
  });
}
