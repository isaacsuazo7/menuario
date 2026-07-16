---
paths:
  - "**/presentation/**/*.dart"
  - "**/*_screen.dart"
  - "**/*_form_controller.dart"
---

# Patrones de Formularios (CRÍTICO)

## ⚠️ Patrón OBJETIVO (target)

Este patrón se **adopta en la remediación**; aún **no hay formularios
`reactive_forms` en el repo**. Los formularios actuales
(`recipe_form_screen.dart`, `ingredient_form_screen.dart`, `_set_stock_sheet.dart`,
`cook_schedule_screen.dart`) usan `ConsumerStatefulWidget` + `TextEditingController`
+ `Notifier`. La dependencia `reactive_forms` **debe agregarse a `pubspec.yaml`**
durante la remediación (todavía no está presente).

Referencia de mecánica general del slice (arquitectura, no formularios): el
módulo `features/today/`.

## Form Controller PURO

### ✅ CORRECTO

```dart
// 1. Provider con dependencies declaradas
final recipeFormController =
    NotifierProvider.autoDispose<RecipeFormController, FormGroup>(
      RecipeFormController.new,
      dependencies: const [], // ✅ Declarar dependencies explícito
    );

// 2. Controller PURO (sin side effects en build).
// Riverpod 3 unificó la API: se extiende `Notifier<T>` y el autoDispose va en
// el provider (`NotifierProvider.autoDispose`); `AutoDisposeNotifier` ya NO
// existe como clase base (no compila).
class RecipeFormController extends Notifier<FormGroup> {
  @override
  FormGroup build() {
    return FormGroup(
      {
        'name': FormControl<String>(validators: [Validators.required]),
        'servings': FormControl<int>(
          validators: [Validators.required, Validators.min(1)],
        ),
        'prepMinutes': FormControl<int>(validators: [Validators.min(0)]),
        'notes': FormControl<String>(),
      },
      validators: [_ServingsWithinPrepValidator()], // ✅ Validators inline
    );
  }

  // ✅ Helper para convertir a entidad
  Recipe toEntity() {
    return Recipe(
      name: state.control('name').value as String,
      servings: state.control('servings').value as int,
      prepMinutes: state.control('prepMinutes').value as int? ?? 0,
      notes: state.control('notes').value as String?,
    );
  }
}

// 3. Custom validators como clases privadas
class _ServingsWithinPrepValidator extends Validator<dynamic> {
  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    if (control is! FormGroup) return null;
    final servings = control.control('servings').value as int?;
    final prep = control.control('prepMinutes').value as int?;

    if (servings != null && prep != null && servings > 0 && prep == 0) {
      return {'prepRequiredForServings': true};
    }
    return null;
  }
}
```

### ❌ INCORRECTO - Anti-patrón con side effects

```dart
class BadFormController extends Notifier<FormGroup> {
  @override
  FormGroup build() {
    final form = FormGroup({...});

    // ❌ PROHIBIDO: Side effects en build()
    form.setValidators([_ServingsWithinPrepValidator()]); // Usar validators: []
    _setupListeners(form); // MEMORY LEAK

    return form;
  }

  // ❌ PROHIBIDO: Listeners en controller
  void _setupListeners(FormGroup form) {
    // Estos listeners se crean CADA VEZ que build() se ejecuta
    form.control('servings').valueChanges.listen((_) => recalc());
  }
}
```

## Screen con ConsumerStatefulWidget

### ✅ CORRECTO

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
    _setupFormListeners(); // ✅ Listeners aquí (ejecuta UNA VEZ)
  }

  void _setupFormListeners() {
    final form = ref.read(recipeFormController);

    // ✅ Listeners se crean UNA SOLA VEZ
    form.control('servings').valueChanges.listen((_) => _recalcPortions());
  }

  void _recalcPortions() {
    final form = ref.read(recipeFormController);
    final servings = form.control('servings').value as int?;
    if (servings != null) {
      // ... lógica derivada
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(recipeFormController);

    // ✅ Efecto puntual de submission (NO existe observeForDialogs)
    ref.listen<AsyncValue<void>>(recipeSubmissionProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text((error as FailureException).message)),
        ),
        data: (_) {
          if (previous is AsyncLoading) context.go(AppRoutes.recipes);
        },
      );
    });

    return ReactiveForm(
      formGroup: form,
      child: Scaffold(
        body: Padding(
          padding: MenuarioSpacing.paddingAll16,
          child: Column(
            children: [
              Text('Nueva receta', style: MenuarioTypography.h3),
              MenuarioSpacing.gapV16,
              const ReactiveTextField<String>(formControlName: 'name'),
              // ... más campos
            ],
          ),
        ),
      ),
    );
  }
}
```

### ❌ INCORRECTO - ConsumerWidget sin lifecycle

```dart
// ❌ PROHIBIDO para forms con listeners
class BadScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(recipeFormController);
    // ❌ No hay initState() para setup de listeners
    return ReactiveForm(formGroup: form, child: ...);
  }
}
```

## ReactiveFormConsumer

Para el botón de envío que reacciona a la validez del form, usar
`ReactiveFormConsumer` + un `FilledButton` de Material:

```dart
ReactiveFormConsumer(
  builder: (context, formGroup, child) {
    final isValid = formGroup.valid;

    return FilledButton(
      onPressed: isValid ? () => _submit(formGroup) : null,
      child: const Text('Guardar'),
    );
  },
)
```

## Checklist de Form Controllers

- [ ] Provider con `dependencies: const []` declarado
- [ ] `build()` retorna FormGroup directamente (sin side effects)
- [ ] Validators inline en el constructor de FormGroup
- [ ] Custom validators como clases privadas `_MyValidator`
- [ ] Screen es `ConsumerStatefulWidget`
- [ ] Listeners configurados en `initState()` del screen
- [ ] `toEntity()` helper para convertir form a entidad
- [ ] Botón de envío con `ReactiveFormConsumer` + `FilledButton`
- [ ] Efectos de submission con `ref.listen(submissionProvider, ...)` (NO `observeForDialogs`)
- [ ] `reactive_forms` agregado a `pubspec.yaml`
