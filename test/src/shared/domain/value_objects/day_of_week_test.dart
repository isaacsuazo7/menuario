import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/value_objects/day_of_week.dart';

void main() {
  group('DayOfWeek', () {
    test('should expose exactly Lun through Sáb (no Domingo)', () {
      // Act & Assert
      expect(DayOfWeek.values, [
        DayOfWeek.lun,
        DayOfWeek.mar,
        DayOfWeek.mie,
        DayOfWeek.jue,
        DayOfWeek.vie,
        DayOfWeek.sab,
      ]);
    });

    group('label', () {
      test('should render the Spanish short label for each day', () {
        // Act & Assert
        expect(DayOfWeek.lun.label, 'Lun');
        expect(DayOfWeek.mar.label, 'Mar');
        expect(DayOfWeek.mie.label, 'Mié');
        expect(DayOfWeek.jue.label, 'Jue');
        expect(DayOfWeek.vie.label, 'Vie');
        expect(DayOfWeek.sab.label, 'Sáb');
      });
    });

    group('fromLabel', () {
      test('should parse each valid label into its DayOfWeek', () {
        // Act & Assert
        expect(DayOfWeek.fromLabel('Lun'), const Right(DayOfWeek.lun));
        expect(DayOfWeek.fromLabel('Sáb'), const Right(DayOfWeek.sab));
      });

      test('should reject Domingo with an invalidDay Failure', () {
        // Act
        final result = DayOfWeek.fromLabel('Dom');

        // Assert
        expect(
          result,
          isA<Left<Failure, DayOfWeek>>().having(
            (left) => left.value.code,
            'code',
            'invalidDay',
          ),
        );
      });

      test('should reject an unknown label with an invalidDay Failure', () {
        // Act
        final result = DayOfWeek.fromLabel('Xyz');

        // Assert
        expect(
          result,
          isA<Left<Failure, DayOfWeek>>().having(
            (left) => left.value.code,
            'code',
            'invalidDay',
          ),
        );
      });
    });
  });
}
