---
paths:
  - "**/*.dart"
---

# Sistema de Diseño

## Ubicación
```
lib/src/core/theme/          (archivos planos, barrel: theme.dart)
├── app_seed.dart            → const menuarioSeed
├── app_theme.dart           → MenuarioTheme (dark/light)
├── category_colors.dart     → MenuarioCategoryColors (ThemeExtension)
├── coverage_colors.dart     → MenuarioCoverageColors (ThemeExtension)
├── spacing.dart             → MenuarioSpacing
├── typography.dart          → MenuarioTypography + MenuarioTextStyleX
└── theme.dart               (barrel)
```

Import típico:

```dart
import 'package:menuario/src/core/theme/theme.dart';
// o, granular y también aceptado:
import 'package:menuario/src/core/theme/spacing.dart';
```

## Colores — Material 3 (sin paleta estática)

menuario **NO** tiene una clase de paleta con constantes de color. El color se
define con Material 3 a partir de un `seed`:

```dart
// lib/src/core/theme/app_seed.dart
const menuarioSeed = Color(0xFF4F46E5);
```

```dart
// lib/src/core/theme/app_theme.dart
abstract final class MenuarioTheme {
  static ThemeData get dark => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: menuarioSeed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: menuarioSeed),
        useMaterial3: true,
      );
}
```

- **El tema oscuro (`dark`) es el predeterminado por diseño.**
- Los colores se leen SIEMPRE desde el `ColorScheme` del contexto, nunca desde
  una constante global:

```dart
final scheme = Theme.of(context).colorScheme;
Container(color: scheme.primary);
Text('Hola', style: TextStyle(color: scheme.onSurface));
```

Roles habituales: `primary`, `onPrimary`, `surface`, `onSurface`,
`surfaceContainerHighest`, `outline`, `error`, `onError`.

### Extensiones de color de dominio (ThemeExtension)

Dos extensiones de tema aportan colores específicos del dominio. Se acceden vía
`Theme.of(context).extension<...>()`:

```dart
// lib/src/core/theme/category_colors.dart
final categoryColors = Theme.of(context).extension<MenuarioCategoryColors>()!;
final color = categoryColors.colorFor(category, fallback: scheme.primary);
```

```dart
// lib/src/core/theme/coverage_colors.dart
final coverageColors = Theme.of(context).extension<MenuarioCoverageColors>()!;
final color = coverageColors.colorFor(coverageStatus);
// CoverageStatus: cubierto | justo | falta | neutral
```

## MenuarioSpacing

`abstract final class` en `lib/src/core/theme/spacing.dart`. Todos los miembros
son `static const` y se acceden **CALIFICADOS**: `MenuarioSpacing.gapH16`.

⚠️ **El eje está nombrado al revés respecto a otros proyectos**: en menuario los
gaps **horizontales** son `gapH*` (ancho) y los **verticales** son `gapV*`
(alto). No existe `gapW*`.

### Escala base (doubles)

```dart
MenuarioSpacing.xs   // 4
MenuarioSpacing.sm   // 8
MenuarioSpacing.md   // 16
MenuarioSpacing.lg   // 24
MenuarioSpacing.xl   // 32
```

### Gaps (SizedBox)

```dart
// Horizontales (width)
MenuarioSpacing.gapH4
MenuarioSpacing.gapH8
MenuarioSpacing.gapH16
MenuarioSpacing.gapH24
MenuarioSpacing.gapH32

// Verticales (height)
MenuarioSpacing.gapV4
MenuarioSpacing.gapV8
MenuarioSpacing.gapV16
MenuarioSpacing.gapV24
MenuarioSpacing.gapV32
```

### Padding (EdgeInsets)

```dart
MenuarioSpacing.paddingAll4
MenuarioSpacing.paddingAll8
MenuarioSpacing.paddingAll16
MenuarioSpacing.paddingAll24
MenuarioSpacing.paddingAll32
```

⚠️ **NO existen**: `gapW*`, `paddingH*`/`paddingV*`, ni helpers como
`gapW(n)`/`gapH(n)`/`paddingSymmetric(...)`/`paddingOnly(...)`. Para paddings no
cubiertos por las constantes, usa `EdgeInsets` directo de Flutter
(`EdgeInsets.symmetric(...)`, `EdgeInsets.only(...)`).

## MenuarioTypography

`abstract final class` en `lib/src/core/theme/typography.dart`. Son `TextStyle`
`static const` que se pasan al parámetro `style:` de `Text` — **no** son
extensiones sobre `Text`.

```dart
MenuarioTypography.h1    // 32 / w700
MenuarioTypography.h2    // 28 / w700
MenuarioTypography.h3    // 24 / w600
MenuarioTypography.h4    // 20 / w600
MenuarioTypography.h5    // 18 / w600
MenuarioTypography.h6    // 16 / w600
MenuarioTypography.body  // 14 / w400
```

Uso:

```dart
Text('Título', style: MenuarioTypography.h3)
```

### MenuarioTextStyleX (única extensión)

Una sola extensión sobre `TextStyle` permite ajustar peso y color de forma
fluida:

```dart
extension MenuarioTextStyleX on TextStyle {
  TextStyle get bold;              // fuerza w700
  TextStyle withColor(Color color);
}
```

```dart
Text('Título', style: MenuarioTypography.h3.bold)
Text(
  'Subtítulo',
  style: MenuarioTypography.body.withColor(
    Theme.of(context).colorScheme.onSurfaceVariant,
  ),
)
```

⚠️ **NO existen** los encadenados tipo `.xs/.sm/.base/.semibold/.caption/`
`.label/.center/.ellipsis/.withOpacity`. Para alineación, overflow, opacidad,
etc., usa los parámetros nativos de `Text` (`textAlign:`, `maxLines:`,
`overflow:`) o `TextStyle` directamente.

## Uso Típico

```dart
Widget build(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Título', style: MenuarioTypography.h3.bold),
      MenuarioSpacing.gapV8,
      Text(
        'Subtítulo',
        style: MenuarioTypography.body.withColor(scheme.onSurfaceVariant),
      ),
      MenuarioSpacing.gapV16,
      Container(
        padding: MenuarioSpacing.paddingAll16,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('Contenido', style: MenuarioTypography.body),
      ),
    ],
  );
}
```
