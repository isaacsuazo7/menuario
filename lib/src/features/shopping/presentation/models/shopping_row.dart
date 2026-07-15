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

/// The full derived Comprar list: category-grouped rows plus the
/// ingredient ids skipped due to a per-item calculation failure.
class ShoppingBuyList {
  const ShoppingBuyList({required this.groups, required this.skipped});

  /// The rows to render, grouped and ordered by [Category.values].
  final List<ShoppingCategoryGroup> groups;

  /// Ingredient ids whose calculation returned `Left(Failure)` and were
  /// skipped rather than failing the whole list.
  final List<String> skipped;
}
