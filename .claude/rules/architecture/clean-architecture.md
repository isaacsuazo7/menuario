---
paths:
  - "lib/src/features/**/*.dart"
  - "lib/src/shared/**/*.dart"
---

# Clean Architecture

## Capas del Sistema

```
lib/src/
├── core/           # Funcionalidad compartida transversal (auth, error, firebase, routing, theme)
├── features/       # Módulos de dominio (vertical slices)
└── shared/         # SHARED KERNEL: domain/data compartidos + el único widget compartido
```

## Estructura de una Feature

> ⚠️ La mayoría de las features son **solo presentación**. Su `domain`/`data`
> viven en el shared kernel (`lib/src/shared/domain/**`, `lib/src/shared/data/**`).
> Solo `today` tiene un slice completo `domain/data/presentation` en disco.

```
features/[feature]/
├── domain/                 # (opcional) solo si el slice es completo, como today/
│   ├── entities/           # Modelos de dominio puros (Freezed)
│   ├── repositories/       # Contratos (interfaces / ports abstractos)
│   └── value_objects/      # Value objects del dominio
├── data/                   # (opcional) solo si el slice es completo, como today/
│   ├── models/             # DTOs (Freezed + json_serializable)
│   ├── datasources/        # Acceso a Firestore
│   └── repositories/       # Implementación de contratos
└── presentation/
    ├── models/             # View-models de presentación (ej: cook_item.dart)
    ├── providers/          # Riverpod providers
    ├── screens/            # Pantallas principales
    └── widgets/            # Widgets específicos del feature
```

> **NO existe capa de use cases.** No hay directorio `usecases/` en ningún lugar
> del proyecto. La lógica de negocio vive en `lib/src/shared/domain/services/`
> (`coverage_calculator.dart`, `measurement_converter.dart`,
> `provisioning_calculator.dart`, `stock_lens_service.dart`).

## Flujo de Datos con Either Pattern

```
Widget → Provider → Repository → DataSource → Firestore
                          ↓
AsyncValue ← fold() ← Either<Failure, T> ←──┘
```

> No hay salto por UseCase. El provider llama al Repository directamente (o a un
> domain Service cuando corresponde lógica de negocio pura).

### Reglas de Dependencia

1. **Domain NO depende de nada** (solo de Dart core y Freezed).
2. **Data depende de Domain** (implementa contratos, mapea DTO ↔ Entity).
3. **Presentation depende de Domain y Data** (a través de providers).
4. **Core es transversal** (auth, error, firebase, routing, theme).
5. **Shared es el kernel** que aloja domain/data de las features solo-presentación.

### Either Pattern

```dart
// DataSource retorna Either
Future<Either<Failure, List<CookSchedule>>> getSchedules();

// Repository propaga (o transforma) el Either
@override
Future<Either<Failure, List<CookSchedule>>> getSchedules() async {
  return dataSource.getSchedules();
}

// Provider convierte a AsyncValue con fold()
final result = await repository.getSchedules();
return result.fold(
  (failure) => throw FailureException(failure),
  (data) => data,
);
```

`dartz` se importa `hide Unit` para evitar conflicto con el tipo `Unit` propio.

## Responsabilidades por Capa

### Domain
- Entidades inmutables con Freezed.
- Interfaces (ports) de repositorios.
- Value objects.
- Servicios de dominio en `shared/domain/services/` (lógica de negocio pura,
  ej: `CoverageCalculator`, `MeasurementConverter`).
- Sin dependencias de Flutter.

### Data
- DTOs con `fromJson`/`toJson` (Freezed + json_serializable).
- Mappers bidireccionales (`fromEntity`/`toEntity`).
- DataSources que leen/escriben en Firestore (`cloud_firestore`).
- Implementación de repositorios (`*RepositoryImpl`).

### Presentation
- Providers con `dependencies:` declaradas (obligatorio, por overridabilidad
  en tests: se mockea Firebase/auth en `ProviderContainer`).
- View-models bajo `presentation/models/`.
- Screens como `ConsumerStatefulWidget` (para forms/estado local).
- Widgets como `StatelessWidget`, `ConsumerWidget` o `ConsumerStatefulWidget`.
- Uso de `AppAsyncValueWidget<T>` para renderizar `AsyncValue`.

## Gold Standard

El módulo **`features/today/`** es la referencia arquitectónica: único slice con
`domain/data/presentation` completo en disco. Consultarlo para estructura de
DTOs, repositorios, providers y widgets de presentación.
