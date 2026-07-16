---
paths:
  - "**/widgets/**/*.dart"
  - "**/screens/**/*.dart"
---

# Patrones de Widgets

## AppAsyncValueWidget (OBLIGATORIO)

**SIEMPRE usar `AppAsyncValueWidget<T>` para renderizar `AsyncValue`.** Es el
ÚNICO widget compartido de UI del proyecto
(`lib/src/shared/presentation/widgets/app_async_value_widget.dart`).

### ✅ CORRECTO

```dart
AppAsyncValueWidget<List<Recipe>>(
  value: recipesAsyncValue,
  builder: (context, recipes) => ListView.builder(
    itemCount: recipes.length,
    itemBuilder: (context, index) => RecipeCard(recipe: recipes[index]),
  ),
  onRetry: () => ref.invalidate(recipeListProvider),
)
```

### ❌ PROHIBIDO

```dart
// ❌ NUNCA usar .when() directamente
recipesAsyncValue.when(
  data: (recipes) => ...,
  loading: () => ...,
  error: (e, s) => ...,
)
```

### Parámetros de AppAsyncValueWidget

```dart
AppAsyncValueWidget<T>(
  value: asyncValue,                          // AsyncValue<T> requerido
  builder: (context, data) => Success(data),  // requerido — NOTA: se llama `builder`, no `data`
  onRetry: () => ref.invalidate(...),         // opcional, botón "Reintentar"
  loadingBuilder: (context) => ...,           // opcional, WidgetBuilder para el estado de carga
)
```

- No existe parámetro `error:`. La UI de error es fija (mensaje centrado +
  botón "Reintentar" opcional), gestionada internamente por el widget a partir
  de `FailureException.message`.

## observeForDialogs NO existe

menuario **no tiene** `observeForDialogs`. Para reaccionar al resultado de un
submission (éxito/error, navegación, SnackBar), usa `ref.listen` sobre el
`AsyncValue` del provider de submission:

```dart
@override
Widget build(BuildContext context) {
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

  return ...;
}
```

## Bottom Sheets

El patrón real es `showModalBottomSheet<T>` de Material abriendo un widget
privado (archivo prefijado con `_`, ej: `_recipe_detail_sheet.dart` →
`_RecipeDetailSheet`, o `today_meal_detail_sheet.dart`).

```dart
Future<Recipe?> _openDetailSheet(BuildContext context) {
  return showModalBottomSheet<Recipe>(
    context: context,
    isScrollControlled: true, // permite superar el 50% de altura por defecto
    // Limitar la altura del modal (p. ej. ~80% de la pantalla)
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.8,
    ),
    builder: (context) => const _RecipeDetailSheet(),
  );
}
```

Para contenido con scroll y arrastre puede usarse `DraggableScrollableSheet`.
Un helper compartido de bottom sheet sería una mejora recomendable, pero **aún
no existe** — no lo referencies como si existiera.

## Widgets Privados en Screens

Dividir screens grandes en widgets privados **como clases** (nunca funciones):

```dart
class RecipeFormScreen extends ConsumerStatefulWidget { ... }

// Secciones como widgets privados (clases)
class _RecipeFieldsSection extends StatelessWidget { ... }
class _BomEditor extends ConsumerWidget { ... }
class _BottomActionBar extends ConsumerWidget { ... }
```

En `today/` la convención de widget privado usa archivo `_name.dart` → clase
`_PascalCase` (ej: `_cook_body.dart` → `_CookBody`, `_today_header.dart` →
`_TodayHeader`). Esto es aceptado. Los screens/sheets que son punto de entrada
deben usar nombre de archivo `snake_case` plano.

## Reglas de Widgets

### NO crear funciones que retornen widgets

```dart
// ❌ PROHIBIDO
Widget _buildHeader() {
  return Container(...);
}

// ✅ CORRECTO - Usar StatelessWidget (clase)
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Text('Hoy', style: MenuarioTypography.h3);
  }
}
```

### Usar SizedBox / constantes de spacing en lugar de Container para sizing

```dart
// ❌ INCORRECTO
Container(height: 16)
Container(width: 8)

// ✅ CORRECTO
const SizedBox(height: 16)
MenuarioSpacing.gapV16  // gap vertical predefinido
```

### Usar constantes de MenuarioSpacing

`MenuarioSpacing` se accede **cualificado** (`lib/src/core/theme/spacing.dart`).
Ejes: horizontal = `gapH*`, vertical = `gapV*` (⚠️ no hay `gapW*`).

```dart
// ✅ CORRECTO
Column(
  children: [
    Text('Título', style: MenuarioTypography.h3),
    MenuarioSpacing.gapV16,
    Text('Subtítulo', style: MenuarioTypography.body),
  ],
)

Padding(
  padding: MenuarioSpacing.paddingAll16,
  child: ...,
)
```

### Usar MenuarioTypography para texto

`MenuarioTypography` expone `TextStyle` estáticos
(`h1..h6`, `body`) — se pasan por `style:`, no por extensiones sobre `Text`.

```dart
// ✅ CORRECTO
Text('Título', style: MenuarioTypography.h3)
Text('Destacado', style: MenuarioTypography.h4.bold)          // extension .bold
Text('Coloreado', style: MenuarioTypography.body.withColor(color)) // extension .withColor

// ❌ INCORRECTO - no existen extensiones de este tipo sobre Text
Text('Título').h3
```

## Cuándo Extraer Widgets

Si el método `build()` supera **~150-200 líneas**, dividirlo en widgets privados:

- Cada sección lógica del UI (header, campos de formulario, action bar) → widget privado (clase)
- Preferir `StatelessWidget` o `ConsumerWidget` privados sobre funciones que retornan widgets

## Dónde Ubicar Widgets Extraídos

| Alcance de reutilización | Ubicación | Visibilidad |
|--------------------------|-----------|-------------|
| Uso único en una pantalla | Mismo archivo que la screen | `_WidgetName` (privado) |
| 2+ pantallas del **mismo** feature | `features/[feature]/presentation/widgets/` | Público |
| 2+ **features** distintos | `shared/presentation/widgets/` | Público |

- El único widget compartido actual es `AppAsyncValueWidget`. Antes de crear uno
  nuevo en `shared/presentation/widgets/`, confirmar reutilización real (no especulativa).

## Checklist de Widgets

- [ ] `AppAsyncValueWidget` para AsyncValue (parámetro `builder`, NO `.when()`)
- [ ] Efectos de submission con `ref.listen(...)` (NO `observeForDialogs`)
- [ ] Bottom sheets con `showModalBottomSheet` + widget privado `_XxxSheet`
- [ ] Widgets privados como clases `_PascalCase`, no funciones
- [ ] `SizedBox` o `MenuarioSpacing.*` para spacing (no `Container` para sizing)
- [ ] Texto con `MenuarioTypography.*` vía `style:`
- [ ] `const` constructors donde sea posible
- [ ] `build()` no supera ~150-200 líneas
- [ ] Widgets reutilizados en 2+ features en `shared/presentation/widgets/`
