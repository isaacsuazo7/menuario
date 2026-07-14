import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/recipes/presentation/providers/selected_meal_type_provider.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  test('defaults to null (Todas)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(selectedMealTypeProvider), isNull);
  });

  test('select updates the state to the given meal type', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(selectedMealTypeProvider.notifier).select(
      MealType.desayuno,
    );

    expect(container.read(selectedMealTypeProvider), MealType.desayuno);
  });

  test('select(null) resets back to Todas', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(selectedMealTypeProvider.notifier).select(
      MealType.desayuno,
    );
    container.read(selectedMealTypeProvider.notifier).select(null);

    expect(container.read(selectedMealTypeProvider), isNull);
  });
}
