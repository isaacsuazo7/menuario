import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  Future<void> pump(WidgetTester tester, MealType mealType) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: Center(child: MealTypeTag(mealType: mealType)),
        ),
      ),
    );
  }

  testWidgets('shows the meal type Spanish label', (tester) async {
    await pump(tester, MealType.cena);

    expect(find.text('Cena'), findsOneWidget);
  });

  testWidgets('renders every meal type label', (tester) async {
    for (final mealType in MealType.values) {
      await pump(tester, mealType);
      expect(find.text(mealType.label), findsOneWidget);
    }
  });

  testWidgets('is a filled pill tinted from the color scheme', (tester) async {
    await pump(tester, MealType.cena);

    final context = tester.element(find.byType(MealTypeTag));
    final colorScheme = Theme.of(context).colorScheme;
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(MealTypeTag),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;

    expect(decoration.color, colorScheme.secondaryContainer);
    // Fully rounded: a stadium, not a rounded rectangle.
    expect(decoration.shape, BoxShape.rectangle);
    expect(decoration.borderRadius, isNotNull);
  });

  testWidgets('labels with the on-container role so it stays legible', (
    tester,
  ) async {
    await pump(tester, MealType.cena);

    final context = tester.element(find.byType(MealTypeTag));
    final label = tester.widget<Text>(find.text('Cena'));

    expect(
      label.style?.color,
      Theme.of(context).colorScheme.onSecondaryContainer,
    );
  });

  testWidgets('pads the label horizontally and vertically', (tester) async {
    await pump(tester, MealType.cena);

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(MealTypeTag),
        matching: find.byType(Container),
      ),
    );
    final padding = container.padding! as EdgeInsets;

    expect(padding.horizontal, greaterThan(0));
    expect(padding.vertical, greaterThan(0));
    expect(padding.horizontal, greaterThan(padding.vertical));
  });
}
