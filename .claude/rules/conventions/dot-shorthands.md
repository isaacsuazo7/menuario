---
paths:
  - "**/*.dart"
---

# Dot Shorthands (Dart 3.10+)

## Regla General

Usar dot shorthand siempre que el tipo sea inferible por contexto. Aplica a: enums, constructores (named y `.new`), y static members.

## Enums

```dart
// ✅ Correcto
switch (status) {
  case .cubierto: ...
  case .justo: ...
  case .falta: ...
  case .neutral: ...
}

final tab = StateProvider<TodayTab>((_) => .cook);

colorFor(status: .falta);

// ❌ Incorrecto
switch (status) {
  case CoverageStatus.cubierto: ...
  case CoverageStatus.justo: ...
  case CoverageStatus.falta: ...
  case CoverageStatus.neutral: ...
}

final tab = StateProvider<TodayTab>((_) => TodayTab.cook);

colorFor(status: CoverageStatus.falta);
```

## Constructores Named

```dart
// ✅ Correcto
padding: .all(16),
margin: .symmetric(horizontal: 16, vertical: 8),
borderRadius: .circular(12),
decoration: .underline,

// ❌ Incorrecto
padding: EdgeInsets.all(16),
margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
borderRadius: BorderRadius.circular(12),
decoration: TextDecoration.underline,
```

## Constructor por Defecto (.new)

```dart
// ✅ Correcto
final TextEditingController controller = .new();
final List<String> items = .empty(growable: true);

// ❌ Incorrecto
final TextEditingController controller = TextEditingController();
final List<String> items = List.empty(growable: true);
```

## Static Members

```dart
// ✅ Correcto
BigInt count = .zero;
Duration timeout = .zero;
Color background = .white;

// ❌ Incorrecto
BigInt count = BigInt.zero;
Duration timeout = Duration.zero;
Color background = Colors.white;
```

## Expresiones Const

```dart
// ✅ Correcto
const EdgeInsets padding = .all(16);
const BorderRadius radius = .all(Radius.circular(8));

// ❌ Incorrecto
const EdgeInsets padding = EdgeInsets.all(16);
const BorderRadius radius = BorderRadius.all(Radius.circular(8));
```

## Cuándo NO Usar

- **Sin contexto de tipo claro**: si el tipo no es inferible, usar el nombre completo
- **Lado izquierdo de `==` / `!=`**: no se permite dot shorthand a la izquierda de comparaciones
- **Expression statements sueltos**: `.foo()` solo no es válido como statement
- **Cuando afecte la legibilidad**: cadenas de tipos muy largos o anidados donde el shorthand oscurece el significado
