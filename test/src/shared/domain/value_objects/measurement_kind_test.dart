import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_kind.dart';

void main() {
  group('MeasurementKind', () {
    test('should expose exactly unit and bulk values', () {
      // Act & Assert
      expect(MeasurementKind.values, [
        MeasurementKind.unit,
        MeasurementKind.bulk,
      ]);
    });
  });
}
