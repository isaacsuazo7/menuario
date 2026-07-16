import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_mode.dart';

void main() {
  group('MeasurementMode', () {
    test('exposes exactly five values: mass, count, packageBase, '
        'packageAbstract, boolean', () {
      // Act & Assert
      expect(MeasurementMode.values, hasLength(5));
      expect(MeasurementMode.values, contains(MeasurementMode.mass));
      expect(MeasurementMode.values, contains(MeasurementMode.count));
      expect(MeasurementMode.values, contains(MeasurementMode.packageBase));
      expect(
        MeasurementMode.values,
        contains(MeasurementMode.packageAbstract),
      );
      expect(MeasurementMode.values, contains(MeasurementMode.boolean));
    });

    test('the same value is equal to itself', () {
      // Act & Assert
      expect(MeasurementMode.mass, MeasurementMode.mass);
      expect(MeasurementMode.mass, isNot(MeasurementMode.count));
    });
  });
}
