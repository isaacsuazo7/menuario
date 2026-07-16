import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/features/recipes/presentation/providers/ingredients_by_id_provider.dart';
import 'package:menuario/src/features/today/presentation/widgets/today_meal_detail_sheet.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  const ingredient = Ingredient(
    id: 'i-1',
    name: 'Harina',
    emoji: '🌾',
    category: Category.cereal,
    measurementKind: MeasurementKind.unit,
    booleanTracked: false,
  );
  const recipe = Recipe(
    id: 'r-1',
    name: 'Pan casero',
    emoji: '🍞',
    mealType: MealType.desayuno,
    bomLines: [
      BomLine(
        recipeId: 'r-1',
        ingredientId: 'i-1',
        quantity: Quantity(value: 2, unit: Unit.count),
      ),
    ],
  );

  String? pushedRouteName;
  Map<String, String>? pushedPathParameters;

  Future<void> pumpSheet(WidgetTester tester) async {
    pushedRouteName = null;
    pushedPathParameters = null;

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const TodayMealDetailSheet(
                    recipe: recipe,
                    mealSlot: MealSlot.desayuno,
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/recipes/:id',
          name: ShellRoutes.recipeDetailName,
          builder: (context, state) {
            pushedRouteName = ShellRoutes.recipeDetailName;
            pushedPathParameters = state.pathParameters;
            return const Scaffold(body: Text('detail'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ingredientsByIdProvider.overrideWith(
            (ref) async => const {'i-1': ingredient},
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows emoji, name, and its ingredient rows', (tester) async {
    await pumpSheet(tester);

    expect(find.text('Pan casero'), findsOneWidget);
    expect(find.text('🍞'), findsOneWidget);
    expect(find.text('Harina'), findsOneWidget);
  });

  testWidgets('shows exactly one action: "Ver receta"', (tester) async {
    await pumpSheet(tester);

    expect(find.text('Ver receta'), findsOneWidget);
    expect(find.text('Cambiar'), findsNothing);
    expect(find.text('Quitar'), findsNothing);
  });

  testWidgets(
    'tapping "Ver receta" pops the sheet and pushes the recipe-detail route',
    (tester) async {
      await pumpSheet(tester);

      await tester.tap(find.text('Ver receta'));
      await tester.pumpAndSettle();

      expect(find.byType(TodayMealDetailSheet), findsNothing);
      expect(pushedRouteName, ShellRoutes.recipeDetailName);
      expect(pushedPathParameters, {'id': 'r-1'});
    },
  );
}
