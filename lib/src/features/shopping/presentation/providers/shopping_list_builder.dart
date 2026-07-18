import 'package:dartz/dartz.dart' hide Unit;
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/shopping/presentation/models/shopping_row.dart';
import 'package:menuario/src/shared/shared.dart';

/// Pure, Flutter-free derivation of the Comprar buy list from the shared
/// weekly-consumption map, pantry and ingredient data, via
/// [ProvisioningCalculator].
///
/// No mutations, no Riverpod — the derived provider that watches the
/// upstream `AsyncValue`s is the only Flutter-aware layer; this class is
/// unit-testable with plain fixtures, mirroring [ProvisioningCalculator]
/// itself. The plan+recipe join that produces
/// [ShoppingBuyList]'s per-ingredient demand lives in exactly ONE place —
/// `weeklyConsumptionByIngredientProvider` — this builder only consumes
/// its result, it never re-derives it.
class ShoppingListBuilder {
  const ShoppingListBuilder({required ProvisioningCalculator calculator})
    // ignore: prefer_initializing_formals
    : _calculator = calculator;

  final ProvisioningCalculator _calculator;

  /// Derives the [ShoppingBuyList] from [weeklyConsumptionByIngredient]
  /// (the shared weekly-need join's result) against [ingredientsById] and
  /// [pantryByIngredientId].
  ///
  /// Quantity-tracked rows are gathered directly from
  /// [weeklyConsumptionByIngredient]'s keys (see the Assume-Zero Anchor
  /// Rule for ingredients with no matching [pantryByIngredientId] entry).
  /// Boolean-tracked ingredients are gathered directly from
  /// [pantryByIngredientId] via
  /// [ProvisioningCalculator.shouldSurfaceBooleanItem] — independent of
  /// whether they appear in [weeklyConsumptionByIngredient].
  ///
  /// A `Left(Failure)` consumption entry for one ingredient skips only
  /// that row, recorded in [ShoppingBuyList.skipped], and continues with
  /// the rest.
  ShoppingBuyList build({
    required Map<String, Either<Failure, Quantity>>
    weeklyConsumptionByIngredient,
    required Map<String, Ingredient> ingredientsById,
    required Map<String, PantryItem> pantryByIngredientId,
  }) {
    final rows = <ShoppingRow>[];
    final skipped = <SkippedItem>[];

    for (final entry in weeklyConsumptionByIngredient.entries) {
      final ingredientId = entry.key;
      final ingredient = ingredientsById[ingredientId];
      if (ingredient == null) continue;

      final result = _buildQuantityRow(
        ingredientId: ingredientId,
        ingredient: ingredient,
        consumptionResult: entry.value,
        pantryByIngredientId: pantryByIngredientId,
      );
      if (result case Left(value: final failure)) {
        skipped.add(
          SkippedItem(
            name: ingredient.name,
            reason: failure.code == 'missingConversionFactor'
                ? SkipReason.needsFactor
                : SkipReason.other,
          ),
        );
        continue;
      }
      final row = (result as Right<Failure, ShoppingRow?>).value;
      if (row != null && row.quantityDisplay != null) {
        rows.add(row);
      }
    }

    for (final entry in pantryByIngredientId.entries) {
      final item = entry.value;
      if (item is! BooleanTrackedPantryItem) continue;
      if (!_calculator.shouldSurfaceBooleanItem(item)) continue;

      final ingredient = ingredientsById[entry.key];
      if (ingredient == null) continue;

      rows.add(
        ShoppingRow(
          ingredientId: entry.key,
          ingredient: ingredient,
          category: ingredient.category,
          isBooleanTracked: true,
          pantryItem: item,
          pantryExists: true,
        ),
      );
    }

    final groups = [
      for (final category in Category.values)
        if (rows.where((row) => row.category == category).toList()
            case final categoryRows when categoryRows.isNotEmpty)
          ShoppingCategoryGroup(category: category, rows: categoryRows),
    ];

    return ShoppingBuyList(groups: groups, skipped: skipped);
  }

