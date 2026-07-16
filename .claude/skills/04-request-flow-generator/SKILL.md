---
name: "Generating Feature Slices"
description: "Trigger: new feature vertical, slice scaffolding, form flow in menuario. Generates domain/data/presentation slices (no usecases) with Riverpod dependencies, Either/Failure, target reactive_forms, per features/today/."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Generating Feature Slices

## Cuándo usar

- Al implementar un nuevo feature vertical (recetas, despensa, compras, etc.).
- Para scaffolding de un slice completo: datasource + repository + providers + screen.
- Cuando necesites un flujo con formulario: form + submission + detalle.

> ⚠️ **Sobre formularios**: el patrón de formulario descrito abajo (reactive_forms)
> es un **patrón OBJETIVO** que introduce la remediación. Aún NO hay formularios
> reactive_forms en el repo; los 4 formularios actuales
> (`recipe_form_screen.dart`, `ingredient_form_screen.dart`, `_set_stock_sheet.dart`,
> `cook_schedule_screen.dart`) usan `ConsumerStatefulWidget` + `TextEditingController` +
> `Notifier`. El dep `reactive_forms` debe AÑADIRSE a `pubspec.yaml` durante la
> remediación (todavía no está presente). Para la mecánica general de un slice, la
> referencia real es `features/today/`.

## Gold Standard

**`features/today/` es la fuente de verdad.** Estructura de referencia:

```
features/today/
├── data/
│   ├── datasources/cook_schedule_data_source.dart   (cookScheduleDataSourceProvider)
│   ├── models/cook_schedule_dto.dart (+ .freezed.dart .g.dart), cook_target_dto.dart
│   └── repositories/cook_schedule_repository_impl.dart (CookScheduleRepositoryImpl + provider)
├── domain/
│   ├── entities/cook_schedule.dart (+ .freezed.dart)
│   ├── repositories/cook_schedule_repository.dart    (puerto abstracto)
│   └── value_objects/cook_target.dart
└── presentation/
    ├── models/       (cook_item.dart, day_toggles.dart)   ← view-models de presentación
    ├── providers/    (cook_list_provider, cook_schedule_provider, today_meals_provider, ...)
    ├── screens/      (cook_schedule_screen.dart — ConsumerStatefulWidget)
    ├── widgets/      (_cook_body.dart→_CookBody, today_meal_detail_sheet.dart)
    ├── today_screen.dart
    └── greeting.dart
```

> ⚠️ **Muchos features son solo-presentación**: su `domain`/`data` viven en el shared
> kernel (`lib/src/shared/domain/**`, `lib/src/shared/data/**`). Solo `today` tiene un
> slice domain/data/presentation completo en disco. Decide dónde vive el dominio antes
> de generar carpetas: si el modelo es transversal, va al shared kernel; si es propio
> del feature, va en su slice.

> ⚠️ **NO hay capa usecase** en menuario (no existe ningún `usecases/`). El flujo de
> datos es `Widget → Provider → Repository → DataSource → Firestore`, sin salto UseCase.
> La lógica de negocio vive en `lib/src/shared/domain/services/`
> (`coverage_calculator.dart`, `measurement_converter.dart`, `provisioning_calculator.dart`,
> `stock_lens_service.dart`).

## Workflow

### Paso 1: Análisis del Requerimiento

Preguntas clave:
1. ¿El dominio es propio del feature o transversal (shared kernel)?
2. Campos del formulario y validaciones de negocio.
3. Colección/documento de Firestore a leer/escribir.
4. Estados de UI (lista, detalle, edición).

### Paso 2: Domain Layer

**Orden:** Entity (Freezed) → Repository Interface (puerto abstracto). **Sin UseCases.**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe.freezed.dart';

@freezed
abstract class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required String name,
    required int servings,
    @Default(true) bool enabled,
  }) = _Recipe;

  const Recipe._();

  bool get isValid => name.isNotEmpty && servings > 0;
}
```

El puerto abstracto vive en `domain/repositories/` y devuelve `Either<Failure, T>`:

```dart
import 'package:dartz/dartz.dart' hide Unit;
import 'package:menuario/src/core/error/failure.dart';

