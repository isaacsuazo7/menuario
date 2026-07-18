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

/// Route path/name constant for the batch-cook schedule editor.
///
/// Top-level (sibling of [SplashRoutes]/[AuthRoutes], NOT nested inside
/// the shell's [ShellRoutes] branches) — mirrors [IngredientRoutes]: the
/// editor covers the whole screen, no bottom nav, no drawer, just a back
/// button.
abstract final class CookScheduleRoutes {
  const CookScheduleRoutes._();

  static const edit = '/cook-schedule';
}

/// Route path/name constant for the theme-customization screen.
///
/// Top-level (sibling of [SplashRoutes]/[AuthRoutes], NOT nested inside the
/// shell's [ShellRoutes] branches) — mirrors [CookScheduleRoutes]: the
/// screen covers the whole screen, no bottom nav, no drawer, just a back
/// button.
abstract final class SettingsRoutes {
  const SettingsRoutes._();

  static const appearance = '/appearance';
}

/// Route path/name constant for the recipe create/edit form.
///
/// Top-level (sibling of [SplashRoutes]/[AuthRoutes], NOT nested inside the
/// shell's [ShellRoutes] branches) — mirrors [IngredientRoutes]. Deliberately
/// `/recipe-form`, NOT `/recipes/form`: the latter would collide with the
/// Recetario shell branch's `/recipes/:id` recipe-detail child route, where
/// `:id` would capture the literal segment `form`. Serves BOTH create and
/// edit: an absent `id` query parameter means create, a present one means
/// edit-by-id.
abstract final class RecipeRoutes {
  const RecipeRoutes._();

  static const form = '/recipe-form';
}
