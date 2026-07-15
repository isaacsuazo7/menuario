/// Route path/name constants for the splash gate.
///
/// Shown while [authStateProvider] resolves its first emission, avoiding
/// a sign-in/shell flicker on cold start.
abstract final class SplashRoutes {
  const SplashRoutes._();

  static const splash = '/splash';
}

/// Route path/name constants for the unauthenticated flow.
abstract final class AuthRoutes {
  const AuthRoutes._();

  static const signIn = '/sign-in';
}

/// Route path/name constants for the authenticated four-tab shell.
abstract final class ShellRoutes {
  const ShellRoutes._();

  static const today = '/';
  static const week = '/week';
  static const provisioning = '/provisioning';
  static const recipes = '/recipes';

  /// The Recetario recipe-detail child route (full path `/recipes/:id`).
  static const recipeDetailName = 'recipe-detail';
}

/// Route path/name constants for the ingredient catalog maintenance flow.
///
/// Both routes are top-level (siblings of [SplashRoutes]/[AuthRoutes], NOT
/// nested inside the shell's [ShellRoutes] branches) so the list and form
/// cover the whole screen — no bottom nav, no drawer, just a back button.
/// [form] serves BOTH create and edit: an absent `id` query parameter
/// means create, a present one means edit-by-id.
abstract final class IngredientRoutes {
  const IngredientRoutes._();

  static const list = '/ingredients';
  static const form = '/ingredients/form';
}
