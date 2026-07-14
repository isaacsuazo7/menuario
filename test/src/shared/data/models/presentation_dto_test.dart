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
}
