import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/features/recipes/presentation/widgets/_bom_editor.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// A single video-list row's immutable draft state: the platform selector
/// and its url.
///
/// Immutable (unlike [BomDraft]) so it can live directly as a
/// `FormControl<List<VideoDraft>>` value: the row widget that renders it
/// owns its own seeded [TextEditingController] and reports edits back via
/// `copyWith` + an updated list, instead of the draft owning mutable
/// controller state itself.
@immutable
class VideoDraft {
  const VideoDraft({this.source = VideoSource.youtube, this.url = ''});

  final VideoSource source;
  final String url;

  VideoDraft copyWith({VideoSource? source, String? url}) =>
      VideoDraft(source: source ?? this.source, url: url ?? this.url);

  @override
  bool operator ==(Object other) =>
      other is VideoDraft && other.source == source && other.url == url;

  @override
  int get hashCode => Object.hash(source, url);
}

bool _looksLikeUrl(String url) =>
    url.isNotEmpty && (url.startsWith('http') || url.contains('.'));

/// Rejects a [FormControl]`<List<VideoDraft>>` when any non-empty url does
/// not look like a url — empty rows (not filled in yet) are always valid.
class _VideoUrlsValidator extends Validator<dynamic> {
  const _VideoUrlsValidator();

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    final videos = control.value as List<VideoDraft>? ?? const [];
    for (final draft in videos) {
      final url = draft.url.trim();
      if (url.isEmpty) continue;
      if (!_looksLikeUrl(url)) return {'invalidVideoUrl': true};
    }
    return null;
  }
}

/// Rejects a [FormControl]`<List<BomDraft>>` when any line is missing its
/// picked ingredient or carries an empty/non-positive quantity — an empty
/// list (no lines yet) is always valid.
///
/// A [BomDraft.quantityLess] line is exempt from the quantity check: an
/// "al gusto" condiment is complete with nothing but its ingredient.
class _BomLinesValidator extends Validator<dynamic> {
  const _BomLinesValidator();

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    final lines = control.value as List<BomDraft>? ?? const [];
    for (final draft in lines) {
      if (draft.ingredientId == null) return {'invalidBomLine': true};
      if (draft.quantityLess) continue;

      final quantity = num.tryParse(draft.quantityController.text.trim());
      if (quantity == null || quantity <= 0) {
        return {'invalidBomLine': true};
      }
    }
    return null;
  }
}

/// Owns the recipe create/edit [FormGroup] — name/emoji/mealType/enabled as
/// simple controls, `videos`/`bomLines` as opaque `FormControl<List<T>>`
/// mutated immutably by the screen's row callbacks (see
/// `recipe_form_screen.dart`).
///
/// `dependencies: const []` — the controller reads/writes only its own
/// form state, no other provider.
final recipeFormControllerProvider =
    NotifierProvider.autoDispose<RecipeFormController, FormGroup>(
      RecipeFormController.new,
      dependencies: const [],
    );

class RecipeFormController extends Notifier<FormGroup> {
  @override
  FormGroup build() {
    final form = FormGroup({
      'name': FormControl<String>(validators: [Validators.required]),
      'emoji': FormControl<String>(value: ''),
      'mealType': FormControl<MealType?>(),
      'enabled': FormControl<bool>(value: true),
      'videos': FormControl<List<VideoDraft>>(
        value: const [],
        validators: [const _VideoUrlsValidator()],
      ),
      'bomLines': FormControl<List<BomDraft>>(
        value: const [],
        validators: [const _BomLinesValidator()],
      ),
    });

    ref.onDispose(() {
      final bomLines =
          (form.control('bomLines') as FormControl<List<BomDraft>>).value ??
          const [];
      for (final draft in bomLines) {
        draft.dispose();
      }
    });

    return form;
  }

  /// Copies [recipe]'s fields into the form, once — mirrors the previous
  /// `_RecipeFormScreenState._prefill` (edit-mode prefill guard lives in
  /// the screen, which calls this only the first time the recipe loads).
  void prefill(Recipe recipe) {
    state.control('name').value = recipe.name;
    state.control('emoji').value = recipe.emoji ?? '';
    state.control('mealType').value = recipe.mealType;
    state.control('enabled').value = recipe.enabled;
    (state.control('videos') as FormControl<List<VideoDraft>>).value = [
      for (final video in recipe.videos)
        VideoDraft(source: video.source, url: video.url),
    ];
    (state.control('bomLines') as FormControl<List<BomDraft>>).value = [
      for (final line in recipe.bomLines)
        BomDraft(
          ingredientId: line.ingredientId,
          quantity: line.quantity?.value,
          unit: line.quantity?.unit,
          quantityLess: line.quantity == null,
        ),
    ];
  }

  /// Builds the [Recipe] for [id] from the form's current values — only
  /// meaningful once the form is valid (every video url looks like a url,
  /// every BOM line has a picked ingredient and, unless it is "al gusto",
  /// a positive quantity).
  Recipe toEntity(String id) {
    final name = (state.control('name').value as String? ?? '').trim();
    final emoji = (state.control('emoji').value as String? ?? '').trim();
    final videos =
        (state.control('videos').value as List<VideoDraft>? ?? const [])
            .where((draft) => draft.url.trim().isNotEmpty)
            .map(
              (draft) => VideoLink(source: draft.source, url: draft.url.trim()),
            )
            .toList();
    final bomLines = [
      for (final draft
          in state.control('bomLines').value as List<BomDraft>? ?? const [])
        BomLine(
          recipeId: id,
          ingredientId: draft.ingredientId!,
          quantity: draft.quantityLess
              ? null
              : Quantity(
                  value: num.parse(draft.quantityController.text.trim()),
                  unit: draft.unit,
                ),
        ),
    ];

    return Recipe(
      id: id,
      name: name,
      emoji: emoji.isEmpty ? null : emoji,
      mealType: state.control('mealType').value as MealType?,
      bomLines: bomLines,
      videos: videos,
      enabled: state.control('enabled').value as bool? ?? true,
    );
  }
}
