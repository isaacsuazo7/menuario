---
name: "Using UI Components"
description: "Trigger: designing screens, spacing/typography, async UI, bottom sheets, navigation in menuario. Real UI catalog: only shared AppAsyncValueWidget, MenuarioSpacing/Typography, raw Material, theme extensions, go_router."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Using UI Components

## Descripción

Catálogo de la UI **real** de menuario. A diferencia de proyectos con un design system
propio, menuario usa **widgets Material crudos** como norma; solo hay UN widget shared
(`AppAsyncValueWidget`). Esta skill garantiza que no invoques componentes inexistentes.

> ⚠️ **Lee primero**: la sección "Componentes que NO existen en menuario" al final.
> Si dudas si un símbolo existe, trátalo como inexistente.

## Cuándo usar esta skill

- Al diseñar nuevas pantallas.
- Para aplicar spacing/typography consistentes (cualificados).
- Para manejar estados async en UI (`AppAsyncValueWidget`).
- Para abrir bottom sheets y navegar con go_router.

## Sistema de Diseño

### Colors — Material 3, sin clase de paleta

NO existe `MenuarioColors` ni paleta estática. Los colores salen de un `ColorScheme`
generado con `ColorScheme.fromSeed`:

```dart
// lib/src/core/theme/app_seed.dart
const menuarioSeed = Color(0xFF4F46E5);
```

`MenuarioTheme` (`abstract final class`) expone `static ThemeData get dark` / `get light`.
**Dark es el tema por defecto por diseño.** Accede a colores vía el contexto:

```dart
final scheme = Theme.of(context).colorScheme;
Container(color: scheme.primary);
Text('x', style: TextStyle(color: scheme.onSurface));
```

**Theme extensions de dominio** (ThemeExtension), accedidas con `Theme.of(context).extension<...>()`:

```dart
// Color por categoría de receta/ingrediente
final catColors = Theme.of(context).extension<MenuarioCategoryColors>()!;
final color = catColors.colorFor(category);          // + {fallback}

// Color por estado de cobertura (cubierto / justo / falta / neutral)
final covColors = Theme.of(context).extension<MenuarioCoverageColors>()!;
final color = covColors.colorFor(coverageStatus);
```

Definidos en `lib/src/core/theme/category_colors.dart` y `coverage_colors.dart`.

### Spacing (MenuarioSpacing) — SIEMPRE cualificado

`MenuarioSpacing` (`abstract final class`, `lib/src/core/theme/spacing.dart`). Se accede
cualificado: `MenuarioSpacing.gapH16` (NO un `gapH16` suelto). Miembros exactos (todos `static const`):

```dart
// doubles
MenuarioSpacing.xs   // 4
MenuarioSpacing.sm   // 8
MenuarioSpacing.md   // 16
MenuarioSpacing.lg   // 24
MenuarioSpacing.xl   // 32

// gaps HORIZONTALES (SizedBox con width)
MenuarioSpacing.gapH4, gapH8, gapH16, gapH24, gapH32

// gaps VERTICALES (SizedBox con height)
MenuarioSpacing.gapV4, gapV8, gapV16, gapV24, gapV32

// paddings (EdgeInsets.all)
MenuarioSpacing.paddingAll4, paddingAll8, paddingAll16, paddingAll24, paddingAll32
```

> ⚠️ **El eje está INVERTIDO respecto a otros proyectos**: en menuario horizontal = `gapH*`,
> vertical = `gapV*`. NO existe `gapW*`, NI `paddingH*`/`paddingV*`, NI helpers
> `gapW(n)`/`gapH(n)`/`paddingSymmetric`. No los documentes ni los uses.

### Typography (MenuarioTypography) — estilos estáticos

`MenuarioTypography` (`abstract final class`, `lib/src/core/theme/typography.dart`).
Miembros `static const TextStyle`: `h1`(32/w700), `h2`(28/w700), `h3`(24/w600),
`h4`(20/w600), `h5`(18/w600), `h6`(16/w600), `body`(14/w400).

```dart
// ✅ Uso correcto: pasar el estilo, NO una extensión sobre Text
Text('Título', style: MenuarioTypography.h3)
```

UNA sola extensión existe: `extension MenuarioTextStyleX on TextStyle` →

```dart
Text('Fuerte', style: MenuarioTypography.body.bold)                 // getter .bold
Text('Color',  style: MenuarioTypography.h3.withColor(scheme.error)) // .withColor(Color)
```

> ⚠️ NO existen las cadenas `.xs/.sm/.base/.semibold/.caption/.label/.center/.ellipsis/.withOpacity`,
> ni el patrón `Text('x').h3`.

## Componente Shared (el único)

### AppAsyncValueWidget<T> (OBLIGATORIO para AsyncValue)

`lib/src/shared/presentation/widgets/app_async_value_widget.dart`. API real:

- `required AsyncValue<T> value`
- `required Widget Function(BuildContext, T) builder`  ← se llama **`builder`**, NO `data`
- `VoidCallback? onRetry`
- `WidgetBuilder? loadingBuilder`
- **NO tiene param `error:`** — la UI de error es fija (`_AppAsyncErrorView` privado:
  mensaje centrado + botón "Reintentar" `FilledButton` opcional).

```dart
// ✅ SIEMPRE usar para AsyncValue (nunca .when() directo)
AppAsyncValueWidget<List<Recipe>>(
  value: ref.watch(recipeListProvider),
  builder: (context, recipes) => RecipeList(recipes: recipes),
  onRetry: () => ref.invalidate(recipeListProvider),
)

// Con loading custom
AppAsyncValueWidget<Recipe>(
  value: ref.watch(recipeEditProvider(id)),
  builder: (context, recipe) => RecipeDetail(recipe: recipe),
  loadingBuilder: (context) => const Center(child: CircularProgressIndicator()),
  onRetry: () => ref.invalidate(recipeEditProvider(id)),
)
```

