import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/week/presentation/providers/meal_slot_mapping.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  test('pregym slot maps to pregym meal type', () {
    expect(mealTypeForSlot(MealSlot.pregym), MealType.pregym);
  });

  test('desayuno slot maps to desayuno meal type', () {
    expect(mealTypeForSlot(MealSlot.desayuno), MealType.desayuno);
  });

  test('almuerzo slot maps to almuerzo meal type', () {
    expect(mealTypeForSlot(MealSlot.almuerzo), MealType.almuerzo);
  });

  test('merienda slot maps to merienda meal type', () {
    expect(mealTypeForSlot(MealSlot.merienda), MealType.merienda);
  });

  test('cena slot maps to cena meal type', () {
    expect(mealTypeForSlot(MealSlot.cena), MealType.cena);
  });

  test('no MealSlot ever maps to MealType.aderezo', () {
    for (final slot in MealSlot.values) {
      expect(mealTypeForSlot(slot), isNot(MealType.aderezo));
    }
  });
}
