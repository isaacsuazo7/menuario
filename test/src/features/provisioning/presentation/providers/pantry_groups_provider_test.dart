import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_groups_provider.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockPantryRepository extends Mock implements PantryRepository {}

class MockIngredientRepository extends Mock implements IngredientRepository {}

void main() {
  late MockPantryRepository mockPantryRepository;
  late MockIngredientRepository mockIngredientRepository;

  const avena = Ingredient(
    id: 'ing-avena',
    name: 'Avena',
    emoji: '🥣',
    category: Category.cereal,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    conversionFactor: 85,
  );
  const zanahoria = Ingredient(
    id: 'ing-zanahoria',
    name: 'Zanahoria',
    emoji: '🥕',
    category: Category.vegetal,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    conversionFactor: 50,
  );
  const papa = Ingredient(
    id: 'ing-papa',
    name: 'Papa',
    emoji: '🥔',
    category: Category.vegetal,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    conversionFactor: 50,
  );

  const avenaItem = PantryItem.quantityTracked(
    ingredientId: 'ing-avena',
    category: Category.cereal,
    presentation: Presentation.package(yieldQty: 454, label: 'bolsa'),
    stock: Quantity(value: 2, unit: Unit.gram),
  );
  const zanahoriaItem = PantryItem.quantityTracked(
    ingredientId: 'ing-zanahoria',
    category: Category.vegetal,
    presentation: Presentation.loose(),
    stock: Quantity(value: 5, unit: Unit.gram),
  );
  const papaItem = PantryItem.quantityTracked(
    ingredientId: 'ing-papa',
    category: Category.vegetal,
    presentation: Presentation.loose(),
    stock: Quantity(value: 1, unit: Unit.gram),
  );

  setUp(() {
    mockPantryRepository = MockPantryRepository();
    mockIngredientRepository = MockIngredientRepository();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        pantryRepositoryProvider.overrideWithValue(mockPantryRepository),
        ingredientRepositoryProvider.overrideWithValue(
          mockIngredientRepository,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    'groups 3 items spanning 2 categories into exactly 2 fixed-order groups',
    () async {
      when(() => mockPantryRepository.list()).thenAnswer(
        (_) async => const Right([avenaItem, zanahoriaItem, papaItem]),
      );
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([avena, zanahoria, papa]));

      final container = makeContainer();
      await container.read(pantryControllerProvider.future);

      final groupsValue = container.read(pantryGroupsProvider);
      final groups = groupsValue.value!;

      expect(groups, hasLength(2));
      // Category.values fixed order is proteina, vegetal, ..., so vegetal
      // (zanahoria, papa) precedes cereal (avena).
      expect(groups[0].category, Category.vegetal);
      expect(groups[0].rows, hasLength(2));
      expect(groups[1].category, Category.cereal);
      expect(groups[1].rows, hasLength(1));
    },
  );
}
