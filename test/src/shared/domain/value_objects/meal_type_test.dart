import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/value_objects/meal_type.dart';

void main() {
  group('MealType', () {
    test('should expose exactly the six recipe meal types, pregym first', () {
      // Act & Assert
      expect(MealType.values, [
        MealType.pregym,
        MealType.desayuno,
        MealType.almuerzo,
        MealType.merienda,
        MealType.cena,
        MealType.aderezo,
      ]);
    });

    group('label', () {
      test('should render the Spanish label for each meal type', () {
        // Act & Assert
        expect(MealType.pregym.label, 'Pre-gym');
        expect(MealType.desayuno.label, 'Desayuno');
        expect(MealType.almuerzo.label, 'Almuerzo');
        expect(MealType.merienda.label, 'Merienda');
        expect(MealType.cena.label, 'Cena');
        expect(MealType.aderezo.label, 'Aderezo');
      });
    });

    group('wire', () {
      test('should render the lowercase wire string for each meal type', () {
        // Act & Assert
        expect(MealType.pregym.wire, 'pregym');
        expect(MealType.desayuno.wire, 'desayuno');
        expect(MealType.almuerzo.wire, 'almuerzo');
        expect(MealType.merienda.wire, 'merienda');
        expect(MealType.cena.wire, 'cena');
        expect(MealType.aderezo.wire, 'aderezo');
      });
    });

    group('fromWire', () {
      test('should map every valid wire string to its meal type', () {
        // Act & Assert
        expect(MealType.fromWire('pregym'), MealType.pregym);
        expect(MealType.fromWire('desayuno'), MealType.desayuno);
        expect(MealType.fromWire('almuerzo'), MealType.almuerzo);
        expect(MealType.fromWire('merienda'), MealType.merienda);
        expect(MealType.fromWire('cena'), MealType.cena);
        expect(MealType.fromWire('aderezo'), MealType.aderezo);
      });

      test('should return null for an unknown wire string', () {
        // Act & Assert
        expect(MealType.fromWire('desconocido'), isNull);
      });

      test('should return null for a null wire string', () {
        // Act & Assert
        expect(MealType.fromWire(null), isNull);
      });
    });
  });
}
