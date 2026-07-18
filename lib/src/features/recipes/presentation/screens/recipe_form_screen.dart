import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/recipes/presentation/providers/ingredients_by_id_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_edit_provider.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_form_controller.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_submission_provider.dart';
import 'package:menuario/src/features/recipes/presentation/widgets/_bom_editor.dart';
import 'package:menuario/src/features/recipes/presentation/widgets/_recipe_ingredient_picker_sheet.dart';
import 'package:menuario/src/shared/presentation/single_emoji_input_formatter.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Best-effort emoji-forward keyboard for the name/emoji fields.
///
/// Flutter's public [TextInputType] (this SDK: 3.44.5) exposes a fixed,
/// index-based set of platform keyboard types with no emoji variant and no
/// way to construct a custom one — there is no supported way to force an
/// emoji keyboard without a platform channel or a third-party plugin. This
/// stays [TextInputType.text] (the default) so the field is ALWAYS fully
/// functional, matching the spec's "MUST remain fully functional where the
/// platform can't force emoji-mode" — the "SHOULD force emoji-mode" half
/// degrades gracefully to a no-op until such a mechanism is added.
const _emojiKeyboardType = TextInputType.text;

/// Full-screen create/edit form for a [Recipe]: state is owned by
/// [RecipeFormController]'s reactive_forms `FormGroup` (name/emoji/
/// mealType/enabled/videos/bomLines), submission by
/// [recipeSubmissionProvider] — mirrors `ingredient_form_screen.dart`'s
/// idiom (prefill guard, validity-gated confirm) built on the TARGET
/// reactive_forms pattern instead of `setState`/`TextEditingController`.
///
/// BOM lines still pick an ingredient via [RecipeIngredientPickerSheet] and
/// a quantity/curated-[Unit] pair via [BomEditorSection] — unchanged in
/// this slice; only their owning state moved into the form.
class RecipeFormScreen extends ConsumerStatefulWidget {
  const RecipeFormScreen({super.key, this.recipeId});

  /// The [Recipe.id] being edited, or `null` when creating.
  final String? recipeId;

  @override
  ConsumerState<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends ConsumerState<RecipeFormScreen> {
  bool _prefilled = false;

  bool get _isEdit => widget.recipeId != null;

  FormGroup get _form => ref.read(recipeFormControllerProvider);

  FormControl<List<VideoDraft>> get _videosControl =>
      _form.control('videos') as FormControl<List<VideoDraft>>;

  FormControl<List<BomDraft>> get _bomLinesControl =>
      _form.control('bomLines') as FormControl<List<BomDraft>>;

  /// Re-validates [_bomLinesControl] whenever a row's quantity text
  /// changes — [BomDraft] keeps its own [TextEditingController] (unchanged
  /// from before this slice), so the form only learns about an edit when
  /// explicitly asked to recompute.
  void _attachBomListener(BomDraft draft) {
    draft.quantityController.addListener(
      () => _bomLinesControl.updateValueAndValidity(),
    );
  }

  void _addVideoRow() {
    final control = _videosControl;
    control.updateValue([...?control.value, const VideoDraft()]);
  }

  void _removeVideoRow(int index) {
    final control = _videosControl;
    final updated = [...?control.value]..removeAt(index);
    control.updateValue(updated);
  }

  void _handleVideoSourceChanged(int index, VideoSource source) {
    final control = _videosControl;
    final updated = [...?control.value];
    updated[index] = updated[index].copyWith(source: source);
    control.updateValue(updated);
  }

  void _handleVideoUrlChanged(int index, String url) {
    final control = _videosControl;
    final updated = [...?control.value];
    updated[index] = updated[index].copyWith(url: url);
    control.updateValue(updated);
  }

  void _addBomRow() {
    final control = _bomLinesControl;
    final draft = BomDraft();
    _attachBomListener(draft);
    control.updateValue([...?control.value, draft]);
  }

  void _removeBomRow(int index) {
    final control = _bomLinesControl;
    final updated = [...?control.value];
    final removed = updated.removeAt(index);
    removed.dispose();
    control.updateValue(updated);
  }

  /// Opens [RecipeIngredientPickerSheet] for the row at [index] and, if the
  /// user picks an ingredient, assigns its id to that row.
  ///
  /// A boolean-tracked pick turns the row "al gusto": [BomDraft.quantityLess]
  /// is set and any quantity typed for a previously-picked ingredient is
  /// cleared, so a stale number can never be submitted on a line that no
  /// longer renders a quantity field.
  Future<void> _pickIngredientForBomRow(int index) async {
    final ingredientId = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      builder: (_) => const RecipeIngredientPickerSheet(),
    );
    if (ingredientId == null || !mounted) return;

    final ingredientsById = ref
        .read(ingredientsByIdProvider)
        .maybeWhen(
          data: (map) => map,
          orElse: () => const <String, Ingredient>{},
        );
    final quantityLess =
        ingredientsById[ingredientId]?.measurementMode ==
        MeasurementMode.boolean;

    final draft = _bomLinesControl.value![index];
    draft.ingredientId = ingredientId;
    draft.quantityLess = quantityLess;
    if (quantityLess) draft.quantityController.clear();
    _bomLinesControl.updateValueAndValidity();
  }

