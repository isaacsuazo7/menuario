import 'package:dartz/dartz.dart' hide Unit;
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/value_objects/coverage_status.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';

/// Derives a [CoverageStatus] from a weekly need, current stock and the
/// mode-aware effective-zero flag ([StockLensService.isEffectivelyZero]).
///
/// Pure and dependency-free — no repositories, no Flutter. The single
/// source of truth for the Despensa row's tri-state coverage tint,
/// superseding the old binary effective-zero tile tint.
class CoverageCalculator {
  const CoverageCalculator();

  /// Classifies coverage for one quantity-tracked ingredient.
  ///
  /// [weeklyNeed] is `null` when no weekly-consumption data is available
  /// yet, `Left(Failure)` when its calculation was skipped (e.g. a missing
  /// `conversionFactor`), or `Right(Quantity)` with the computed need.
  ///
  /// Returns [CoverageStatus.neutral] whenever there is no trustworthy
  /// need signal — `null`/`Left`, a zero-or-negative need (not planned
  /// this week), or a need expressed in a different [Quantity.unit] than
  /// [stock] (never reached in practice once both flow through
  /// `StockLensService.canonicalUnitFor`, but guarded defensively rather
  /// than silently mis-comparing).
  ///
  /// Otherwise: [isEffectivelyZero] (or a non-positive raw [stock] value)
  /// wins as [CoverageStatus.falta] regardless of the numeric gap;
  /// `stock >= need` is [CoverageStatus.cubierto]; anything in between is
  /// [CoverageStatus.justo].
  CoverageStatus statusFor({
    required Either<Failure, Quantity>? weeklyNeed,
    required Quantity stock,
    required bool isEffectivelyZero,
  }) {
    if (weeklyNeed is! Right<Failure, Quantity>) {
      return CoverageStatus.neutral;
    }
    final need = weeklyNeed.value;
    if (need.value <= 0) {
      return CoverageStatus.neutral;
    }
    if (need.unit != stock.unit) {
      return CoverageStatus.neutral;
    }

    if (isEffectivelyZero || stock.value <= 0) {
      return CoverageStatus.falta;
    }
    if (stock.value >= need.value) {
      return CoverageStatus.cubierto;
    }
    return CoverageStatus.justo;
  }
}
