import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/data/models/presentation_dto.dart';
import 'package:menuario/src/shared/domain/value_objects/presentation.dart';

void main() {
  group('PresentationDTO round-trip', () {
    test('loose survives fromEntity->toJson->fromJson->toEntity', () {
      // Arrange
      const entity = Presentation.loose();

      // Act
      final json = PresentationDTO.fromEntity(entity).toJson();
      final result = PresentationDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
      expect(json['type'], 'loose');
    });

    test('package survives fromEntity->toJson->fromJson->toEntity', () {
      // Arrange
      const entity = Presentation.package(yieldQty: 454, label: 'bolsa');

      // Act
      final json = PresentationDTO.fromEntity(entity).toJson();
      final result = PresentationDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
      expect(json['type'], 'package');
      expect(json['yieldQty'], 454);
      expect(json['label'], 'bolsa');
    });

    test('counter survives fromEntity->toJson->fromJson->toEntity', () {
      // Arrange
      const entity = Presentation.counter();

      // Act
      final json = PresentationDTO.fromEntity(entity).toJson();
      final result = PresentationDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
      expect(json['type'], 'counter');
    });
  });

  group('PresentationDTO back-compat null-yieldQty read (no crash)', () {
    test('a package doc with a null yieldQty no longer force-unwrap-crashes '
        '(espinaca/escarola/galletas-marias/fresas crash case)', () {
      // Arrange
      const dto = PresentationDTO(type: 'package', label: 'bolsa');

      // Act
      final result = dto.toEntity();

      // Assert
      expect(result, const Presentation.package(yieldQty: 1, label: 'bolsa'));
    });

    test('a package doc with both yieldQty and label null no longer '
        'force-unwrap-crashes', () {
      // Arrange
      const dto = PresentationDTO(type: 'package');

      // Act
      final result = dto.toEntity();

      // Assert
      expect(result, const Presentation.package(yieldQty: 1, label: 'paquete'));
    });
  });
}
