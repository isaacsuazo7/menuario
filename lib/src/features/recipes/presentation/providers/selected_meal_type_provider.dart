import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/shared/shared.dart';

/// The Recetario grid's active meal-type filter. `null` means "Todas".
///
/// Not `autoDispose`: the filter should survive switching away from and
/// back to the Recetario tab (the tab's nested navigator/state is kept
/// alive by the shell's `IndexedStack`).
final selectedMealTypeProvider =
    NotifierProvider<SelectedMealTypeNotifier, MealType?>(
      SelectedMealTypeNotifier.new,
      dependencies: const [],
    );

/// Holds the currently selected [MealType] filter, or `null` for "Todas".
class SelectedMealTypeNotifier extends Notifier<MealType?> {
  @override
  MealType? build() => null;

  /// Selects [mealType] as the active filter (`null` resets to "Todas").
  void select(MealType? mealType) => state = mealType;
}
