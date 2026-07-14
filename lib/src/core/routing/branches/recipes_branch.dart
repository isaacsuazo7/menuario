import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/core/routing/navigator_keys.dart';
import 'package:menuario/src/features/recipes/presentation/screens/recipe_detail_screen.dart';
import 'package:menuario/src/features/recipes/presentation/screens/recipes_screen.dart';

final _recipesNavigatorKey = GlobalKey<NavigatorState>();

/// The "Recetario" tab branch — hosts [RecipesScreen] on its own nested
/// navigator so its state survives switching to other tabs
/// (indexed-stack). The `:id` child route pushes [RecipeDetailScreen] on
/// the ROOT navigator (`parentNavigatorKey: rootNavigatorKey`) so the
/// detail covers the whole screen — no bottom nav, no drawer, just a back
/// button.
final recipesBranch = StatefulShellBranch(
  navigatorKey: _recipesNavigatorKey,
  routes: [
    GoRoute(
      path: ShellRoutes.recipes,
      name: ShellRoutes.recipes,
      builder: (context, state) => const RecipesScreen(),
      routes: [
        GoRoute(
          path: ':id',
          name: ShellRoutes.recipeDetailName,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) =>
              RecipeDetailScreen(recipeId: state.pathParameters['id']!),
        ),
      ],
    ),
  ],
);