  void _handleBomUnitChanged(int index, Unit unit) {
    _bomLinesControl.value![index].unit = unit;
    _bomLinesControl.updateValueAndValidity();
  }

  /// Mints an id on create (reuses it on edit), builds the [Recipe] from
  /// the form's current values and submits it — success/error/navigation
  /// react to [recipeSubmissionProvider] via the `ref.listen` at the root of
  /// [build].
  Future<void> _handleConfirm() async {
    final repository = ref.read(recipeRepositoryProvider);
    final id = widget.recipeId ?? repository.newId();
    final recipe = ref.read(recipeFormControllerProvider.notifier).toEntity(id);
    await ref.read(recipeSubmissionProvider.notifier).submit(recipe);
  }

  @override
  Widget build(BuildContext context) {
    final editValue = widget.recipeId == null
        ? const AsyncValue<Recipe?>.data(null)
        : ref.watch(recipeEditProvider(widget.recipeId));
    final form = ref.watch(recipeFormControllerProvider);

    // Seed the form once, when the recipe to edit is available. Works whether
    // the value is already cached (immediate) or arrives async (build re-runs
    // on the Loading -> Data transition). Deferred via addPostFrameCallback so
    // we never mutate the FormGroup that ReactiveForm is watching mid-build.
    editValue.whenData((recipe) {
      if (recipe == null || _prefilled) return;
      _prefilled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(recipeFormControllerProvider.notifier).prefill(recipe);
        for (final draft in _bomLinesControl.value ?? const <BomDraft>[]) {
          _attachBomListener(draft);
        }
      });
    });

    // Submission side effects. ref.listen MUST sit at the root of build()
    // (never in initState) — per flutter_riverpod's own docs.
    ref.listen<AsyncValue<void>>(recipeSubmissionProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text((error as FailureException).message)),
          );
        },
        data: (_) {
          if (!mounted) return;
          if (previous is AsyncLoading) Navigator.of(context).pop();
        },
      );
    });

    return ReactiveForm(
      formGroup: form,
      child: Scaffold(
        appBar: AppBar(title: Text(_isEdit ? 'Editar receta' : 'Nueva receta')),
        body: AppAsyncValueWidget<Recipe?>(
          value: editValue,
          onRetry: () => ref.invalidate(recipeEditProvider(widget.recipeId)),
          builder: (context, _) => _RecipeFormBody(
            onAddVideo: _addVideoRow,
            onRemoveVideo: _removeVideoRow,
            onVideoSourceChanged: _handleVideoSourceChanged,
            onVideoUrlChanged: _handleVideoUrlChanged,
            onAddBom: _addBomRow,
            onRemoveBom: _removeBomRow,
            onPickIngredient: _pickIngredientForBomRow,
            onBomUnitChanged: _handleBomUnitChanged,
            onConfirm: _handleConfirm,
          ),
        ),
      ),
    );
  }
}

/// The form's scrollable body: core fields, BOM editor, video list and the
/// cancel/confirm action row — extracted from `build()` into its own
/// widget class per the no-`Widget _foo()`-functions rule.
class _RecipeFormBody extends ConsumerWidget {
  const _RecipeFormBody({
    required this.onAddVideo,
    required this.onRemoveVideo,
    required this.onVideoSourceChanged,
    required this.onVideoUrlChanged,
    required this.onAddBom,
    required this.onRemoveBom,
    required this.onPickIngredient,
    required this.onBomUnitChanged,
    required this.onConfirm,
  });

  final VoidCallback onAddVideo;
  final void Function(int index) onRemoveVideo;
  final void Function(int index, VideoSource source) onVideoSourceChanged;
  final void Function(int index, String url) onVideoUrlChanged;
  final VoidCallback onAddBom;
  final void Function(int index) onRemoveBom;
  final void Function(int index) onPickIngredient;
  final void Function(int index, Unit unit) onBomUnitChanged;
  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredientsByIdValue = ref.watch(ingredientsByIdProvider);

