import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/recipes/presentation/widgets/_bom_editor.dart';
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

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('recipeUnitOptions', () {
    test('is the fixed curated vocabulary: taza, g, u, cda, L', () {
      expect(recipeUnitOptions.map((u) => u.symbol).toList(), [
        'taza',
        'g',
        'u',
        'cda',
        'L',
      ]);
      expect(recipeUnitOptions[0].dimension, UnitDimension.volume);
      expect(recipeUnitOptions[1], Unit.gram);
      expect(recipeUnitOptions[2], Unit.count);
      expect(recipeUnitOptions[3].dimension, UnitDimension.volume);
      expect(recipeUnitOptions[4], Unit.liter);
    });
  });

  group('BomDraft', () {
    test('defaults to the first curated unit and an empty quantity', () {
      final draft = BomDraft();
      addTearDown(draft.dispose);

      expect(draft.ingredientId, isNull);
      expect(draft.unit, recipeUnitOptions.first);
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
      final draft = BomDraft(ingredientId: 'ing-pollo', quantity: 1);
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

    testWidgets('the unit dropdown offers exactly the 5 curated units', (
      tester,
    ) async {
      final draft = BomDraft(ingredientId: 'ing-pollo', quantity: 1);
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

      // The dropdown renders one DropdownMenuItem per curated unit in the
      // open menu, PLUS the currently-selected item mirrored in the closed
      // field itself (Flutter's DropdownButtonFormField behavior) — 5 + 1.
      expect(find.byType(DropdownMenuItem<Unit>), findsNWidgets(6));
      for (final label in const [
        'Taza',
        'Gramos (g)',
        'Unidades (u)',
        'Cucharada (cda)',
        'Litros (L)',
      ]) {
        expect(find.text(label), findsWidgets);
      }
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
      await tester.tap(find.text('Litros (L)').last);
      await tester.pumpAndSettle();

      expect(changedIndex, 0);
      expect(changedUnit, Unit.liter);
    });
  });
}