  /// Computes the quantity-tracked row for [ingredientId], propagating the
  /// typed `Left(Failure)` (caller records it as a named [SkippedItem])
  /// when any pipeline step fails. A `Right(row)` with a `null`
  /// [ShoppingRow.quantityDisplay] means there is nothing to buy
  /// (`purchaseQuantity` returned `Right(null)`) and the caller omits it.
  Either<Failure, ShoppingRow?> _buildQuantityRow({
    required String ingredientId,
    required Ingredient ingredient,
    required Either<Failure, Quantity> consumptionResult,
    required Map<String, PantryItem> pantryByIngredientId,
  }) {
    if (consumptionResult case Left(value: final failure)) {
      return Left(failure);
    }
    final consumption = (consumptionResult as Right<Failure, Quantity>).value;

    final existing = pantryByIngredientId[ingredientId];
    final QuantityTrackedPantryItem pantryItem;
    final bool pantryExists;
    if (existing is QuantityTrackedPantryItem) {
      pantryItem = existing;
      pantryExists = true;
    } else {
      pantryItem = QuantityTrackedPantryItem(
        ingredientId: ingredientId,
        category: ingredient.category,
        stock: Quantity(value: 0, unit: consumption.unit),
      );
      pantryExists = false;
    }

    final shortfallResult = _calculator.shortfall(
      ingredient: ingredient,
      consumption: consumption,
      stock: pantryItem.stock,
    );
    if (shortfallResult case Left(value: final failure)) {
      return Left(failure);
    }
    final shortfall = (shortfallResult as Right<Failure, Quantity>).value;

    final purchaseResult = _calculator.purchaseQuantity(
      shortfall: shortfall,
      presentation: presentationForPurchase(ingredient),
    );
    if (purchaseResult case Left(value: final failure)) {
      return Left(failure);
    }
    final purchase =
        (purchaseResult as Right<Failure, PurchaseQuantity?>).value;

    return Right(
      ShoppingRow(
        ingredientId: ingredientId,
        ingredient: ingredient,
        category: ingredient.category,
        isBooleanTracked: false,
        pantryItem: pantryItem,
        pantryExists: pantryExists,
        quantityDisplay: purchase == null
            ? null
            : purchaseDisplayFor(purchase: purchase, ingredient: ingredient),
      ),
    );
  }
}

/// [PurchaseQuantity.display], annotated with the two-level breakdown when
/// [ingredient] is bought in an outer pack that nests inner ones — e.g.
/// `'1 caja (8 bolsas × 3 u)'`, so the shopper sees WHY one caja covers the
/// shortfall without re-multiplying it themselves.
///
/// Single-level packages (and every non-package purchase shape) render
/// exactly as before.
String purchaseDisplayFor({
  required PurchaseQuantity purchase,
  required Ingredient ingredient,
}) {
  final breakdown = ingredient.package?.innerBreakdown;
  if (purchase is! PackagePurchase || breakdown == null) {
    return purchase.display;
  }
  return '${purchase.display} ($breakdown)';
}

/// [PackageSpec.effectiveYieldQty] only when it can actually divide a
/// shortfall, else `null` — "no hay empaque usable".
///
/// A legacy or hand-edited Firestore doc can carry `yieldQty: 0` (making
/// [MeasurementConverter.toPurchaseQuantity]'s `(value / yieldQty).ceil()`
/// throw `UnsupportedError` on `Infinity`, outside any `Either`) or a
/// negative one (rendering "-3 caja", since [PurchaseQuantity]'s
/// `packs >= 0` check is an `assert` stripped in release). A `?? 1`
/// fallback catches neither, because both values are non-null.
num? _usableYieldQty(Ingredient ingredient) {
  final total = ingredient.package?.effectiveYieldQty;
  if (total == null || total <= 0) return null;
  return total;
}

/// The default purchase [Presentation] synthesized for an ingredient absent
/// from the pantry (assume-zero anchor), derived from
/// [Ingredient.measurementMode] rather than the legacy `measurementKind`/
/// `booleanTracked` pair: `mass` -> `counter`, `count` -> `package` when it
/// carries a [PackageSpec.effectiveYieldQty] (e.g. salmas caja = 8 bolsas ×
/// 3 u = 24, so a 3 u shortfall buys 1 caja, not 3 loose units) else
/// `loose`, `packageBase` -> `package` (its own `effectiveYieldQty`/
/// `label`), `packageAbstract` -> `package` (a single decimal pack of its
/// own `label`).
///
/// Always reads [PackageSpec.effectiveYieldQty], never the raw `yieldQty`,
/// so a two-level package rounds up to whole OUTER packs off its DERIVED
/// total rather than a hand-multiplied one — and only when that total is
/// usable, see [_usableYieldQty].
///
/// Keeps [MeasurementConverter.toPurchaseQuantity]'s ceiling behavior fed
/// with the [Presentation] shape it still expects, without
/// [MeasurementConverter] itself knowing about [MeasurementMode] — see the
/// flexible-units design's "Preserve MeasurementConverter" decision.
/// `boolean`-mode ingredients never reach this adapter (they are gathered
/// via [ProvisioningCalculator.shouldSurfaceBooleanItem] instead), so
/// `loose` is only a harmless placeholder for that case.
Presentation presentationForPurchase(Ingredient ingredient) {
  return switch (ingredient.measurementMode) {
    MeasurementMode.mass => const Presentation.counter(),
    MeasurementMode.count => switch (_usableYieldQty(ingredient)) {
      final num yieldQty => Presentation.package(
        yieldQty: yieldQty,
        label: ingredient.package?.label ?? 'paquete',
      ),
      null => const Presentation.loose(),
    },
    MeasurementMode.packageBase => Presentation.package(
      yieldQty: _usableYieldQty(ingredient) ?? 1,
      label: ingredient.package?.label ?? 'paquete',
    ),
    MeasurementMode.packageAbstract => Presentation.package(
      yieldQty: 1,
      label: ingredient.package?.label ?? 'paquete',
    ),
    MeasurementMode.boolean => const Presentation.loose(),
  };
}
