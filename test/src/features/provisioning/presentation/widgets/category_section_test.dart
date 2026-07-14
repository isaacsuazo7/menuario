import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/theme/app_theme.dart';
import 'package:menuario/src/core/theme/category_colors.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/widgets/_category_section.dart';
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
  const avenaItem = PantryItem.quantityTracked(
    ingredientId: 'ing-avena',
    category: Category.cereal,
    presentation: Presentation.package(yieldQty: 454, label: 'bolsa'),
    stock: Quantity(value: 2, unit: Unit.gram),
  );

  setUp(() {
    mockPantryRepository = MockPantryRepository();
    mockIngredientRepository = MockIngredientRepository();
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => const Right([avenaItem]));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([avena]));
  });

  Future<void> pumpSection(
    WidgetTester tester,
    PantryCategoryGroup group,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pantryRepositoryProvider.overrideWithValue(mockPantryRepository),
          ingredientRepositoryProvider.overrideWithValue(
            mockIngredientRepository,
          ),
        ],
        child: MaterialApp(
          theme: MenuarioTheme.light,
          home: Scaffold(body: CategorySection(group: group)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Color colorDotColor(WidgetTester tester) {
    final container = tester.widget<Container>(
      find.byKey(const ValueKey('category-color-dot')),
    );
    return (container.decoration! as BoxDecoration).color!;
  }

  testWidgets('renders the category label and its themed color dot', (
    tester,
  ) async {
    final group = PantryCategoryGroup(
      category: Category.cereal,
      rows: [PantryRow(item: avenaItem, ingredient: avena)],
    );

    await pumpSection(tester, group);

    expect(find.text('Cereal'), findsOneWidget);
    final palette = MenuarioTheme.light.extension<MenuarioCategoryColors>()!;
    expect(colorDotColor(tester), palette.cereal);
  });

  testWidgets('renders a neutral fallback dot for Category.otro', (
    tester,
  ) async {
    const comino = Ingredient(
      id: 'ing-comino',
      name: 'Comino',
      category: Category.otro,
      measurementKind: MeasurementKind.unit,
      booleanTracked: true,
    );
    const cominoItem = PantryItem.booleanTracked(
      ingredientId: 'ing-comino',
      category: Category.otro,
      presentation: Presentation.loose(),
      haveIt: false,
    );
    when(
      () => mockPantryRepository.list(),
    ).thenAnswer((_) async => const Right([cominoItem]));
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([comino]));

    final group = PantryCategoryGroup(
      category: Category.otro,
      rows: [PantryRow(item: cominoItem, ingredient: comino)],
    );

    await pumpSection(tester, group);

    expect(find.text('Otro'), findsOneWidget);
    final palette = MenuarioTheme.light.extension<MenuarioCategoryColors>()!;
    final dotColor = colorDotColor(tester);
    expect(dotColor, isNot(palette.proteina));
    expect(dotColor, isNot(palette.vegetal));
    expect(dotColor, isNot(palette.fruta));
    expect(dotColor, isNot(palette.cereal));
    expect(dotColor, isNot(palette.lacteo));
    expect(dotColor, isNot(palette.condimento));
    expect(dotColor, isNot(palette.semilla));
  });
}
