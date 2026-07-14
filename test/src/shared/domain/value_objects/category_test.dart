import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';

void main() {
  group('Category', () {
    test('should expose exactly the eight pantry categories', () {
      // Act & Assert
      expect(Category.values, [
        Category.proteina,
        Category.vegetal,
        Category.fruta,
        Category.cereal,
        Category.lacteo,
        Category.condimento,
        Category.semilla,
        Category.otro,
      ]);
    });

    group('label', () {
      test('should render the Spanish label for each category', () {
        // Act & Assert
        expect(Category.proteina.label, 'Proteína');
        expect(Category.vegetal.label, 'Vegetal');
        expect(Category.fruta.label, 'Fruta');
        expect(Category.cereal.label, 'Cereal');
        expect(Category.lacteo.label, 'Lácteo');
        expect(Category.condimento.label, 'Condimento');
        expect(Category.semilla.label, 'Semilla');
        expect(Category.otro.label, 'Otro');
      });
    });
  });
}
