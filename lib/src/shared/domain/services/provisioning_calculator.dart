import 'package:dartz/dartz.dart' hide Unit;
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/entities/pantry_item.dart';
import 'package:menuario/src/shared/domain/entities/recipe.dart';
import 'package:menuario/src/shared/domain/entities/week_plan.dart';
import 'package:menuario/src/shared/domain/services/measurement_converter.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_kind.dart';
import 'package:menuario/src/shared/domain/value_objects/presentation.dart';
import 'package:menuario/src/shared/domain/value_objects/purchase_quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

/// Computes weekly consumption, shortfall and purchase quantities for
/// quantity-tracked ingredients, and decides which boolean-tracked
/// ingredients belong on the buy list.
///
/// Pure and dependency-free besides [MeasurementConverter] (constructor
/// injected, no Flutter/Riverpod). Boolean-tracked ingredients are
/// structurally excluded from the numeric math: callers route them
/// through [shouldSurfaceBooleanItem] instead of [weeklyConsumption].
class ProvisioningCalculator {
  ProvisioningCalculator({required MeasurementConverter converter})
    // ignore: prefer_initializing_formals
    : _converter = converter;

  final MeasurementConverter _converter;

  /// The weekly stock-unit consumption of [ingredient]: the sum, over
  /// every [Recipe] in [recipes], of each matching `BomLine` quantity
  /// (converted to stock unit) multiplied by how many times that recipe
  /// appears in [weekPlan].
  Either<Failure, Quantity> weeklyConsumption({
    required Ingredient ingredient,
    required List<Recipe> recipes,
    required WeekPlan weekPlan,
  }) {
    final defaultUnit = ingredient.measurementKind == MeasurementKind.unit
        ? Unit.count
        : Unit.gram;
    Unit resultUnit = defaultUnit;
    num total = 0;

    for (final recipe in recipes) {
      final timesPlanned = weekPlan.entries
          .where((entry) => entry.recipeId == recipe.id)
          .length;
      if (timesPlanned == 0) continue;

      for (final line in recipe.bomLines) {
        if (line.ingredientId != ingredient.id) continue;

        final converted = _converter.toStockUnit(
          recipeQuantity: line.quantity,
          ingredient: ingredient,
        );
        if (converted is Left<Failure, Quantity>) {
          return converted;
        }

        final stockQuantity = (converted as Right<Failure, Quantity>).value;
        resultUnit = stockQuantity.unit;
        total += stockQuantity.value * timesPlanned;
      }
    }

    return Right(Quantity(value: total, unit: resultUnit));
  }

  /// The positive shortfall between [consumption] and [stock], never
  /// negative. Returns `Left(Failure.negativeStock)` when [stock] itself
  /// is invalid (below zero).
  Either<Failure, Quantity> shortfall({
    required Ingredient ingredient,
    required Quantity consumption,
    required Quantity stock,
  }) {
    if (stock.value < 0) {
      return Left(Failure.negativeStock(ingredient.name));
    }

    final diff = consumption.value - stock.value;
    return Right(Quantity(value: diff > 0 ? diff : 0, unit: consumption.unit));
  }

  /// Translates a positive [shortfall] into a [PurchaseQuantity] via
  /// [presentation]. Returns `Right(null)` when there is nothing to buy.
  Either<Failure, PurchaseQuantity?> purchaseQuantity({
    required Quantity shortfall,
    required Presentation presentation,
  }) {
    if (shortfall.value <= 0) {
      return const Right(null);
    }

    return _converter.toPurchaseQuantity(
      stockShortfall: shortfall,
      presentation: presentation,
    );
  }

  /// Whether a boolean-tracked [pantryItem] belongs on the buy list: only
  /// "no tengo" (`haveIt == false`) items are surfaced, without a
  /// quantity. "tengo" items are omitted. Quantity-tracked items are
  /// never surfaced through this path — they go through the numeric
  /// [weeklyConsumption]/[shortfall]/[purchaseQuantity] pipeline instead.
  bool shouldSurfaceBooleanItem(PantryItem pantryItem) {
    return switch (pantryItem) {
      BooleanTrackedPantryItem(:final haveIt) => !haveIt,
      QuantityTrackedPantryItem() => false,
    };
  }
}