Importado desde `package:menuario/src/shared/shared.dart`.

## Widgets Material crudos (la norma)

menuario NO tiene wrappers de UI. Usa los widgets del framework directamente:

| Necesitas | Usa (crudo) |
|---|---|
| Botón primario | `FilledButton` |
| Botón secundario/texto | `TextButton` / `OutlinedButton` |
| Botón de icono | `IconButton` |
| Campo de texto | `TextField` + `TextEditingController` |
| App bar | `AppBar` |
| Card | `Card` / `Container` |
| Diálogo | `showDialog` + `AlertDialog` |
| Loading | `CircularProgressIndicator` |
| Lista | `ListView` / `ListView.builder` |

```dart
FilledButton(onPressed: _submit, child: const Text('Guardar'))
TextButton(onPressed: () => context.pop(), child: const Text('Cancelar'))

final controller = TextEditingController();
TextField(controller: controller, decoration: const InputDecoration(labelText: 'Nombre'))
```

## Bottom Sheets — showModalBottomSheet + widget privado

El patrón real es
`showModalBottomSheet<T>` abriendo un widget **privado** (`_`), p.ej.
`today_meal_detail_sheet.dart` → clase interna, o un archivo `_recipe_detail_sheet.dart`
→ `_RecipeDetailSheet`.

```dart
final result = await showModalBottomSheet<bool>(
  context: context,
  isScrollControlled: true,
  // Para "modal máx 80% de alto": usa constraints o DraggableScrollableSheet.
  constraints: BoxConstraints(
    maxHeight: MediaQuery.of(context).size.height * 0.8,
  ),
  builder: (context) => const _RecipeDetailSheet(),
);
```

> No hay wrapper reutilizable todavía. Un helper shared para sheets sería una
> RECOMENDACIÓN de futuro, no algo existente que puedas referenciar.

## Formularios (patrón OBJETIVO — reactive_forms)

> ⚠️ reactive_forms es el estándar **OBJETIVO** de la remediación; aún NO hay formularios
> reactive_forms en el repo y el dep no está en `pubspec.yaml`. Los 4 formularios actuales
> usan `ConsumerStatefulWidget` + `TextEditingController` + `Notifier`. Referencia de
> mecánica general de UI: el slice `features/today/`.

```dart
ReactiveForm(
  formGroup: ref.watch(recipeFormControllerProvider),
  child: Column(
    children: [
      const ReactiveTextField<String>(formControlName: 'name'),
      MenuarioSpacing.gapV16,
      ReactiveFormConsumer(
        builder: (context, form, _) => FilledButton(
          onPressed: form.valid ? _submit : null,
          child: const Text('Guardar'),
        ),
      ),
    ],
  ),
)
```

Para el flujo completo (form controller, submission, screen): ver Skill `/04-request-flow-generator`.

## Manejo de éxito/error de mutaciones

NO existe `observeForDialogs`. Observa el `AsyncValue` del submission en la screen:

```dart
ref.listen(recipeSubmissionProvider, (prev, next) {
  next.whenOrNull(
    data: (_) => context.go('/recipes'),
    error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text((e as FailureException).message)),
    ),
  );
});
```

`FailureException.message` es lo que se muestra al usuario (ver `rules/shared/error-handling.md`).

## Patrones de Pantalla

### Screen (form / detalle con estado)

```dart
class RecipeScreen extends ConsumerStatefulWidget {
  const RecipeScreen({super.key});
  @override
  ConsumerState<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends ConsumerState<RecipeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receta')),
      body: SingleChildScrollView(
        padding: MenuarioSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Detalle', style: MenuarioTypography.h4),
            MenuarioSpacing.gapV16,
            // contenido...
          ],
        ),
      ),
    );
  }
}
```

### Detail Screen (AsyncValue)

```dart
class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: AppAsyncValueWidget<Recipe>(
        value: ref.watch(recipeEditProvider(id)),
        builder: (context, recipe) => RecipeContent(recipe: recipe),
        onRetry: () => ref.invalidate(recipeEditProvider(id)),
      ),
    );
  }
}
```

## Navegación con go_router

```dart
context.go('/recipes');
context.push('/recipes/new');
context.goNamed('recipeDetail', pathParameters: {'id': '123'});
context.pop();
context.pop(result);
```

Rutas definidas en `lib/src/core/routing/` (barrel `package:menuario/src/core/routing/routing.dart`).

## Checklist de UI

- [ ] Widgets Material crudos (`FilledButton`, `TextField`, `AppBar`, `Card`) — sin wrappers.
- [ ] Spacing/typography cualificados (`MenuarioSpacing.gapV16`, `MenuarioTypography.h4`).
- [ ] Para `AsyncValue`, `AppAsyncValueWidget` (param `builder`, sin `.when()` directo).
- [ ] Colores vía `Theme.of(context).colorScheme` o theme extensions (Category/Coverage).
- [ ] Sheets con `showModalBottomSheet` + widget privado `_`.
- [ ] Mutaciones: `ref.listen` sobre el submission (no `observeForDialogs`).
- [ ] Navegación con go_router (`context.go/push/pop`).

## Referencias

- [`references/components-catalog.md`](references/components-catalog.md) — catálogo de widgets crudos y el único shared
- [`references/extensions-catalog.md`](references/extensions-catalog.md) — la única extensión (`MenuarioTextStyleX`) y las que NO existen
- `lib/src/shared/presentation/widgets/app_async_value_widget.dart` — código del único widget shared
- `lib/src/core/theme/` — spacing, typography, seed, theme extensions
- Slice de referencia: `lib/src/features/today/**`
