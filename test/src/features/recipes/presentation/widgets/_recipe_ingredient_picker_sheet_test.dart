import 'package:dartz/dartz.dart' hide State, Unit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/features/recipes/presentation/widgets/_recipe_ingredient_picker_sheet.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:mocktail/mocktail.dart';

class MockIngredientRepository extends Mock implements IngredientRepository {}

/// A mutable box for the `Future<String?>` a `showModalBottomSheet` call
/// resolves with — lets a test read the pop value AFTER interacting with
/// the still-open sheet (the awaited `Future` only resolves once the sheet
/// pops, so it can't be captured via a plain local before then).
class _PickerResultBox {
  String? value;
  bool resolved = false;
}

void main() {
  late MockIngredientRepository mockIngredientRepository;

  const huevo = Ingredient(
    id: 'ing-huevo',
    name: 'Huevo',
    emoji: '🥚',
    category: Category.proteina,
    measurementKind: MeasurementKind.unit,
    booleanTracked: false,
    measurementMode: MeasurementMode.count,
  );
  const leche = Ingredient(
    id: 'ing-leche',
    name: 'Leche',
    emoji: '🥛',
    category: Category.lacteo,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    conversionFactor: 1,
    measurementMode: MeasurementMode.mass,
  );

  setUp(() {
    mockIngredientRepository = MockIngredientRepository();
  });

  /// Pumps a screen with a button that opens [RecipeIngredientPickerSheet]
  /// as a modal bottom sheet and taps it open, behind a [GoRouter] so
  /// [IngredientRoutes.form] is a real, navigable route (mirrors
  /// `recipe_detail_screen_test.dart`'s edit-navigation setup). Returns a
  /// box that captures the sheet's eventual pop value.
  Future<_PickerResultBox> pumpAndOpenSheet(
    WidgetTester tester, {
    String createdIngredientId = 'ing-new',
  }) async {
    final box = _PickerResultBox();
    final router = GoRouter(
      initialLocation: '/host',
      routes: [
        GoRoute(
          path: '/host',
          builder: (context, state) => Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  box.value = await showModalBottomSheet<String?>(
                    context: context,
                    builder: (_) => const RecipeIngredientPickerSheet(),
                  );
                  box.resolved = true;
                },
                child: const Text('open picker'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: IngredientRoutes.form,
          name: IngredientRoutes.form,
          builder: (context, state) =>
              _FakeIngredientFormScreen(returns: createdIngredientId),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ingredientRepositoryProvider.overrideWithValue(
            mockIngredientRepository,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open picker'));
    await tester.pumpAndSettle();

    return box;
  }

  testWidgets('lists ingredients grouped by category', (tester) async {
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([huevo, leche]));

    await pumpAndOpenSheet(tester);

    expect(find.text(Category.proteina.label), findsOneWidget);
    expect(find.text(Category.lacteo.label), findsOneWidget);
    expect(find.text('Huevo'), findsOneWidget);
    expect(find.text('Leche'), findsOneWidget);
  });

  testWidgets('tapping an ingredient pops the sheet with its id', (
    tester,
  ) async {
    when(
      () => mockIngredientRepository.list(),
    ).thenAnswer((_) async => const Right([huevo, leche]));

    final box = await pumpAndOpenSheet(tester);

    await tester.tap(find.text('Leche'));
    await tester.pumpAndSettle();

    expect(box.resolved, isTrue);
    expect(box.value, 'ing-leche');
  });

  testWidgets(
    'Nuevo ingrediente pushes the ingredient form and pops the sheet with '
    'the newly-created id',
    (tester) async {
      when(
        () => mockIngredientRepository.list(),
      ).thenAnswer((_) async => const Right([huevo]));

      final box = await pumpAndOpenSheet(
        tester,
        createdIngredientId: 'ing-new',
      );

      expect(find.text('＋ Nuevo ingrediente'), findsOneWidget);

      await tester.tap(find.text('＋ Nuevo ingrediente'));
      await tester.pumpAndSettle();

      // The fake ingredient form auto-confirms and pops('ing-new'); the
      // sheet must relay that value as its own pop value.
      expect(find.text('open picker'), findsOneWidget);
      expect(box.resolved, isTrue);
      expect(box.value, 'ing-new');
    },
  );
}

/// Stands in for `IngredientFormScreen`: immediately pops with [returns]
/// when built, exercising the picker's `pop(id)` handoff without needing
/// the real ingredient form's fields.
class _FakeIngredientFormScreen extends StatefulWidget {
  const _FakeIngredientFormScreen({required this.returns});

  final String returns;

  @override
  State<_FakeIngredientFormScreen> createState() =>
      _FakeIngredientFormScreenState();
}

class _FakeIngredientFormScreenState extends State<_FakeIngredientFormScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop(widget.returns);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}