abstract class RecipeRepository {
  Future<Either<Failure, List<Recipe>>> watchRecipes();
  Future<Either<Failure, Recipe?>> findById(String id);
  Future<Either<Failure, Unit>> save(Recipe recipe);
}
```

### Paso 3: Data Layer

**Orden:** DTO (Freezed + json_serializable, con mappers `fromEntity`/`toEntity`) →
DataSource (provider con `dependencies:`) → Repository Implementation.

DTO — clase `*DTO`, archivo `*_dto.dart`. Para reglas de DTOs: ver `rules/patterns/dtos.md`.

```dart
// recipe_dto.dart — el id NO se persiste en el DTO: viene del doc de Firestore
@freezed
abstract class RecipeDTO with _$RecipeDTO {
  const factory RecipeDTO({
    required String name,
    required int servings,
    @Default(true) bool enabled,
  }) = _RecipeDTO;

  const RecipeDTO._();

  factory RecipeDTO.fromJson(Map<String, dynamic> json) => _$RecipeDTOFromJson(json);
  factory RecipeDTO.fromEntity(Recipe e) =>
      RecipeDTO(name: e.name, servings: e.servings, enabled: e.enabled);

  Recipe toEntity({required String id}) =>
      Recipe(id: id, name: name, servings: servings, enabled: enabled);
}
```

DataSource y Repository providers declaran SIEMPRE `dependencies:` (ver Paso 4).

### Paso 4: Providers / DI (dependencies: OBLIGATORIO)

`dependencies:` es obligatorio en TODO provider. Rationale en menuario = **overridabilidad
en tests** (mockear Firebase/auth en `ProviderContainer`). Providers sin `ref` declaran
`dependencies: const []`.

Cadena de DI real (SIN salto usecase):

```
firebaseFirestoreProvider  +  currentUidProvider        (core/firebase, core/auth)
   → recipeDataSourceProvider   dependencies: [firebaseFirestoreProvider, currentUidProvider]
   → recipeRepositoryProvider   dependencies: [recipeDataSourceProvider]   (RepositoryImpl)
   → controller / list / detail / submission providers  dependencies: [recipeRepositoryProvider, ...]
```

Providers reales de referencia (todos declaran `dependencies:`):

```dart
// FutureProvider.family: lee vía repositorio, sin usecase
final recipeEditProvider = FutureProvider.autoDispose.family<Recipe?, String?>(
  (ref, id) async {
    if (id == null) return null;
    final repo = ref.watch(recipeRepositoryProvider);
    final result = await repo.findById(id);
    return result.fold((f) => throw FailureException(f), (r) => r);
  },
  dependencies: [recipeRepositoryProvider],
  retry: (_, __) => null,
);
```

Otros nombres reales verificados: `recipeDataSourceProvider`
(deps `[firebaseFirestoreProvider, currentUidProvider]`), `recipeRepositoryProvider`
(deps `[recipeDataSourceProvider]`), `todayMealsProvider`
(deps `[planControllerProvider, recipeListProvider, todayProvider]`),
`pantryControllerProvider` (deps `[pantryRepositoryProvider, ingredientRepositoryProvider]`).

### Paso 5: Submission Provider

Notifier con `AsyncValue<void>`, `dependencies:` al repositorio, y guarda `if (!ref.mounted) return;`.
Referencia real: `lib/src/features/auth/presentation/providers/sign_in_submission_provider.dart:40-47`.

```dart
final recipeSubmissionProvider =
    NotifierProvider.autoDispose<RecipeSubmissionNotifier, AsyncValue<void>>(
  RecipeSubmissionNotifier.new,
  dependencies: [recipeRepositoryProvider],
);

class RecipeSubmissionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> submit(Recipe recipe) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(recipeRepositoryProvider);
      final result = await repo.save(recipe);
      result.fold((f) => throw FailureException(f), (_) {});
      if (!ref.mounted) return;
      state = const AsyncData(null);
    } on FailureException catch (e, st) {
      if (!ref.mounted) return;
      state = AsyncError(e, st);
    } on Exception catch (e, st) {
      if (!ref.mounted) return;
      state = AsyncError(FailureException(Failure(message: e.toString())), st);
    }
  }
}
```

No existe `observeForDialogs`: el éxito/error se surface observando el `AsyncValue`
del submission en la screen (`ref.listen` / `AppAsyncValueWidget`).

### Paso 6: Form Controller (patrón OBJETIVO — reactive_forms)

> Recordatorio: reactive_forms es el estándar OBJETIVO de la remediación. Debe añadirse
> a `pubspec.yaml`. Mantén el FormGroup genérico/agnóstico al feature.

```dart
import 'package:reactive_forms/reactive_forms.dart';

