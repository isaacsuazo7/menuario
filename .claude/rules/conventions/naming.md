---
paths:
  - "**/*.dart"
---

# Convenciones de Nomenclatura

## Tabla de Referencia

| Elemento | Patrón | Ejemplo |
|----------|--------|---------|
| **Entity** | Nombre simple | `CookSchedule` |
| **DTO** | Nombre + DTO | `CookScheduleDTO` |
| **DTO Extension** | DTOName + X | `CookScheduleDTOX` |
| **DataSource** | Feature + DataSource | `CookScheduleDataSource` |
| **Repository Interface** | Feature + Repository | `RecipeRepository` |
| **Repository Impl** | Feature + RepositoryImpl | `RecipeRepositoryImpl` |
| **Repository Provider** | feature + RepositoryProvider | `recipeRepositoryProvider` |
| **Domain Service** | Sustantivo descriptivo | `CoverageCalculator`, `MeasurementConverter` |
| **List Provider** | feature + Provider | `recipeListProvider` |
| **Detail/Edit Provider** | feature + Edit/DetailProvider | `recipeEditProvider` |
| **Submission Provider** | acción + SubmissionProvider | `signInSubmissionProvider` |
| **Screen** | Nombre + Screen | `RecipeFormScreen` |
| **View-model** | Sustantivo simple | `CookItem`, `PantryRow` |
| **Widget privado** | _Nombre | `_CookBody`, `_TodayHeader` |

> **No existe capa de use cases.** La lógica de negocio se nombra como un
> **domain Service** (`CoverageCalculator`, `MeasurementConverter`) y vive en
> `lib/src/shared/domain/services/`. No usar sufijo `UseCase`.

## Archivos

| Tipo | Patrón | Ejemplo |
|------|--------|---------|
| Entity | `nombre.dart` | `cook_schedule.dart` |
| DTO | `nombre_dto.dart` | `cook_schedule_dto.dart` |
| DataSource | `feature_data_source.dart` | `cook_schedule_data_source.dart` |
| Repository | `feature_repository.dart` | `recipe_repository.dart` |
| Repository Impl | `feature_repository_impl.dart` | `recipe_repository_impl.dart` |
| Domain Service | `nombre.dart` | `coverage_calculator.dart` |
| Provider | `nombre_provider.dart` | `today_meals_provider.dart` |
| Screen | `nombre_screen.dart` | `recipe_form_screen.dart` |
| View-model | `nombre.dart` (en `presentation/models/`) | `cook_item.dart` |

### Nomenclatura de Archivos: privacidad

- **Widgets privados** PUEDEN vivir en archivos `_nombre.dart` (con clase
  `_PascalCase`). Es una convención real y aceptada en `today/`:
  `_cook_body.dart` → `class _CookBody`, `_today_header.dart` → `class _TodayHeader`.
- **Screens y sheets que son puntos de entrada** deben usar snake_case plano,
  sin prefijo `_` en el archivo (ej: `today_meal_detail_sheet.dart`,
  `recipe_form_screen.dart`). La privacidad se expresa con la **clase** `_PascalCase`
  cuando aplique, no con el nombre del archivo de entrada.
- Nombres tipo `_set_stock_sheet.dart` o `_bom_editor.dart` (archivo de entrada
  con prefijo `_`) son candidatos a renombrar a snake_case plano.

## Providers

### Nomenclatura según Tipo

```dart
// Repositorios / datasources (instancias de clase)
final recipeRepositoryProvider = Provider<RecipeRepository>(...);

// Listas
final recipeListProvider = AsyncNotifierProvider<RecipeListNotifier, List<Recipe>>(...);

// Detalle / edición por ID
final recipeEditProvider = FutureProvider.family<Recipe?, String?>(...);

// Submissions
final signInSubmissionProvider =
    NotifierProvider.autoDispose<SignInSubmissionNotifier, AsyncValue<void>>(...);

// Estado simple
final todayTabProvider = NotifierProvider<TodayTabNotifier, TodayTab>(...);
```

Todo provider declara `dependencies:` (los que no usan `ref` declaran
`dependencies: const []`).

## Clases Privadas

### Widgets Privados en Screens
Usar prefijo `_` y nombres descriptivos:

```dart
class RecipeFormScreen extends ConsumerStatefulWidget { ... }

class _CookBody extends ConsumerWidget { ... }
class _EatBody extends StatelessWidget { ... }
class _TodayHeader extends StatelessWidget { ... }
```

### Validators Privados
Cuando se adopte `reactive_forms`, los validators custom van como clases privadas:

```dart
class _RequiredNameValidator extends Validator<dynamic> { ... }
class _PositiveQuantityValidator extends Validator<dynamic> { ... }
```

## Métodos

| Tipo | Patrón | Ejemplo |
|------|--------|---------|
| Obtener datos | `get[Nombre]` | `getSchedules()` |
| Crear | `create[Nombre]` | `createRecipe()` |
| Actualizar | `update[Nombre]` | `updateRecipe()` |
| Eliminar | `delete[Nombre]` | `deleteRecipe()` |
| Buscar | `search[Nombre]` | `searchRecipes()` |
| Convertir | `to[Tipo]` | `toEntity()` |
| Factory | `from[Origen]` | `fromEntity()`, `fromJson()` |
| Callbacks UI | `_on[Acción]` | `_onSubmit()`, `_onTap()` |
| Helpers privados | `_[acción]` | `_setupListeners()` |

## Constantes

```dart
// Spacing (QUALIFIED, no bare)
MenuarioSpacing.gapH16
MenuarioSpacing.paddingAll16

// Typography (TextStyle static const)
MenuarioTypography.h3

// Rutas
static const String recipes = '/recipes';
```

> Colores: NO existe clase de paleta. Se usa Material 3 vía
> `ColorScheme.fromSeed(seedColor: menuarioSeed)` y se accede con
> `Theme.of(context).colorScheme.*`.
