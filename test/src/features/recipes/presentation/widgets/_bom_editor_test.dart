import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/recipes/presentation/widgets/_bom_editor.dart';
import 'package:menuario/src/shared/domain/services/recipe_unit_options.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  const pollo = Ingredient(
    id: 'ing-pollo',
    name: 'Pollo',
    emoji: '🍗',
    category: Category.proteina,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    conversionFactor: 1,
    measurementMode: MeasurementMode.mass,
  );
  const huevo = Ingredient(
    id: 'ing-huevo',
    name: 'Huevo',
    emoji: '🥚',
    category: Category.proteina,
    measurementKind: MeasurementKind.unit,
    booleanTracked: false,
    measurementMode: MeasurementMode.count,
  );
  const leche = Ingredient(
    id: 'ing-leche',
    name: 'Leche',
    emoji: '🥛',
    category: Category.lacteo,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    measurementMode: MeasurementMode.packageBase,
    package: PackageSpec(
      label: 'bolsa',
      yieldQty: 1,
      baseDimension: Unit.liter,
    ),
  );

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('BomDraft', () {
    test('defaults to Unit.count and an empty quantity', () {
      final draft = BomDraft();
      addTearDown(draft.dispose);

      expect(draft.ingredientId, isNull);
      expect(draft.unit, Unit.count);
      expect(draft.quantityController.text, isEmpty);
    });

    test(
      'seeds ingredientId, quantity text and unit from constructor args',
      () {
        final draft = BomDraft(
          ingredientId: 'ing-pollo',
          quantity: 2.5,
          unit: Unit.gram,
        );
        addTearDown(draft.dispose);

        expect(draft.ingredientId, 'ing-pollo');
        expect(draft.unit, Unit.gram);
        expect(draft.quantityController.text, '2.5');
      },
    );
  });

  group('BomEditorSection', () {
    testWidgets('renders an existing line: ingredient, quantity and unit', (
      tester,
    ) async {
      final draft = BomDraft(
        ingredientId: 'ing-pollo',
        quantity: 2,
        unit: Unit.gram,
      );
      addTearDown(draft.dispose);

      await tester.pumpWidget(
        wrap(
          BomEditorSection(
            lines: [draft],
            ingredientsById: const {'ing-pollo': pollo},
            onAddLine: () {},
            onRemoveLine: (_) {},
            onPickIngredient: (_) {},
            onUnitChanged: (_, _) {},
          ),
        ),
      );

      expect(find.textContaining('Pollo'), findsOneWidget);
      expect(find.widgetWithText(TextField, '2'), findsOneWidget);
      final dropdown = tester.widget<DropdownButtonFormField<Unit>>(
        find.byKey(const Key('recipe-bom-unit-field-0')),
      );
      expect(dropdown.initialValue, Unit.gram);
    });

    testWidgets('a line with no ingredient shows a placeholder and taps '
        'onPickIngredient', (tester) async {
      final draft = BomDraft();
      addTearDown(draft.dispose);
      var pickedIndex = -1;

      await tester.pumpWidget(
        wrap(
          BomEditorSection(
            lines: [draft],
            ingredientsById: const {},
            onAddLine: () {},
            onRemoveLine: (_) {},
            onPickIngredient: (index) => pickedIndex = index,
            onUnitChanged: (_, _) {},
          ),
        ),
      );

      expect(find.text('Seleccionar ingrediente'), findsOneWidget);

      await tester.tap(find.byKey(const Key('recipe-bom-ingredient-field-0')));
      await tester.pumpAndSettle();

      expect(pickedIndex, 0);
    });

    testWidgets('Agregar ingrediente invokes onAddLine', (tester) async {
      var added = false;

      await tester.pumpWidget(
        wrap(
          BomEditorSection(
            lines: const [],
            ingredientsById: const {},
            onAddLine: () => added = true,
            onRemoveLine: (_) {},
            onPickIngredient: (_) {},
            onUnitChanged: (_, _) {},
          ),
        ),
      );

      await tester.tap(find.text('Agregar ingrediente'));
      await tester.pumpAndSettle();

      expect(added, isTrue);
    });

    testWidgets('the remove button invokes onRemoveLine with the row index', (
      tester,
    ) async {
      final draft = BomDraft(
        ingredientId: 'ing-pollo',
        quantity: 1,
        unit: Unit.gram,
      );
      addTearDown(draft.dispose);
      var removedIndex = -1;

      await tester.pumpWidget(
        wrap(
          BomEditorSection(
            lines: [draft],
            ingredientsById: const {'ing-pollo': pollo},
            onAddLine: () {},
            onRemoveLine: (index) => removedIndex = index,
            onPickIngredient: (_) {},
            onUnitChanged: (_, _) {},
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('recipe-bom-remove-0')));
      await tester.pumpAndSettle();

      expect(removedIndex, 0);
    });

    testWidgets(
      'the unit dropdown offers exactly recipeUnitsFor(ingredient) for a '
      'picked mass-mode ingredient (pollo: g, kg, taza, cda)',
      (tester) async {
        final draft = BomDraft(
          ingredientId: 'ing-pollo',
          quantity: 1,
          unit: Unit.gram,
        );
        addTearDown(draft.dispose);

        await tester.pumpWidget(
          wrap(
            BomEditorSection(
              lines: [draft],
              ingredientsById: const {'ing-pollo': pollo},
              onAddLine: () {},
              onRemoveLine: (_) {},
              onPickIngredient: (_) {},
              onUnitChanged: (_, _) {},
            ),
          ),
        );

        await tester.tap(find.byKey(const Key('recipe-bom-unit-field-0')));
        await tester.pumpAndSettle();

        expect(recipeUnitsFor(pollo), hasLength(4));
        for (final label in const [
          'Gramos (g)',
          'Kilogramos (kg)',
          'Taza',
          'Cucharada (cda)',
        ]) {
          expect(find.text(label), findsWidgets);
        }
        expect(find.text('Litros (L)'), findsNothing);
        expect(find.text('Unidades (u)'), findsNothing);
      },
    );

    testWidgets(
      'a count-dimension ingredient (huevo) locks the unit dropdown to '
      'exactly {u}',
      (tester) async {
        final draft = BomDraft(
          ingredientId: 'ing-huevo',
          quantity: 1,
          unit: Unit.count,
        );
        addTearDown(draft.dispose);

        await tester.pumpWidget(
          wrap(
            BomEditorSection(
              lines: [draft],
              ingredientsById: const {'ing-huevo': huevo},
              onAddLine: () {},
              onRemoveLine: (_) {},
              onPickIngredient: (_) {},
              onUnitChanged: (_, _) {},
            ),
          ),
        );

        await tester.tap(find.byKey(const Key('recipe-bom-unit-field-0')));
        await tester.pumpAndSettle();

        // One item in the open menu, PLUS the currently-selected item
        // mirrored in the closed field itself (Flutter's
        // DropdownButtonFormField behavior) — 1 + 1.
        expect(find.byType(DropdownMenuItem<Unit>), findsNWidgets(2));
        expect(find.text('Unidades (u)'), findsWidgets);
      },
    );

    testWidgets('the unit dropdown is disabled until an ingredient is picked', (
      tester,
    ) async {
      final draft = BomDraft();
      addTearDown(draft.dispose);

      await tester.pumpWidget(
        wrap(
          BomEditorSection(
            lines: [draft],
            ingredientsById: const {},
            onAddLine: () {},
            onRemoveLine: (_) {},
            onPickIngredient: (_) {},
            onUnitChanged: (_, _) {},
          ),
        ),
      );

      final dropdown = tester.widget<DropdownButtonFormField<Unit>>(
        find.byKey(const Key('recipe-bom-unit-field-0')),
      );
      expect(dropdown.onChanged, isNull);

      await tester.tap(find.byKey(const Key('recipe-bom-unit-field-0')));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownMenuItem<Unit>), findsNothing);
    });

    testWidgets('selecting a unit invokes onUnitChanged with the row index', (
      tester,
    ) async {
      final draft = BomDraft(
        ingredientId: 'ing-pollo',
        quantity: 1,
        unit: Unit.gram,
      );
      addTearDown(draft.dispose);
      var changedIndex = -1;
      Unit? changedUnit;

      await tester.pumpWidget(
        wrap(
          BomEditorSection(
            lines: [draft],
            ingredientsById: const {'ing-pollo': pollo},
            onAddLine: () {},
            onRemoveLine: (_) {},
            onPickIngredient: (_) {},
            onUnitChanged: (index, unit) {
              changedIndex = index;
              changedUnit = unit;
            },
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('recipe-bom-unit-field-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kilogramos (kg)').last);
      await tester.pumpAndSettle();

      expect(changedIndex, 0);
      expect(changedUnit, Unit.kilogram);
    });

    testWidgets('picking a different ingredient resets the unit to the new '
        "ingredient's set-default unit", (tester) async {
      final draft = BomDraft();
      addTearDown(draft.dispose);
      var changedIndex = -1;
      Unit? changedUnit;

      Widget build({required Map<String, Ingredient> ingredientsById}) => wrap(
        BomEditorSection(
          lines: [draft],
          ingredientsById: ingredientsById,
          onAddLine: () {},
          onRemoveLine: (_) {},
          onPickIngredient: (_) {},
          onUnitChanged: (index, unit) {
            changedIndex = index;
            changedUnit = unit;
          },
        ),
      );

      await tester.pumpWidget(build(ingredientsById: const {}));

      // Simulates the screen assigning a picked ingredient id to the
      // draft, then re-rendering with the resolved ingredient.
      draft.ingredientId = 'ing-leche';
      await tester.pumpWidget(
        build(ingredientsById: const {'ing-leche': leche}),
      );

      expect(changedIndex, 0);
      expect(changedUnit, Unit.liter);
    });
  });
}
