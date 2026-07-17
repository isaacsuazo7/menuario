import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/value_objects/meal_slot.dart';

void main() {
  group('MealSlot', () {
    test('should expose exactly the five daily meal slots, pregym first', () {
      // Act & Assert
      expect(MealSlot.values, [
        MealSlot.pregym,
        MealSlot.desayuno,
        MealSlot.almuerzo,
        MealSlot.merienda,
        MealSlot.cena,
      ]);
    });

    group('label', () {
      test('should render the Spanish label for each slot', () {
        // Act & Assert
        expect(MealSlot.pregym.label, 'Pre-gym');
        expect(MealSlot.desayuno.label, 'Desayuno');
        expect(MealSlot.almuerzo.label, 'Almuerzo');
        expect(MealSlot.merienda.label, 'Merienda');
        expect(MealSlot.cena.label, 'Cena');
      });
    });
  });
}
