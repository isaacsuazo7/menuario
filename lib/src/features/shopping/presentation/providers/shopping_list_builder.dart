import 'package:dartz/dartz.dart' hide Unit;
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/features/shopping/presentation/models/shopping_row.dart';
import 'package:menuario/src/shared/shared.dart';

/// Pure, Flutter-free derivation of the Comprar buy list from the active
/// plan, pantry and recipe data, via [ProvisioningCalculator].
///
/// No mutations, no Riverpod — the derived provider that watches the four
/// upstream `AsyncValue`s is the only Flutter-aware layer; this class is
/// unit-testable with plain fixtures, mirroring [ProvisioningCalculator]
/// itself.
class ShoppingListBuilder {
  const ShoppingListBuilder({required ProvisioningCalculator calculator})
    // ignore: prefer_initializing_formals
    : _calculator = calculator;

  final ProvisioningCalculator _calculator;

  /// Derives the [ShoppingBuyList] for [weekPlan] against [recipes],
  /// [ingredientsById] and [pantryByIngredientId].
  ///
  /// Quantity-tracked ingredients are gathered from every `BomLine` of a
  /// recipe [weekPlan] actually plans (see the Assume-Zero Anchor Rule for
  /// ingredients with no matching [pantryByIngredientId] entry).
  /// Boolean-tracked ingredients are gathered directly from
  /// [pantryByIngredientId] via
  /// [ProvisioningCalculator.shouldSurfaceBooleanItem] — independent of
  /// whether they appear in [weekPlan] this week.
  ///
  /// Any step returning `Left(Failure)` for one ingredient skips only that
  /// row, recorded in [ShoppingBuyList.skipped], and continues with the
  /// rest.
  ShoppingBuyList build({
    required WeekPlan weekPlan,
    required List<Recipe> recipes,
    required Map<String, Ingredient> ingredientsById,
    required Map<String, PantryItem> pantryByIngredientId,
  }) {
    final plannedRecipeIds = {
      for (final entry in weekPlan.entries) entry.recipeId,
    };
    final plannedRecipes = [
      for (final recipe in recipes)
        if (plannedRecipeIds.contains(recipe.id)) recipe,
    ];

    final quantityIngredientIds = <String>{};
    for (final recipe in plannedRecipes) {
      for (final line in recipe.bomLines) {
        final ingredient = ingredientsById[line.ingredientId];
        if (ingredient != null && !ingredient.booleanTracked) {
          quantityIngredientIds.add(line.ingredientId);
        }
      }
    }

    final rows = <ShoppingRow>[];
    final skipped = <String>[];

    for (final ingredientId in quantityIngredientIds) {
      final row = _buildQuantityRow(
        ingredientId: ingredientId,
        ingredient: ingredientsById[ingredientId]!,
        recipes: recipes,
        weekPlan: weekPlan,
        pantryByIngredientId: pantryByIngredientId,
      );
      if (row == null) {
        skipped.add(ingredientId);
      } else if (row.quantityDisplay != null) {
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

  /// Computes the quantity-tracked row for [ingredientId], or `null` when
  /// any pipeline step returns `Left(Failure)` (caller records it as
  /// skipped). A non-null row with a `null` [ShoppingRow.quantityDisplay]
  /// means there is nothing to buy (`purchaseQuantity` returned
  /// `Right(null)`) and the caller omits it.
  ShoppingRow? _buildQuantityRow({
    required String ingredientId,
    required Ingredient ingredient,
    required List<Recipe> recipes,
    required WeekPlan weekPlan,
    required Map<String, PantryItem> pantryByIngredientId,
  }) {
    final consumptionResult = _calculator.weeklyConsumption(
      ingredient: ingredient,
      recipes: recipes,
      weekPlan: weekPlan,
    );
    if (consumptionResult case Left()) return null;
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
        presentation: _defaultPresentation(ingredient),
        stock: Quantity(value: 0, unit: consumption.unit),
      );
      pantryExists = false;
    }

    final shortfallResult = _calculator.shortfall(
      ingredient: ingredient,
      consumption: consumption,
      stock: pantryItem.stock,
    );
    if (shortfallResult case Left()) return null;
    final shortfall = (shortfallResult as Right<Failure, Quantity>).value;

    final purchaseResult = _calculator.purchaseQuantity(
      shortfall: shortfall,
      presentation: pantryItem.presentation,
    );
    if (purchaseResult case Left()) return null;
    final purchase =
        (purchaseResult as Right<Failure, PurchaseQuantity?>).value;

    return ShoppingRow(
      ingredientId: ingredientId,
      ingredient: ingredient,
      category: ingredient.category,
      isBooleanTracked: false,
      pantryItem: pantryItem,
      pantryExists: pantryExists,
      quantityDisplay: purchase?.display,
    );
  }

  /// The default [Presentation] synthesized for an ingredient absent from
  /// the pantry (assume-zero anchor): `bulk` -> `counter`, `unit` ->
  /// `loose`. `Ingredient` carries no stored presentation, so this cannot
  /// recover a `package` shape — acceptable, since no stored presentation
  /// exists for an absent ingredient either way.
  Presentation _defaultPresentation(Ingredient ingredient) {
    return ingredient.measurementKind == MeasurementKind.bulk
        ? const Presentation.counter()
        : const Presentation.loose();
  }
}
