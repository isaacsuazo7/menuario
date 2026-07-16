import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/recipes/presentation/providers/recipe_form_controller.dart';
import 'package:menuario/src/features/recipes/presentation/widgets/_bom_editor.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('FormGroup shape', () {
    test('name is required and invalid when empty', () {
      final form = makeContainer().read(recipeFormControllerProvider);

      expect(form.control('name').valid, isFalse);
      form.control('name').value = 'Avena';
      expect(form.control('name').valid, isTrue);
    });

    test('enabled defaults to true', () {
      final form = makeContainer().read(recipeFormControllerProvider);

      expect(form.control('enabled').value, isTrue);
    });

    test('emoji, mealType, videos and bomLines default empty/null', () {
      final form = makeContainer().read(recipeFormControllerProvider);

      expect(form.control('emoji').value, anyOf(isNull, isEmpty));
      expect(form.control('mealType').value, isNull);
      expect(form.control('videos').value, isEmpty);
      expect(form.control('bomLines').value, isEmpty);
    });
  });

  group('bomLines validator', () {
    test('invalid when a line has no ingredient picked', () {
      final form = makeContainer().read(recipeFormControllerProvider);
      final bomLines = form.control('bomLines') as FormControl<List<BomDraft>>;

      // Disposal is owned by the controller's autoDispose teardown once the
      // draft is attached to the `bomLines` control (see `RecipeFormController
      // .build`'s `ref.onDispose`) — no separate `addTearDown` here.
      final draft = BomDraft(quantity: 2);
      bomLines.value = [draft];

      expect(bomLines.valid, isFalse);
    });

    test('invalid when a line has an empty/non-positive quantity', () {
      final form = makeContainer().read(recipeFormControllerProvider);
      final bomLines = form.control('bomLines') as FormControl<List<BomDraft>>;

      final draft = BomDraft(ingredientId: 'ing-1');
      bomLines.value = [draft];

      expect(bomLines.valid, isFalse);
    });

    test('valid when every line has an ingredient and a positive quantity', () {
      final form = makeContainer().read(recipeFormControllerProvider);
      final bomLines = form.control('bomLines') as FormControl<List<BomDraft>>;

      final draft = BomDraft(ingredientId: 'ing-1', quantity: 2);
      bomLines.value = [draft];

      expect(bomLines.valid, isTrue);
    });

    test('an empty bomLines list is valid', () {
      final form = makeContainer().read(recipeFormControllerProvider);
      final bomLines = form.control('bomLines') as FormControl<List<BomDraft>>;

      expect(bomLines.valid, isTrue);
    });
  });

  group('videos validator', () {
    test('invalid when a non-empty url does not look like a url', () {
      final form = makeContainer().read(recipeFormControllerProvider);
      final videos = form.control('videos') as FormControl<List<VideoDraft>>;

      videos.value = const [VideoDraft(url: 'not a url')];

      expect(videos.valid, isFalse);
    });

    test('valid when the url looks like a url', () {
      final form = makeContainer().read(recipeFormControllerProvider);
      final videos = form.control('videos') as FormControl<List<VideoDraft>>;

      videos.value = const [VideoDraft(url: 'https://youtu.be/abc')];

      expect(videos.valid, isTrue);
    });

    test('an empty url is valid (row not filled in yet)', () {
      final form = makeContainer().read(recipeFormControllerProvider);
      final videos = form.control('videos') as FormControl<List<VideoDraft>>;

      videos.value = const [VideoDraft()];

      expect(videos.valid, isTrue);
    });
  });

  group('toEntity', () {
    test('builds a Recipe from the current form values', () {
      final container = makeContainer();
      final notifier = container.read(recipeFormControllerProvider.notifier);
      final form = container.read(recipeFormControllerProvider);
      final bomLines = form.control('bomLines') as FormControl<List<BomDraft>>;
      final draft = BomDraft(
        ingredientId: 'ing-1',
        quantity: 3,
        unit: Unit.gram,
      );

      form.control('name').value = '  Avena con leche  ';
      form.control('emoji').value = ' 🥣 ';
      form.control('mealType').value = MealType.desayuno;
      (form.control('videos') as FormControl<List<VideoDraft>>).value = const [
        VideoDraft(source: VideoSource.youtube, url: ' https://youtu.be/x '),
        VideoDraft(),
      ];
      bomLines.value = [draft];

      final recipe = notifier.toEntity('recipe-1');

      expect(recipe.id, 'recipe-1');
      expect(recipe.name, 'Avena con leche');
      expect(recipe.emoji, '🥣');
      expect(recipe.mealType, MealType.desayuno);
      expect(recipe.enabled, isTrue);
      expect(recipe.videos, [
        const VideoLink(source: VideoSource.youtube, url: 'https://youtu.be/x'),
      ]);
      expect(recipe.bomLines, [
        const BomLine(
          recipeId: 'recipe-1',
          ingredientId: 'ing-1',
          quantity: Quantity(value: 3, unit: Unit.gram),
        ),
      ]);
    });

    test('an empty emoji becomes null on the entity', () {
      final container = makeContainer();
      final notifier = container.read(recipeFormControllerProvider.notifier);
      final form = container.read(recipeFormControllerProvider);
      form.control('name').value = 'Sopa';
      form.control('emoji').value = '   ';

      final recipe = notifier.toEntity('recipe-2');

      expect(recipe.emoji, isNull);
    });
  });

  group('prefill', () {
    test('patches every field from an existing Recipe', () {
      final container = makeContainer();
      final notifier = container.read(recipeFormControllerProvider.notifier);
      const recipe = Recipe(
        id: 'r1',
        name: 'Avena',
        emoji: '🥣',
        mealType: MealType.desayuno,
        enabled: false,
        videos: [
          VideoLink(source: VideoSource.youtube, url: 'https://youtu.be/a'),
        ],
        bomLines: [
          BomLine(
            recipeId: 'r1',
            ingredientId: 'ing-1',
            quantity: Quantity(value: 2, unit: Unit.count),
          ),
        ],
      );

      notifier.prefill(recipe);
      final form = container.read(recipeFormControllerProvider);

      expect(form.control('name').value, 'Avena');
      expect(form.control('emoji').value, '🥣');
      expect(form.control('mealType').value, MealType.desayuno);
      expect(form.control('enabled').value, isFalse);
      expect((form.control('videos') as FormControl<List<VideoDraft>>).value, [
        const VideoDraft(
          source: VideoSource.youtube,
          url: 'https://youtu.be/a',
        ),
      ]);
      final bomLines =
          (form.control('bomLines') as FormControl<List<BomDraft>>).value!;
      expect(bomLines, hasLength(1));
      expect(bomLines.single.ingredientId, 'ing-1');
      expect(bomLines.single.quantityController.text, '2');
      expect(bomLines.single.unit, Unit.count);
    });
  });
}
