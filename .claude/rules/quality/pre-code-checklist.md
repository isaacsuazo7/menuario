---
paths:
  - "**/*.dart"
---

# Checklist Pre-Código

## Antes de Escribir Código Nuevo

### 1. Buscar Componentes Existentes

Antes de crear algo nuevo, verificar si ya existe:

```
lib/src/shared/presentation/widgets/   # Widget compartido: AppAsyncValueWidget (el único)
lib/src/core/theme/                     # MenuarioSpacing, MenuarioTypography, ColorScheme, extensiones
lib/src/shared/domain/services/         # Lógica de dominio (CoverageCalculator, MeasurementConverter, etc.)
```

Se usan
widgets Material crudos (`FilledButton`, `TextField`, `Card`, `showModalBottomSheet`...).

### 2. Verificar Gold Standard

Para nuevos slices verticales, usar el módulo `features/today/` como referencia:
- Provider: `features/today/presentation/providers/cook_schedule_provider.dart`
- Screen: `features/today/presentation/screens/cook_schedule_screen.dart` (`ConsumerStatefulWidget`)
- DTO: `features/today/data/models/cook_schedule_dto.dart` (`CookScheduleDTO`)
- Repository: `features/today/data/repositories/cook_schedule_repository_impl.dart`
- DataSource: `features/today/data/datasources/cook_schedule_data_source.dart`
- Puerto abstracto: `features/today/domain/repositories/cook_schedule_repository.dart`

Nota: la mayoría de features son solo presentación; su `domain`/`data` vive en el shared
kernel (`lib/src/shared/domain/**`, `lib/src/shared/data/**`). Solo `today` tiene el slice
completo en disco.

### 3. Checklist de Provider

- [ ] ¿Usa `ref.watch()` o `ref.read()`? → Agregar `dependencies: [...]`
- [ ] ¿Es Provider.family? → SIEMPRE agregar dependencies
- [ ] ¿No usa ref? → Agregar `dependencies: const []` explícito
- [ ] ¿Tiene múltiples ref.watch? → Listar TODAS las dependencias
- [ ] La cadena DI es `firebaseFirestoreProvider`/`currentUidProvider` → DataSource → Repository → controller/list/detail/submission (NO hay capa UseCase)

### 4. Checklist de Form Controller (patrón OBJETIVO)

> reactive_forms es el patrón **objetivo** de formularios (se adopta en la remediación).
> Aún no hay formularios reactive_forms en el repo y la dependencia todavía no está en
> `pubspec.yaml`. Mecánica general de slice: `features/today/`.

- [ ] ¿Tiene `dependencies: const []` declarado?
- [ ] ¿`build()` retorna `FormGroup` directamente?
- [ ] ¿Validators están inline en el constructor?
- [ ] ¿Custom validators son clases privadas (`_XxxValidator extends Validator`)?
- [ ] ¿Tiene método `toEntity()`?

### 5. Checklist de Screen con Form (patrón OBJETIVO)

- [ ] ¿Es `ConsumerStatefulWidget`?
- [ ] ¿Listeners están en `initState()`?
- [ ] ¿Observa la submission con `ref.listen(submissionProvider, ...)` o mirando su `AsyncValue` para mostrar SnackBar/diálogo en éxito/error? (No existe `observeForDialogs`.)

### 6. Checklist de DTO

- [ ] ¿Es Freezed + json_serializable, archivo `*_dto.dart`, clase `*DTO`?
- [ ] ¿Tiene `fromEntity()` static method?
- [ ] ¿Tiene `toEntity()` extension method?
- [ ] ¿Extension se llama `DTONameX`?

### 7. Checklist de Submission Provider

- [ ] ¿Es `NotifierProvider.autoDispose`?
- [ ] ¿Extends `Notifier<AsyncValue<void>>`?
- [ ] ¿`build()` retorna `const AsyncData(null)`?
- [ ] ¿Dependencies incluyen el Repository y los providers a invalidar? (NO hay UseCase)
- [ ] ¿Tiene `if (!ref.mounted) return;` después de cada `await`?
- [ ] ¿Catch separado para `FailureException` y luego `Exception`?
- [ ] ¿Refresca/invalida el provider relacionado después del éxito?

## Durante el Código

### 8. Formato

- [ ] ¿Líneas ≤ 80 caracteres?
- [ ] ¿Trailing commas en argumentos multi-línea?
- [ ] ¿`const` constructors donde sea posible?

### 9. Imports

- [ ] ¿Todos son package imports (`package:menuario/src/...`)?
- [ ] ¿Ningún import relativo?
- [ ] ¿Orden correcto? (dart → flutter → externos → proyecto)

### 10. Widgets

- [ ] ¿Usa `AppAsyncValueWidget` para AsyncValue? (recuerda: su callback se llama `builder`)
- [ ] ¿Usa constantes de spacing cualificadas (`MenuarioSpacing.gapH16`, `MenuarioSpacing.paddingAll16`)?
- [ ] ¿Usa `SizedBox` en lugar de `Container` para spacing?
- [ ] ¿Widgets privados son clases, no funciones?

## Antes de Commit

### 11. Verificación Final

```bash
# Análisis estático
fvm flutter analyze

# Tests
fvm flutter test

# Generación de código (si modificaste modelos Freezed/JSON)
fvm dart run build_runner build --delete-conflicting-outputs
```

### 12. Revisión de Dependencies

Verificar que todos los providers nuevos tengan `dependencies` declaradas
(por overridability en tests: mockear `firebaseFirestoreProvider`/`currentUidProvider`
o los repository providers en un `ProviderContainer`).

## Referencia Rápida de Patrones

### Provider con Dependencies
```dart
final myProvider = Provider<MyClass>((ref) {
  return MyClass(ref.watch(depProvider));
}, dependencies: [depProvider]);
```

### Form Controller (objetivo: reactive_forms)
```dart
final formController = NotifierProvider.autoDispose<Controller, FormGroup>(
  Controller.new,
  dependencies: const [],
);
```

### Submission Provider
```dart
final submissionProvider =
    NotifierProvider.autoDispose<SubmissionNotifier, AsyncValue<void>>(
  SubmissionNotifier.new,
  dependencies: [recipeRepositoryProvider, recipeListProvider],
);
```

### DTO Bidireccional
```dart
// Entity → DTO
static EntityDTO fromEntity(Entity entity) { ... }

// DTO → Entity
extension EntityDTOX on EntityDTO {
  Entity toEntity() { ... }
}
```
