import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/data/models/package_spec_dto.dart';
import 'package:menuario/src/shared/domain/value_objects/package_spec.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  group('PackageSpecDTO round-trip', () {
    test('a packageBase spec (leche bolsa=1L) survives '
        'fromEntity->toJson->fromJson->toEntity', () {
      // Arrange
      const entity = PackageSpec(
        label: 'bolsa',
        yieldQty: 1,
        baseDimension: Unit.liter,
      );

      // Act
      final json = PackageSpecDTO.fromEntity(entity).toJson();
      final result = PackageSpecDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
      expect(json['label'], 'bolsa');
      expect(json['yieldQty'], 1);
      expect(json['baseDimensionSymbol'], 'L');
      expect(json['baseDimensionKind'], 'volume');
    });

    test('a packageAbstract spec (lechuga bolsa) with no base dimension '
        'survives fromEntity->toJson->fromJson->toEntity', () {
      // Arrange
      const entity = PackageSpec(label: 'bolsa');

      // Act
      final json = PackageSpecDTO.fromEntity(entity).toJson();
      final result = PackageSpecDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
      expect(json['yieldQty'], isNull);
      expect(json['baseDimensionSymbol'], isNull);
      expect(json['baseDimensionKind'], isNull);
    });
  });
}
