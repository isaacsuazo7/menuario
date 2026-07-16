import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/weekly_consumption_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/ingredients_by_id_provider.dart';
import 'package:menuario/src/features/shopping/presentation/models/shopping_row.dart';
import 'package:menuario/src/features/shopping/presentation/providers/shopping_list_builder.dart';
import 'package:menuario/src/shared/shared.dart';

final _builder = ShoppingListBuilder(
  calculator: ProvisioningCalculator(converter: const MeasurementConverter()),
);

/// The derived Comprar buy list: combines
/// [weeklyConsumptionByIngredientProvider] (the shared plan+recipe join),
/// [pantryControllerProvider] and [ingredientsByIdProvider] through the
/// pure [ShoppingListBuilder].
///
/// Read-only, mirrors [pantryGroupsProvider]'s shape — the upstream
/// providers already carry `retry: null` + keep-alive, so this derived
/// `Provider` needs neither. An optimistic pantry patch re-emits from
/// [pantryControllerProvider] and this recomputes automatically, so a
/// covered item self-clears without any explicit invalidation here. The
/// plan+recipe join itself is NOT repeated here — see
/// [weeklyConsumptionByIngredientProvider]'s docs for why it lives in
/// exactly one place.
final shoppingListProvider = Provider<AsyncValue<ShoppingBuyList>>(
  (ref) {
    final pantryValue = ref.watch(pantryControllerProvider);
    final consumptionValue = ref.watch(weeklyConsumptionByIngredientProvider);
    final ingredientsValue = ref.watch(ingredientsByIdProvider);

    final upstream = [pantryValue, consumptionValue, ingredientsValue];

    if (upstream.any((value) => value.isLoading)) {
      return const AsyncLoading();
    }
    for (final value in upstream) {
      if (value.hasError) {
        return AsyncError(value.error!, value.stackTrace ?? StackTrace.empty);
      }
    }

    final pantryByIngredientId = {
      for (final row in pantryValue.value!) row.item.ingredientId: row.item,
    };

    final buyList = _builder.build(
      weeklyConsumptionByIngredient: consumptionValue.value!,
      ingredientsById: ingredientsValue.value!,
      pantryByIngredientId: pantryByIngredientId,
    );

    return AsyncData(buyList);
  },
  dependencies: [
    pantryControllerProvider,
    weeklyConsumptionByIngredientProvider,
    ingredientsByIdProvider,
  ],
);
