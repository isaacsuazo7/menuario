import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/services/coverage_calculator.dart';
import 'package:menuario/src/shared/domain/value_objects/coverage_status.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  const calculator = CoverageCalculator();
  const taza = Unit(symbol: 'taza', dimension: UnitDimension.volume);

  group('CoverageCalculator.statusFor', () {
    test('stock at or above need -> cubierto (400 g stock, 340 g need)', () {
      final status = calculator.statusFor(
        weeklyNeed: const Right(Quantity(value: 340, unit: Unit.gram)),
        stock: const Quantity(value: 400, unit: Unit.gram),
        isEffectivelyZero: false,
      );

      expect(status, CoverageStatus.cubierto);
    });

    test('stock exactly equal to need -> cubierto (boundary)', () {
      final status = calculator.statusFor(
        weeklyNeed: const Right(Quantity(value: 340, unit: Unit.gram)),
        stock: const Quantity(value: 340, unit: Unit.gram),
        isEffectivelyZero: false,
      );

      expect(status, CoverageStatus.cubierto);
    });

    test('nonzero stock below need, not effectively zero -> justo '
        '(170 g stock, 340 g need)', () {
      final status = calculator.statusFor(
        weeklyNeed: const Right(Quantity(value: 340, unit: Unit.gram)),
        stock: const Quantity(value: 170, unit: Unit.gram),
        isEffectivelyZero: false,
      );

      expect(status, CoverageStatus.justo);
    });

    test('effectively-zero stock with a real need -> falta '
        '(0 g stock, 340 g need)', () {
      final status = calculator.statusFor(
        weeklyNeed: const Right(Quantity(value: 340, unit: Unit.gram)),
        stock: const Quantity(value: 0, unit: Unit.gram),
        isEffectivelyZero: true,
      );

      expect(status, CoverageStatus.falta);
    });

    test('a nonzero raw stock that rounds to zero at display precision '
        'still counts as falta (isEffectivelyZero wins over raw value)', () {
      final status = calculator.statusFor(
        weeklyNeed: const Right(Quantity(value: 340, unit: Unit.gram)),
        stock: const Quantity(value: 1, unit: Unit.gram),
        isEffectivelyZero: true,
      );

      expect(status, CoverageStatus.falta);
    });

    test('a negative stock value (should never happen) still falls back to '
        'falta rather than a bogus cubierto/justo split', () {
      final status = calculator.statusFor(
        weeklyNeed: const Right(Quantity(value: 340, unit: Unit.gram)),
        stock: const Quantity(value: -5, unit: Unit.gram),
        isEffectivelyZero: false,
      );

      expect(status, CoverageStatus.falta);
    });

    test('zero weekly need (not planned this week) -> neutral, never falta, '
        'regardless of stock', () {
      final status = calculator.statusFor(
        weeklyNeed: const Right(Quantity(value: 0, unit: Unit.gram)),
        stock: const Quantity(value: 0, unit: Unit.gram),
        isEffectivelyZero: true,
      );

      expect(status, CoverageStatus.neutral);
    });

    test('a null weeklyNeed (no data yet) -> neutral', () {
      final status = calculator.statusFor(
        weeklyNeed: null,
        stock: const Quantity(value: 170, unit: Unit.gram),
        isEffectivelyZero: false,
      );

      expect(status, CoverageStatus.neutral);
    });

    test('a Left weeklyNeed (skipped/needs-factor) -> neutral, no crash', () {
      final status = calculator.statusFor(
        weeklyNeed: Left(Failure.missingConversionFactor('Arroz')),
        stock: const Quantity(value: 170, unit: Unit.gram),
        isEffectivelyZero: false,
      );

      expect(status, CoverageStatus.neutral);
    });

    test('a unit mismatch between need and stock -> neutral, no bogus '
        'comparison across incompatible units', () {
      final status = calculator.statusFor(
        weeklyNeed: const Right(Quantity(value: 2, unit: taza)),
        stock: const Quantity(value: 170, unit: Unit.gram),
        isEffectivelyZero: false,
      );

      expect(status, CoverageStatus.neutral);
    });
  });
}
