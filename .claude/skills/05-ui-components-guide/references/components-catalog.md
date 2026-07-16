# Catálogo de Componentes UI (menuario)

menuario NO tiene un design system con wrappers propios. La norma son **widgets Material
crudos** + UN único widget shared (`AppAsyncValueWidget`). Este catálogo documenta lo que
SÍ existe y, al final, lo que NO existe para que no lo invoques.

---

## El único widget shared

### AppAsyncValueWidget<T> (OBLIGATORIO para AsyncValue)

`lib/src/shared/presentation/widgets/app_async_value_widget.dart`
(exportado por `package:menuario/src/shared/shared.dart`).

API real:
- `required AsyncValue<T> value`
- `required Widget Function(BuildContext, T) builder`  ← **`builder`**, NO `data`
- `VoidCallback? onRetry`
- `WidgetBuilder? loadingBuilder`
- **Sin param `error:`** — la vista de error es fija (`_AppAsyncErrorView`: mensaje
  centrado + `FilledButton` "Reintentar" cuando hay `onRetry`).

```dart
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

---

## Botones (Material crudos)

```dart
FilledButton(onPressed: _submit, child: const Text('Guardar'))
OutlinedButton(onPressed: _show, child: const Text('Ver detalles'))
TextButton(onPressed: () => context.pop(), child: const Text('Cancelar'))
IconButton(onPressed: _settings, icon: const Icon(Icons.settings))

// Deshabilitar: onPressed: null
FilledButton(onPressed: form.valid ? _submit : null, child: const Text('Enviar'))

// Loading dentro del botón (no hay isLoading): intercambia el child
FilledButton(
  onPressed: isSubmitting ? null : _submit,
  child: isSubmitting
      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
      : const Text('Enviar'),
)
```

## Campos de texto (Material crudos / reactive_forms objetivo)

```dart
// Actual: TextField + TextEditingController
final nameController = TextEditingController();
TextField(
  controller: nameController,
  decoration: const InputDecoration(labelText: 'Nombre', hintText: 'Ej: Sopa'),
)

// Numérico
TextField(
  controller: servingsController,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(labelText: 'Porciones'),
)

// Fecha
final picked = await showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
);

// Dropdown
DropdownButtonFormField<Category>(
  decoration: const InputDecoration(labelText: 'Categoría'),
  items: [for (final c in Category.values) DropdownMenuItem(value: c, child: Text(c.name))],
  onChanged: (v) {/* ... */},
)
```

> Patrón OBJETIVO (reactive_forms, aún no en pubspec): `ReactiveTextField<String>(formControlName: 'name')`,
> `ReactiveDropdownField<T>(...)`. Ver Skill `/04-request-flow-generator`.

## Estados async y loading

```dart
// Para AsyncValue → AppAsyncValueWidget (arriba). Loading suelto:
const CircularProgressIndicator()
const Center(child: CircularProgressIndicator())
```

## Errores

La UI de error para AsyncValue la provee `AppAsyncValueWidget` internamente. Para un
error suelto, usa Material crudo:

```dart
Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('No se pudo cargar', style: MenuarioTypography.h5),
      MenuarioSpacing.gapV8,
      FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
    ],
  ),
)
```

El texto de error de una mutación sale de `FailureException.message`.

## Diálogos (Material crudos)

```dart
final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Confirmar'),
    content: const Text('¿Estás seguro?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
    ],
  ),
);
```

## Cards (Material crudos)

```dart
Card(
  child: Padding(
    padding: MenuarioSpacing.paddingAll16,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Título', style: MenuarioTypography.h6),
        MenuarioSpacing.gapV4,
        Text('Subtítulo', style: MenuarioTypography.body),
      ],
    ),
  ),
)
```

## Listas (Material crudas)

```dart
ListView.builder(
  itemCount: recipes.length,
  itemBuilder: (context, i) => RecipeCard(recipe: recipes[i]),
)

// Con refresh
RefreshIndicator(
  onRefresh: () async => ref.invalidate(recipeListProvider),
  child: ListView.builder(/* ... */),
)
```

> NO hay lista paginada/searchable shared. Si se necesita, se construye con `ListView` +
> lógica en el provider (un helper shared sería recomendación de futuro, no algo existente).

## App Bar (Material crudo)

```dart
Scaffold(
  appBar: AppBar(
    title: const Text('Recetas'),
    actions: [IconButton(onPressed: _settings, icon: const Icon(Icons.settings))],
  ),
)
```

`AppBar` ya trae botón de retroceso automático dentro de una ruta con go_router.

## Bottom Sheets (showModalBottomSheet + widget privado)

```dart
final result = await showModalBottomSheet<bool>(
  context: context,
  isScrollControlled: true,
  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
  builder: (context) => const _RecipeDetailSheet(),
);
```

El contenido vive en un widget privado (`_RecipeDetailSheet`), habitualmente en un archivo
propio como `_recipe_detail_sheet.dart` o el patrón real `today_meal_detail_sheet.dart`.

## Colores de dominio (theme extensions)

```dart
final catColors = Theme.of(context).extension<MenuarioCategoryColors>()!;
final categoryColor = catColors.colorFor(category);   // + {fallback}

final covColors = Theme.of(context).extension<MenuarioCoverageColors>()!;
final coverageColor = covColors.colorFor(coverageStatus); // cubierto/justo/falta/neutral
```

---