final recipeFormControllerProvider =
    NotifierProvider.autoDispose<RecipeFormController, FormGroup>(
  RecipeFormController.new,
  dependencies: const [],
);

class RecipeFormController extends Notifier<FormGroup> {
  @override
  FormGroup build() {
    return FormGroup({
      'name': FormControl<String>(validators: [Validators.required]),
      'servings': FormControl<int>(validators: [Validators.required, Validators.min(1)]),
    }, validators: [_RecipeFormValidator()]);
  }

  Recipe toEntity() => Recipe(
        id: '',
        name: state.control('name').value as String,
        servings: state.control('servings').value as int,
      );
}
```

Validador de negocio custom:

```dart
class _RecipeFormValidator extends Validator<dynamic> {
  const _RecipeFormValidator();

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    final servings = control.findControl('servings')?.value as int?;
    if (servings != null && servings <= 0) return {'invalidServings': true};
    return null;
  }
}
```

### Paso 7: Screen (ConsumerStatefulWidget)

```dart
class RecipeFormScreen extends ConsumerStatefulWidget {
  const RecipeFormScreen({super.key});

  @override
  ConsumerState<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends ConsumerState<RecipeFormScreen> {
  @override
  void initState() {
    super.initState();
    final form = ref.read(recipeFormControllerProvider);
    form.control('servings').valueChanges.listen((_) => _recalculate());
  }

  void _recalculate() {/* ... */}

  @override
  Widget build(BuildContext context) {
    // Éxito/error del submission — NO existe observeForDialogs.
    ref.listen(recipeSubmissionProvider, (prev, next) {
      next.whenOrNull(
        data: (_) => context.go('/recipes'),
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text((e as FailureException).message)),
        ),
      );
    });

    return ReactiveForm(
      formGroup: ref.watch(recipeFormControllerProvider),
      child: Scaffold(
        appBar: AppBar(title: const Text('Nueva receta')),
        body: SingleChildScrollView(
          padding: MenuarioSpacing.paddingAll16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ReactiveTextField<String>(formControlName: 'name'),
              MenuarioSpacing.gapV16,
              const ReactiveTextField<int>(formControlName: 'servings'),
              MenuarioSpacing.gapV24,
              ReactiveFormConsumer(
                builder: (context, form, _) => FilledButton(
                  onPressed: form.valid
                      ? () => ref.read(recipeSubmissionProvider.notifier)
                          .submit(ref.read(recipeFormControllerProvider.notifier).toEntity())
                      : null,
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Notas de UI menuario:
- Botones = `FilledButton` / `TextButton` / `IconButton` crudos 
- Spacing/typography SIEMPRE cualificados: `MenuarioSpacing.gapV16`, `MenuarioTypography.h3`.
- Para `AsyncValue`, usa `AppAsyncValueWidget<T>` (param `builder`, NO `data`/`error`).
- Sheets = `showModalBottomSheet<T>(...)` abriendo un widget privado `_`. No hay helper.

### Paso 8: Testing

Tests requeridos: Entity, Repository (con `fake_cloud_firestore`), Provider (submission),
Widget (screen). Mock con `mocktail` contra los puertos de repositorio y overrides de
`firebaseFirestoreProvider` / `currentUidProvider` en `ProviderContainer`.
Para patrones: ver Skill `/03-testing-patterns`.

### Paso 9: Integración

- Registrar la ruta en el router (go_router, `lib/src/core/routing/`).
- Navegación: `context.go(...)` / `context.push(...)` / `context.pop()`.
- Invalidar el provider de lista tras un submit exitoso (`ref.invalidate(recipeListProvider)`).

## Script de Generación

```bash
./scripts/generate_feature_slice.sh <FeatureName>
# Ejemplo: ./scripts/generate_feature_slice.sh Recipe
```

## Referencias

- Slice de referencia: `lib/src/features/today/**`
- Error handling: `lib/src/core/error/` (`Failure`, `FailureException`) — ver `rules/shared/error-handling.md`
- Componentes UI: Skill `/05-ui-components-guide`
- Testing: Skill `/03-testing-patterns`
