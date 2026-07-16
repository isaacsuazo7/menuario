---
name: "Enforcing Code Standards"
description: "Trigger: writing/refactoring code, code review, fixing analyze warnings in menuario. Enforces package:menuario imports, 80-col formatting, MenuarioSpacing/Typography, Failure/FailureException, prohibited anti-patterns."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Enforcing Code Standards

## Cuándo activar

- Al escribir nuevo código o refactorizar
- Durante code reviews
- Para resolver warnings de `fvm flutter analyze`

## Workflow

### 1. Verificar análisis estático

```bash
fvm flutter analyze
```

### 2. Aplicar rules en orden de prioridad

| Prioridad | Rule | Alcance |
|-----------|------|---------|
| 1 | `rules/patterns/providers.md` | `dependencies` obligatorias, tipos de provider |
| 2 | `rules/patterns/forms.md` | Formularios (patrón objetivo reactive_forms) |
| 3 | `rules/patterns/widgets.md` | `AppAsyncValueWidget`, widgets |
| 4 | `rules/patterns/submission.md` | Submission notifiers |
| 5 | `rules/conventions/naming.md` | Naming de archivos, clases, variables |
| 6 | `rules/conventions/imports.md` | Imports `package:menuario`, orden |
| 7 | `rules/conventions/formatting.md` | Trailing commas, const, 80 columnas |
| 8 | `rules/quality/errors-to-avoid.md` | Anti-patrones generales |

### 3. Imports

- Siempre absolutos: `package:menuario/src/...`. **Nunca relativos** (`../`).
- **NO hay barrels por feature** (`today.dart`, `recipes.dart` no existen). Se
  importa por ruta explícita, ej.
  `import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';`
- Barrels que SÍ existen y se pueden usar: `package:menuario/src/core/core.dart`,
  `package:menuario/src/core/theme/theme.dart`,
  `package:menuario/src/core/routing/routing.dart`,
  `package:menuario/src/shared/shared.dart` (incluye `AppAsyncValueWidget`).
- Código generado con `part 'x.freezed.dart';` / `part 'x.g.dart';`.

### 4. Formato

- Límite de 80 columnas (default de `dart format`); ejecutar `fvm dart format .`.
- Trailing commas en listas de argumentos/params multilinea (mejor formateo).
- `const` siempre que sea posible.
- Nada de `print(...)` → usar `log(...)` de `dart:developer`.

### 5. Theme: spacing y tipografía

- Espaciado **cualificado**: `MenuarioSpacing.gapH16`, `MenuarioSpacing.paddingAll16`
  (nunca importar los miembros “pelados”). Eje: `gapH*` = horizontal, `gapV*` =
  vertical. **No existen** `gapW*`, `paddingH*/paddingV*`, ni helpers `gapH(n)` /
  `paddingSymmetric`.
- Tipografía: `Text('Título', style: MenuarioTypography.h3)` (const `TextStyle`),
  no `Text('x').h3`. Única extensión: `MenuarioTextStyleX` → `.bold`,
  `.withColor(Color)`, ej. `MenuarioTypography.h3.withColor(...)`.
- Colores vía `Theme.of(context).colorScheme.*` (Material 3, `ColorScheme.fromSeed`).
  **No existe** una clase de paleta `MenuarioColors`.

### 6. Manejo de errores

- Solo dos tipos: `Failure` (dominio, dentro de `Either<Failure, T>`) y
  `FailureException` (se lanza en providers para que `AsyncValue` lo capture).
- **No existen** `ErrorPresenter` / `ErrorType` / `.toErrorPresenter()` — no
  referenciarlos. La UI lee `FailureException.message` (lo hace `AppAsyncValueWidget`).
- Ver `rules/shared/error-handling.md`.

### 7. Reglas de documentación (únicas de este skill)

- Comentarios en español cuando sea necesario.
- Máximo 1 línea de documentación por clase/método.
- No documentar lo autodescriptivo: `class CookSchedule` no necesita
  `/// Horario de cocina`.
- Solo documentar lógica no obvia o contratos (puertos de repositorio, servicios).

### 8. Anti-patrones prohibidos

- Imports relativos (`../`).
- `print()` en lugar de `log()`.
- `catch (e)` sin tipo → usar `on FailureException` / `on Exception`.
- `Container` solo para dar tamaño → usar `SizedBox` o `MenuarioSpacing.gap*`.
- Funciones que retornan `Widget` en vez de una subclase `Widget`.
- Guardar `ref.read(...)` en un campo/variable de larga vida (leer en el momento).
- Providers sin `dependencies` (usar `dependencies: const []` si no dependen de nada).

### 9. Verificación final

```bash
fvm flutter analyze  # Sin warnings
fvm flutter test # Tests pasan
```

## Checklist rápido

Ver `rules/quality/pre-code-checklist.md` para el checklist completo.
