import 'package:flutter/material.dart';

// TODO(PR3): real combined form — replace this stub with the adaptive
// create/edit form (measurementKind/booleanTracked branches) and the atomic
// `IngredientCatalogRepository.saveWithPantry` wiring, per the
// ingredient-crud design.
/// Placeholder screen wired into [IngredientRoutes.form] so navigation from
/// the list screen (FAB and row-tap) is testable ahead of the real form.
class IngredientFormScreen extends StatelessWidget {
  const IngredientFormScreen({super.key, this.ingredientId});

  /// The [Ingredient.id] being edited, or `null` when creating.
  final String? ingredientId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ingredientId == null ? 'Nuevo ingrediente' : 'Editar ingrediente',
        ),
      ),
      body: const SizedBox.shrink(),
    );
  }
}
