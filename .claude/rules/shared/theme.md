---
paths:
  - "**/*.dart"
---

# Sistema de Diseño

## Ubicación
```
lib/src/core/theme/          (archivos planos, barrel: theme.dart)
├── app_seed.dart            → menuarioSeed, menuarioSeedOptions, menuarioSeedFor
├── app_theme.dart           → MenuarioTheme.dark({seed}) / .light({seed})
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
define con Material 3 a partir de un `seed`, y **el seed lo elige la persona
usuaria** (se persiste; ver "Seed configurable").

```dart
// lib/src/core/theme/app_seed.dart
const menuarioSeed = Color(0xFF4F46E5); // el default (Índigo)
```

⚠️ **`MenuarioTheme.dark` / `MenuarioTheme.light` son FUNCIONES, no getters.**
Reciben el seed por parámetro con nombre y caen al default cuando no se pasa:

```dart
// lib/src/core/theme/app_theme.dart
abstract final class MenuarioTheme {
  const MenuarioTheme._();

  static ThemeData dark({Color seed = menuarioSeed}) =>
      _build(brightness: Brightness.dark, seed: seed);

  static ThemeData light({Color seed = menuarioSeed}) =>
      _build(brightness: Brightness.light, seed: seed);

  static ThemeData _build({
    required Brightness brightness,
    required Color seed,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [
        MenuarioCategoryColors.fromBrightness(brightness),
        MenuarioCoverageColors.fromBrightness(brightness),
      ],
    );
  }
}
```

```dart
// ✅ CORRECTO — se invocan
theme: MenuarioTheme.light(seed: selectedSeed),
darkTheme: MenuarioTheme.dark(seed: selectedSeed),

// ❌ INCORRECTO — ya no son getters
theme: MenuarioTheme.light,
```

### Seed configurable y persistido

El seed **no** está fijo en el código: se elige desde la pantalla *Apariencia*
y se persiste junto al `ThemeMode` (`ThemeSettings` en el shared kernel,
`shared/data/repositories/theme_settings_repository_impl.dart`).

La lista de seeds es **cerrada y curada** — no hay color picker libre:

```dart
typedef MenuarioSeedOption = ({String label, Color color});

const menuarioSeedOptions = <MenuarioSeedOption>[
  (label: 'Índigo', color: menuarioSeed),      // default
  (label: 'Esmeralda', color: Color(0xFF059669)),
  (label: 'Cian', color: Color(0xFF0891B2)),
  (label: 'Violeta', color: Color(0xFF7C3AED)),
  (label: 'Rosa', color: Color(0xFFDB2777)),
  (label: 'Ámbar', color: Color(0xFFD97706)),
  (label: 'Terracota', color: Color(0xFFC2410C)),
];
```

`menuarioSeedFor(int? value)` resuelve un seed curado desde su ARGB32
persistido y devuelve `null` si el valor no pertenece a la lista, de modo que
un documento manipulado degrada al default en vez de tematizar la app con un
color no validado.

- **El tema oscuro (`dark`) es el predeterminado por diseño**; el `ThemeMode`
  también es configurable por la persona usuaria.
- **Consecuencia para los widgets:** como el seed cambia en runtime, ningún
  color de UI puede estar hardcodeado. Todo color debe derivarse del
  `ColorScheme` del contexto para que re-tinte con el seed elegido:

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
