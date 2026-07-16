import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/recipes/presentation/providers/ingredients_by_id_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_edit_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/filtered_recipes_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_list_provider.dart';
import 'package:menuario/src/shared/shared.dart';

/// A single video-list row's editable draft state: the platform selector
/// and its url [TextEditingController].
class _VideoDraft {
  _VideoDraft({this.source = VideoSource.youtube, String url = ''})
    : urlController = TextEditingController(text: url);

  VideoSource source;
  final TextEditingController urlController;
}

/// Full-screen create/edit form for a [Recipe], mirroring
/// `ingredient_form_screen.dart`'s idiom (prefill guard, `_canConfirm`
/// gate, atomic save -> invalidate -> pop).
///
/// PR2 scope: core fields (name/emoji/mealType/enabled) + video list only.
/// BOM editing is PR3 — any existing [Recipe.bomLines] are prefilled once
/// and round-tripped unchanged on save, never rendered or mutated here.
class RecipeFormScreen extends ConsumerStatefulWidget {
  const RecipeFormScreen({super.key, this.recipeId});

  /// The [Recipe.id] being edited, or `null` when creating.
  final String? recipeId;

  @override
  ConsumerState<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends ConsumerState<RecipeFormScreen> {
  final _nameController = TextEditingController();
  final _emojiController = TextEditingController();

  MealType? _mealType;
  bool _enabled = true;
  final List<_VideoDraft> _videos = [];

  /// The recipe's existing [Recipe.bomLines], carried through unchanged —
  /// BOM editing ships in PR3.
  List<BomLine> _bomLines = const [];

  bool _prefilled = false;

  bool get _isEdit => widget.recipeId != null;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_handleFieldChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    for (final video in _videos) {
      video.urlController.dispose();
    }
    super.dispose();
  }

  void _handleFieldChanged() => setState(() {});

  /// Copies [recipe]'s fields into local state, once. Mirrors
  /// `_IngredientFormScreenState._prefill`.
  void _prefill(Recipe recipe) {
    _prefilled = true;
    _nameController.removeListener(_handleFieldChanged);

    _nameController.text = recipe.name;
    _emojiController.text = recipe.emoji ?? '';
    _mealType = recipe.mealType;
    _enabled = recipe.enabled;
    _bomLines = recipe.bomLines;
    for (final video in recipe.videos) {
      _videos.add(
        _VideoDraft(source: video.source, url: video.url)
          ..urlController.addListener(_handleFieldChanged),
      );
    }

    _nameController.addListener(_handleFieldChanged);
  }

  void _addVideoRow() {
    setState(() {
      _videos.add(
        _VideoDraft()..urlController.addListener(_handleFieldChanged),
      );
    });
  }

  void _removeVideoRow(int index) {
    final removed = _videos.removeAt(index);
    removed.urlController.removeListener(_handleFieldChanged);
    removed.urlController.dispose();
    setState(() {});
  }

  bool _isValidUrl(String url) =>
      url.isNotEmpty && (url.startsWith('http') || url.contains('.'));

  bool get _canConfirm {
    if (_nameController.text.trim().isEmpty) return false;

    for (final video in _videos) {
      final url = video.urlController.text.trim();
      if (url.isEmpty) continue;
      if (!_isValidUrl(url)) return false;
    }

    return true;
  }

  /// The [VideoLink]s built from [_videos], dropping empty rows.
  List<VideoLink> get _resolvedVideos => [
    for (final video in _videos)
      if (video.urlController.text.trim().isNotEmpty)
        VideoLink(source: video.source, url: video.urlController.text.trim()),
  ];

  /// Builds the [Recipe] (minting an id on create, reusing it on edit) and
  /// commits it via [RecipeRepository.save]. On success, pops the form and
  /// invalidates the read surfaces that must reflect it; on `Left(Failure)`,
  /// shows a `SnackBar` and stays on the form.
  Future<void> _handleConfirm() async {
    final repository = ref.read(recipeRepositoryProvider);
    final id = widget.recipeId ?? repository.newId();

    final recipe = Recipe(
      id: id,
      name: _nameController.text.trim(),
      emoji: _emojiController.text.trim().isEmpty
          ? null
          : _emojiController.text.trim(),
      mealType: _mealType,
      bomLines: _bomLines,
      videos: _resolvedVideos,
      enabled: _enabled,
    );

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final result = await repository.save(recipe);

    if (!mounted) return;

    result.fold(
      (failure) =>
          messenger.showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ref.invalidate(recipeListProvider);
        ref.invalidate(filteredRecipesProvider);
        ref.invalidate(ingredientsByIdProvider);
        navigator.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final editValue = widget.recipeId == null
        ? const AsyncValue<Recipe?>.data(null)
        : ref.watch(recipeEditProvider(widget.recipeId));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar receta' : 'Nueva receta'),
      ),
      body: AppAsyncValueWidget<Recipe?>(
        value: editValue,
        onRetry: () => ref.invalidate(recipeEditProvider(widget.recipeId)),
        builder: (context, recipe) {
          if (recipe != null && !_prefilled) {
            _prefill(recipe);
          }
          return _buildForm(context);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: MenuarioSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('recipe-name-field'),
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          MenuarioSpacing.gapV16,
          TextField(
            key: const Key('recipe-emoji-field'),
            controller: _emojiController,
            decoration: const InputDecoration(labelText: 'Emoji (opcional)'),
          ),
          MenuarioSpacing.gapV16,
          DropdownButtonFormField<MealType?>(
            key: const Key('recipe-meal-type-field'),
            initialValue: _mealType,
            decoration: const InputDecoration(labelText: 'Tipo de comida'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Sin tipo')),
              for (final mealType in MealType.values)
                DropdownMenuItem(value: mealType, child: Text(mealType.label)),
            ],
            onChanged: (value) => setState(() => _mealType = value),
          ),
          MenuarioSpacing.gapV16,
          SwitchListTile(
            key: const Key('recipe-enabled-field'),
            title: const Text('Activa'),
            value: _enabled,
            onChanged: (value) => setState(() => _enabled = value),
          ),
          MenuarioSpacing.gapV24,
          Text('Videos', style: MenuarioTypography.h5),
          MenuarioSpacing.gapV8,
          for (var i = 0; i < _videos.length; i++) _buildVideoRow(i),
          TextButton.icon(
            onPressed: _addVideoRow,
            icon: const Icon(Icons.add),
            label: const Text('Agregar video'),
          ),
          MenuarioSpacing.gapV24,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              MenuarioSpacing.gapH8,
              FilledButton(
                onPressed: _canConfirm ? _handleConfirm : null,
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoRow(int index) {
    final video = _videos[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: MenuarioSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<VideoSource>(
              key: Key('recipe-video-source-field-$index'),
              initialValue: video.source,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Plataforma'),
              items: [
                for (final source in VideoSource.values)
                  DropdownMenuItem(value: source, child: Text(source.label)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => video.source = value);
              },
            ),
          ),
          MenuarioSpacing.gapH8,
          Expanded(
            flex: 3,
            child: TextField(
              key: Key('recipe-video-url-field-$index'),
              controller: video.urlController,
              decoration: const InputDecoration(labelText: 'URL'),
            ),
          ),
          IconButton(
            key: Key('recipe-video-remove-$index'),
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _removeVideoRow(index),
          ),
        ],
      ),
    );
  }
}
