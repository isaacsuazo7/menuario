import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredients_list_provider.dart';
import 'package:menuario/src/shared/shared.dart';

/// Every stored [Ingredient], keyed by [Ingredient.id] for O(1) `BomLine`
/// resolution.
///
/// Deriva de [ingredientsListProvider] (misma carga, un solo fetch) en vez
/// de consultar el repositorio por su cuenta: así el upsert en sitio del
/// catálogo llega hasta acá por propagación de `ref.watch`, sin que nadie
/// tenga que invalidar este provider desde otra ruta.
final ingredientsByIdProvider = FutureProvider<Map<String, Ingredient>>(
  (ref) async {
    final ingredients = await ref.watch(ingredientsListProvider.future);
    return {for (final ingredient in ingredients) ingredient.id: ingredient};
  },
  dependencies: [ingredientsListProvider],
  retry: (retryCount, error) => null,
);
