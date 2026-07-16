import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/core/routing/navigator_keys.dart';
import 'package:menuario/src/core/routing/branches/provisioning_branch.dart';
import 'package:menuario/src/core/routing/branches/recipes_branch.dart';
import 'package:menuario/src/core/routing/branches/today_branch.dart';
import 'package:menuario/src/core/routing/branches/week_branch.dart';
import 'package:menuario/src/core/routing/widgets/app_shell_scaffold.dart';
import 'package:menuario/src/core/routing/widgets/splash_screen.dart';
import 'package:menuario/src/features/auth/presentation/sign_in_screen.dart';
import 'package:menuario/src/features/ingredients/presentation/screens/ingredient_form_screen.dart';
import 'package:menuario/src/features/ingredients/presentation/screens/ingredients_list_screen.dart';
import 'package:menuario/src/features/recipes/presentation/screens/recipe_form_screen.dart';
import 'package:menuario/src/features/today/presentation/screens/cook_schedule_screen.dart';

/// Bridges a [Stream] to a [Listenable] so [GoRouter] re-evaluates its
/// `redirect` on every emission — here, every `authStateProvider`
/// emission.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// The app-wide [GoRouter], gated by [authStateProvider].
///
/// `redirect` reads the current auth-state snapshot: while it's still
/// resolving (`AsyncLoading`) the user is sent to [SplashRoutes.splash]
/// and no further redirect is applied — this avoids a flicker/loop on
/// the very first emission. Once resolved, a `null` value means
/// signed-out (→ sign-in) and a non-null [User] means signed-in (→ shell,
/// only when currently on the sign-in or splash routes).
///
/// The refresh bridge is driven by `ref.listen(authStateProvider, ...)`
/// rather than a second, independent subscription to the raw auth
/// stream — this keeps the notification perfectly synchronized with the
/// exact value `redirect` reads via `ref.read(authStateProvider)` (no
/// stream-provider `.stream` modifier exists to expose that in Riverpod
/// 3, and racing two separate subscriptions to the same underlying
/// stream risks the router missing the settled value).
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshController = StreamController<void>.broadcast();
  final authStateSubscription = ref.listen(
    authStateProvider,
    (previous, next) => refreshController.add(null),
  );
  final refreshStream = GoRouterRefreshStream(refreshController.stream);
  ref.onDispose(() {
    authStateSubscription.close();
    refreshController.close();
    refreshStream.dispose();
  });

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: SplashRoutes.splash,
    refreshListenable: refreshStream,
    routes: [
      GoRoute(
        path: SplashRoutes.splash,
        name: SplashRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AuthRoutes.signIn,
        name: AuthRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: IngredientRoutes.list,
        name: IngredientRoutes.list,
        builder: (context, state) => const IngredientsListScreen(),
      ),
      GoRoute(
        path: IngredientRoutes.form,
        name: IngredientRoutes.form,
        builder: (context, state) =>
            IngredientFormScreen(ingredientId: state.uri.queryParameters['id']),
      ),
      GoRoute(
        path: CookScheduleRoutes.edit,
        name: CookScheduleRoutes.edit,
        builder: (context, state) => const CookScheduleScreen(),
      ),
      GoRoute(
        path: RecipeRoutes.form,
        name: RecipeRoutes.form,
        builder: (context, state) =>
            RecipeFormScreen(recipeId: state.uri.queryParameters['id']),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShellScaffold(navigationShell: navigationShell),
        branches: [todayBranch, weekBranch, provisioningBranch, recipesBranch],
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      if (authState.isLoading) {
        return SplashRoutes.splash;
      }

      final isSignedIn = authState.value != null;
      final isOnSignIn = state.matchedLocation == AuthRoutes.signIn;
      final isOnSplash = state.matchedLocation == SplashRoutes.splash;

      if (!isSignedIn) {
        return isOnSignIn ? null : AuthRoutes.signIn;
      }

      if (isOnSignIn || isOnSplash) {
        return ShellRoutes.today;
      }

      return null;
    },
  );

  ref.onDispose(router.dispose);

  return router;
}, dependencies: [authStateProvider, authServiceProvider]);
