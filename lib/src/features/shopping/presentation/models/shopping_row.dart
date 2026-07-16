import 'package:menuario/src/shared/shared.dart';

/// A single Comprar row: an ingredient that still needs to be bought this
/// week, derived (never stored) from the active plan, pantry and recipe
/// data.
///
/// Quantity-tracked ingredients carry [quantityDisplay] (from
/// [PurchaseQuantity.display]); boolean-tracked "no tengo" ingredients
/// carry `null` instead, per [ShoppingRow.isBooleanTracked].
class ShoppingRow {
  const ShoppingRow({
    required this.ingredientId,
    required this.ingredient,
    required this.category,
    required this.isBooleanTracked,
    required this.pantryItem,
    required this.pantryExists,
    this.quantityDisplay,
  });

  /// The ingredient this row is about.
  final String ingredientId;

  /// The resolved ingredient (name, emoji) [ingredientId] refers to.
  final Ingredient ingredient;

  /// The category this row is grouped under.
  final Category category;

  /// Whether this row is a boolean "no tengo" item (tick-only, no
  /// quantity) rather than a numeric quantity-tracked shortfall.
  final bool isBooleanTracked;

  /// The real pantry item (when [pantryExists]) or a synthesized stock-0
  /// [QuantityTrackedPantryItem] (when not) — either way, ready to drive
  /// the restock hand-off.
  final PantryItem pantryItem;

  /// Whether [pantryItem] is a real, persisted pantry record. `false` for
  /// an assume-zero-anchored ingredient absent from the pantry.
  final bool pantryExists;

  /// The purchase-quantity rendering (e.g. `'6 unidades'`), or `null` for
  /// a boolean-tracked row.
  final String? quantityDisplay;
}

/// A fixed-order [Category] bucket of [ShoppingRow]s for the grouped
/// Comprar list.
class ShoppingCategoryGroup {
  const ShoppingCategoryGroup({required this.category, required this.rows});

  /// The category every row in [rows] belongs to.
  final Category category;

  /// The shopping rows belonging to [category], in list order.
  final List<ShoppingRow> rows;
}

/// Why a [SkippedItem] was skipped, distilled from the `Failure.code` that
/// caused its calculation to fail — [needsFactor] is actionable (backfill
/// the ingredient's `conversionFactor`), [other] covers every other failure
/// kind (e.g. `unitMismatch`).
enum SkipReason { needsFactor, other }

/// A single skipped-calculation diagnostic: the ingredient's name and why
/// it was skipped, so the Comprar tab can name it instead of folding it
/// into an anonymous count.
class SkippedItem {
  const SkippedItem({required this.name, required this.reason});

  /// The skipped ingredient's display name.
  final String name;

  /// Why the calculation was skipped.
  final SkipReason reason;
}

/// The full derived Comprar list: category-grouped rows plus the items
/// skipped due to a per-item calculation failure.
class ShoppingBuyList {
  const ShoppingBuyList({required this.groups, required this.skipped});

  /// The rows to render, grouped and ordered by [Category.values].
  final List<ShoppingCategoryGroup> groups;

  /// Items whose calculation returned `Left(Failure)` and were skipped
  /// rather than failing the whole list, named with a [SkipReason].
  final List<SkippedItem> skipped;
}
