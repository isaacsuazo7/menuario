---
paths:
  - "**/widgets/**/*.dart"
  - "**/screens/**/*.dart"
---

# Catálogo de Componentes Compartidos

⚠️ **menuario NO tiene una librería de componentes de diseño propia.** El único
widget de UI compartido es `AppAsyncValueWidget<T>`. Todo lo demás se construye
con **widgets crudos de Material** (`FilledButton`, `TextField`, `Card`,
`showModalBottomSheet`, etc.):
no existen en este proyecto.

## Ubicación
```
lib/src/shared/presentation/widgets/
└── app_async_value_widget.dart   → AppAsyncValueWidget<T>
```

Import (vía el barrel de shared, que exporta este widget):

```dart
import 'package:menuario/src/shared/shared.dart';
```

## Único widget compartido

### AppAsyncValueWidget

Widget principal para renderizar un `AsyncValue`:

```dart
AppAsyncValueWidget<List<Recipe>>(
  value: recipesAsyncValue,
  builder: (context, recipes) => RecipeList(recipes: recipes),
  onRetry: () => ref.invalidate(recipeListProvider), // opcional
  loadingBuilder: (context) => const MyLoader(),      // opcional
)
```

API:

| Parámetro | Tipo | Notas |
|---|---|---|
| `value` | `AsyncValue<T>` | **requerido** |
| `builder` | `Widget Function(BuildContext, T)` | **requerido** — se llama `builder`, NO `data` |
| `onRetry` | `VoidCallback?` | opcional; muestra un botón "Reintentar" |
| `loadingBuilder` | `WidgetBuilder?` | opcional; por defecto un `CircularProgressIndicator` centrado |

Notas importantes:

- **NO hay parámetro `error:`.** La UI de error es fija: un `_AppAsyncErrorView`
  privado (mensaje centrado + `FilledButton` "Reintentar" opcional si se pasa
  `onRetry`). El texto de error proviene de `FailureException.message` cuando el
  provider lanza `FailureException` (ver `error-handling.md`).
- El estado de carga usa `loadingBuilder` si se provee; si no, un indicador por
  defecto.

## Componentes que NO existen (usar Material crudo)

menuario **no** tiene equivalentes compartidos para estos elementos. Usa
directamente los widgets de Material:

| Necesidad | En menuario se usa |
|---|---|
| Botón primario | `FilledButton` / `FilledButton.tonal` |
| Botón secundario / texto | `OutlinedButton` / `TextButton` |
| Botón de icono | `IconButton` |
| Enlace de texto | `TextButton` |
| Campo de texto | `TextField` + `TextEditingController` (o `TextFormField`) |
| Campo de fecha | `showDatePicker` + `TextField` de solo lectura |
| Campo numérico | `TextField` con `keyboardType: TextInputType.number` |
| Dropdown | `DropdownButtonFormField` / `DropdownMenu` |
| Dropdown con búsqueda | `showModalBottomSheet` + lista filtrable propia |
| AppBar | `AppBar` de Material |
| Tarjeta / info | `Card` / `Container` con `BoxDecoration` |
| Diálogo | `showDialog` + `AlertDialog` |
| Badge de estado | `Container`/`Chip` coloreado con las extensiones de tema |
| Lista paginada / con búsqueda | `ListView` + lógica en el provider |
| Indicador de carga | `CircularProgressIndicator` (o `AppAsyncValueWidget`) |
| Estado vacío | `Center` + `Column` propios |
| Widget de error público | (no hay) — el error vive dentro de `AppAsyncValueWidget` |

Para los colores de estos widgets usa `Theme.of(context).colorScheme` y, cuando
aplique, las extensiones `MenuarioCategoryColors` / `MenuarioCoverageColors`
(ver `theme.md`).

## Bottom sheets

El patrón real es `showModalBottomSheet` crudo abriendo un widget privado
definido en su propio archivo:

```dart
Future<void> _openRecipeDetail(BuildContext context, Recipe recipe) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _RecipeDetailSheet(recipe: recipe),
  );
}
```

Convenciones observadas en el repo (p. ej. en `features/today/`):

- El contenido del sheet vive en un archivo aparte con un widget `_`-privado,
  p. ej. `_recipe_detail_sheet.dart` → `_RecipeDetailSheet`, o
  `today_meal_detail_sheet.dart`.
- Para modales con contenido largo, limita la altura con `isScrollControlled:
  true` + `constraints:` (o usa `DraggableScrollableSheet`) para no superar
  ~80% de la pantalla:

```dart
showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  constraints: BoxConstraints(
    maxHeight: MediaQuery.of(context).size.height * 0.8,
  ),
  builder: (context) => const _SomeSheet(),
);
```

> Nota: hoy no hay un wrapper compartido para esto. Un helper de bottom sheet
> reutilizable es una mejora **recomendable** a futuro, pero aún no existe: no
> lo referencies como si estuviera disponible.
