import 'package:dartz/dartz.dart' hide Unit;
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/entities/pantry_item.dart';
import 'package:menuario/src/shared/domain/entities/recipe.dart';
import 'package:menuario/src/shared/domain/entities/week_plan.dart';
import 'package:menuario/src/shared/domain/services/measurement_converter.dart';
import 'package:menuario/src/shared/domain/services/stock_lens_service.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_mode.dart';
import 'package:menuario/src/shared/domain/value_objects/need_type.dart';
import 'package:menuario/src/shared/domain/value_objects/presentation.dart';
import 'package:menuario/src/shared/domain/value_objects/purchase_quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

/// Pure and dependency-free — safe to hold as a single const instance, same
/// as [MeasurementConverter].
const _lensService = StockLensService();

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
  ///
  /// Quantity-less ("al gusto") BOM lines are skipped: they contribute
  /// nothing, and an ingredient whose every line is quantity-less reports
  /// `Right(0)` rather than a [Failure].
  Either<Failure, Quantity> weeklyConsumption({
    required Ingredient ingredient,
    required List<Recipe> recipes,
    required WeekPlan weekPlan,
  }) {
    final defaultUnit = _lensService.canonicalUnitFor(ingredient);
    Unit resultUnit = defaultUnit;
    num total = 0;

    for (final recipe in recipes) {
      final timesPlanned = weekPlan.entries
          .where((entry) => entry.recipeId == recipe.id)
          .length;
      if (timesPlanned == 0) continue;

      for (final line in recipe.bomLines) {
        if (line.ingredientId != ingredient.id) continue;

        // An "al gusto" line carries no number: it is skipped outright, not
        // treated as a zero need. Surfacing it is the pantry's `haveIt`
        // job, never this numeric sum's.
        final recipeQuantity = line.quantity;
        if (recipeQuantity == null) continue;

        final converted = _converter.toStockUnit(
          recipeQuantity: recipeQuantity,
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

  /// Computes the weekly need for [ingredient] according to its
  /// [Ingredient.needType]:
  /// - [NeedType.recipeDriven] (default) delegates straight to
  ///   [weeklyConsumption] — the sum of planned-recipe consumption,
  ///   unchanged.
  /// - [NeedType.weeklyFixed] short-circuits to exactly 1 whole package in
  ///   the ingredient's canonical stock unit ("comprás uno, dura la
  ///   semana") — it never calls [MeasurementConverter.toStockUnit], so it
  ///   needs no [Ingredient.conversionFactor] and can never return
  ///   `Left(missingConversionFactor)`.
  ///
  /// [NeedType.optional] ingredients must never reach this method —
  /// callers (`weeklyConsumptionByIngredientProvider`) exclude them
  /// upstream, since they are excluded from the weekly budget entirely.
  Either<Failure, Quantity> weeklyNeed({
    required Ingredient ingredient,
    required List<Recipe> recipes,
    required WeekPlan weekPlan,
  }) {
    if (ingredient.needType == NeedType.weeklyFixed) {
      return Right(_oneWeeklyPackage(ingredient));
    }
    return weeklyConsumption(
      ingredient: ingredient,
      recipes: recipes,
      weekPlan: weekPlan,
    );
  }

  /// "1 whole package" for [ingredient], in its canonical stock unit: for
  /// `packageBase`, the package's own `effectiveYieldQty` (the DERIVED
  /// total, never the raw `yieldQty`) expressed in its base dimension
  /// (e.g. leche bolsa=1 L -> 1 L); for every other mode, a bare
  /// `1` in the canonical unit (`packageAbstract` -> 1 'paq', `count` -> 1
  /// unit, `mass` -> 1 g as a defensive fallback — `weeklyFixed` is not
  /// expected on mass-mode ingredients in practice).
  Quantity _oneWeeklyPackage(Ingredient ingredient) {
    final unit = _lensService.canonicalUnitFor(ingredient);
    final value = ingredient.measurementMode == MeasurementMode.packageBase
        ? (ingredient.package?.effectiveYieldQty ?? 1)
        : 1;
    return Quantity(value: value, unit: unit);
  }

  /// The positive shortfall between [consumption] and [stock], never
  /// negative. Returns `Left(Failure.negativeStock)` when [stock] itself
  /// is invalid (below zero), and `Left(Failure.unitMismatch)` when
  /// [consumption] and [stock] are expressed in different units — mixing
  /// them would silently miscompute the shortfall.
  Either<Failure, Quantity> shortfall({
    required Ingredient ingredient,
    required Quantity consumption,
    required Quantity stock,
  }) {
    if (stock.value < 0) {
      return Left(Failure.negativeStock(ingredient.name));
    }
    if (consumption.unit != stock.unit) {
      return Left(
        Failure.unitMismatch(
          ingredientName: ingredient.name,
          consumptionUnit: consumption.unit.symbol,
          stockUnit: stock.unit.symbol,
        ),
      );
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