    return SingleChildScrollView(
      padding: MenuarioSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReactiveTextField<String>(
            key: Key('recipe-name-field'),
            formControlName: 'name',
            keyboardType: _emojiKeyboardType,
            decoration: InputDecoration(labelText: 'Nombre'),
          ),
          MenuarioSpacing.gapV16,
          ReactiveTextField<String>(
            key: Key('recipe-emoji-field'),
            formControlName: 'emoji',
            keyboardType: _emojiKeyboardType,
            inputFormatters: const [SingleEmojiInputFormatter()],
            decoration: InputDecoration(labelText: 'Emoji (opcional)'),
          ),
          MenuarioSpacing.gapV16,
          ReactiveValueListenableBuilder<MealType?>(
            formControlName: 'mealType',
            builder: (context, control, child) =>
                DropdownButtonFormField<MealType?>(
                  key: const Key('recipe-meal-type-field'),
                  initialValue: control.value,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de comida',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Sin tipo'),
                    ),
                    for (final mealType in MealType.values)
                      DropdownMenuItem(
                        value: mealType,
                        child: Text(mealType.label),
                      ),
                  ],
                  onChanged: (value) => control.value = value,
                ),
          ),
          MenuarioSpacing.gapV16,
          ReactiveValueListenableBuilder<bool>(
            formControlName: 'enabled',
            builder: (context, control, child) => SwitchListTile(
              key: const Key('recipe-enabled-field'),
              title: const Text('Activa'),
              value: control.value ?? true,
              onChanged: (value) => control.value = value,
            ),
          ),
          MenuarioSpacing.gapV24,
          AppAsyncValueWidget<Map<String, Ingredient>>(
            value: ingredientsByIdValue,
            onRetry: () => ref.invalidate(ingredientsByIdProvider),
            builder: (context, ingredientsById) =>
                ReactiveValueListenableBuilder<List<BomDraft>>(
                  formControlName: 'bomLines',
                  builder: (context, control, child) => BomEditorSection(
                    lines: control.value ?? const [],
                    ingredientsById: ingredientsById,
                    onAddLine: onAddBom,
                    onRemoveLine: onRemoveBom,
                    onPickIngredient: onPickIngredient,
                    onUnitChanged: onBomUnitChanged,
                  ),
                ),
          ),
          MenuarioSpacing.gapV24,
          Text('Videos', style: MenuarioTypography.h5),
          MenuarioSpacing.gapV8,
          ReactiveValueListenableBuilder<List<VideoDraft>>(
            formControlName: 'videos',
            builder: (context, control, child) {
              final videos = control.value ?? const <VideoDraft>[];
              return Column(
                children: [
                  for (var i = 0; i < videos.length; i++)
                    _VideoRow(
                      index: i,
                      draft: videos[i],
                      onSourceChanged: (source) =>
                          onVideoSourceChanged(i, source),
                      onUrlChanged: (url) => onVideoUrlChanged(i, url),
                      onRemove: () => onRemoveVideo(i),
                    ),
                ],
              );
            },
          ),
          TextButton.icon(
            onPressed: onAddVideo,
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
              ReactiveFormConsumer(
                builder: (context, formGroup, child) => FilledButton(
                  onPressed: formGroup.valid ? () => onConfirm() : null,
                  child: const Text('Confirmar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A single video-list row: platform selector + url field + remove button.
///
/// Owns its own seeded [TextEditingController] for the url field (the
/// underlying [VideoDraft] is immutable), reporting edits back via
/// [onUrlChanged] — mirrors [BomDraft]'s row idiom without needing the
/// draft itself to hold controller state.
class _VideoRow extends StatefulWidget {
  const _VideoRow({
    required this.index,
    required this.draft,
    required this.onSourceChanged,
    required this.onUrlChanged,
    required this.onRemove,
  });

  final int index;
  final VideoDraft draft;
  final ValueChanged<VideoSource> onSourceChanged;
  final ValueChanged<String> onUrlChanged;
  final VoidCallback onRemove;

  @override
  State<_VideoRow> createState() => _VideoRowState();
}

class _VideoRowState extends State<_VideoRow> {
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.draft.url);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MenuarioSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<VideoSource>(
              key: Key('recipe-video-source-field-${widget.index}'),
              initialValue: widget.draft.source,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Plataforma'),
              items: [
                for (final source in VideoSource.values)
                  DropdownMenuItem(value: source, child: Text(source.label)),
              ],
              onChanged: (value) {
                if (value != null) widget.onSourceChanged(value);
              },
            ),
          ),
          MenuarioSpacing.gapH8,
          Expanded(
            flex: 3,
            child: TextField(
              key: Key('recipe-video-url-field-${widget.index}'),
              controller: _urlController,
              onChanged: widget.onUrlChanged,
              decoration: const InputDecoration(labelText: 'URL'),
            ),
          ),
          IconButton(
            key: Key('recipe-video-remove-${widget.index}'),
            icon: const Icon(Icons.delete_outline),
            onPressed: widget.onRemove,
          ),
        ],
      ),
    );
  }
}
