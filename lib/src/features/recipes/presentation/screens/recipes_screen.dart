import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/recipes/presentation/providers/filtered_recipes_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/selected_meal_type_provider.dart';
import 'package:menuario/src/shared/presentation/tab_page_sync.dart';
import 'package:menuario/src/shared/shared.dart';

/// Page 0 is "Todas" (`null`); pages 1..N are [MealType.values] in order.
int _pageIndexOf(MealType? mealType) =>
    mealType == null ? 0 : MealType.values.indexOf(mealType) + 1;

/// Inverse of [_pageIndexOf].
MealType? _mealTypeAtPage(int index) =>
    index == 0 ? null : MealType.values[index - 1];

/// The "Recetario" tab: a 2-column grid of recipes, filterable by
/// [MealType], with loading/error/empty states.
///
/// The filter chips double as swipeable pages — dragging horizontally moves
/// to the next/previous filter, the same affordance Hoy and Abastecer ship.
/// [selectedMealTypeProvider] stays the single source of truth: the
/// [PageView] reports settles into it, and a root-level `ref.listen` drives
/// the page back (guarded inside [TabPageSync.syncPageToIndex] so the two
/// directions never fight).
///
/// Rendered inside the shell's single [AppBar]; keeps its own [Scaffold]
/// (without an `appBar`) purely to provide the [Material] ancestor its
/// [ChoiceChip]/[Card] descendants require.
class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen>
    with TabPageSync<RecipesScreen> {
  @override
  int get initialTabIndex => _pageIndexOf(ref.read(selectedMealTypeProvider));

  @override
  Widget build(BuildContext context) {
    // Provider -> page: keep the swipe view in sync when the filter changes
    // (chip tap or anywhere else). ref.listen MUST sit at build()'s root.
    ref.listen<MealType?>(selectedMealTypeProvider, (previous, next) {
      syncPageToIndex(_pageIndexOf(next));
    });

    return Scaffold(
      body: Column(
        children: [
          const _MealFilterChips(),
          Expanded(
            // El grid scrollea en vertical y el PageView en horizontal:
            // ejes ortogonales, sin competencia de gestos.
            child: PageView.builder(
              controller: pageController,
              itemCount: MealType.values.length + 1,
              onPageChanged: (index) => ref
                  .read(selectedMealTypeProvider.notifier)
                  .select(_mealTypeAtPage(index)),
              itemBuilder: (context, index) =>
                  _RecipeFilterPage(mealType: _mealTypeAtPage(index)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(RecipeRoutes.form),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// One swipe page: the grid for a single [mealType] filter (`null` = Todas).
///
/// Each page owns its [AppAsyncValueWidget] so the content sliding in during
/// a drag is already the destination filter's, not a copy of the current
/// one. Only the visible page is built, so loading/error/empty still render
/// exactly once.
class _RecipeFilterPage extends ConsumerWidget {
  const _RecipeFilterPage({required this.mealType});

  final MealType? mealType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredRecipes = ref.watch(filteredRecipesProvider(mealType));

    return AppAsyncValueWidget<List<Recipe>>(
      value: filteredRecipes,
      onRetry: () => ref.invalidate(recipeListProvider),
      loadingBuilder: (context) => const _RecipeGridSkeleton(),
      builder: (context, recipes) {
        if (recipes.isEmpty) {
          return const _EmptyRecipes();
        }
        return _RecipeGrid(recipes: recipes);
      },
    );
  }
}

/// The horizontally scrollable filter row.
///
/// Stateful only to keep one [GlobalKey] per chip: with seven chips the row
/// overflows a phone's width, so a swipe to Cena/Aderezo would otherwise
/// leave the selected chip off-screen. [Scrollable.ensureVisible] on a
/// post-frame callback centres it — cheaper and more robust than measuring
/// offsets against a [ScrollController].
class _MealFilterChips extends ConsumerStatefulWidget {
  const _MealFilterChips();

  @override
  ConsumerState<_MealFilterChips> createState() => _MealFilterChipsState();
}

class _MealFilterChipsState extends ConsumerState<_MealFilterChips> {
  late final List<GlobalKey> _chipKeys = List.generate(
    MealType.values.length + 1,
    (_) => GlobalKey(),
  );

  void _revealChip(MealType? mealType) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _chipKeys[_pageIndexOf(mealType)].currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedMealType = ref.watch(selectedMealTypeProvider);

    // Mantiene el chip activo a la vista cuando el filtro cambia por swipe.
    // ref.listen SIEMPRE en el root de build().
    ref.listen<MealType?>(selectedMealTypeProvider, (previous, next) {
      _revealChip(next);
    });

    return Padding(
      padding: MenuarioSpacing.paddingAll8,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              key: _chipKeys[0],
              label: const Text('Todas'),
              selected: selectedMealType == null,
              onSelected: (_) =>
                  ref.read(selectedMealTypeProvider.notifier).select(null),
            ),
            for (final mealType in MealType.values) ...[
              MenuarioSpacing.gapH8,
              ChoiceChip(
                key: _chipKeys[_pageIndexOf(mealType)],
                label: Text(mealType.label),
                selected: selectedMealType == mealType,
                onSelected: (_) => ref
                    .read(selectedMealTypeProvider.notifier)
                    .select(mealType),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecipeGrid extends StatelessWidget {
  const _RecipeGrid({required this.recipes});

  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: MenuarioSpacing.paddingAll16,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: MenuarioSpacing.md,
        crossAxisSpacing: MenuarioSpacing.md,
        // Slightly taller than square so a 2-line name plus the meal chip
        // always fits without overflowing the cell.
        childAspectRatio: 0.85,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) => _RecipeCard(recipe: recipes[index]),
    );
  }
}

/// A disabled recipe stays reachable instead of vanishing from the grid: it
/// renders greyed (via [Opacity]) with a "Desactivada" marker chip. Tapping
/// it ALWAYS navigates to its detail, same as an enabled card — reactivation
/// happens only through the "Activa" switch on the edit form, never as a
/// tap side effect (a synchronous `submit()` call from `InkWell.onTap` used
/// to race the tap ripple's `Ticker` and throw
/// `setState()`/`markNeedsBuild() called during build`).
class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.pushNamed(
          ShellRoutes.recipeDetailName,
          pathParameters: {'id': recipe.id},
        ),
        child: Opacity(
          opacity: recipe.enabled ? 1.0 : 0.5,
          child: Padding(
            padding: MenuarioSpacing.paddingAll16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EmojiAvatar(emoji: recipe.emoji ?? '🍽️', size: 56),
                MenuarioSpacing.gapV4,
                Text(
                  recipe.name,
                  style: MenuarioTypography.h6,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (recipe.mealType != null) ...[
                  MenuarioSpacing.gapV4,
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: MealTypeTag(mealType: recipe.mealType!),
                  ),
                ],
                if (!recipe.enabled) ...[
                  MenuarioSpacing.gapV4,
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Chip(
                      label: const Text('Desactivada'),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.errorContainer,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeGridSkeleton extends StatelessWidget {
  const _RecipeGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: MenuarioSpacing.paddingAll16,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: MenuarioSpacing.md,
        crossAxisSpacing: MenuarioSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _EmptyRecipes extends StatelessWidget {
  const _EmptyRecipes();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: MenuarioSpacing.paddingAll16,
        child: const Text(
          'Aún no tienes recetas. Impórtalas o créalas desde el menú.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
