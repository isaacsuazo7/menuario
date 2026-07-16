---
name: "Guiding Clean Architecture"
description: "Trigger: new feature slice, domain entity, provider dependencies chain, layer integration in menuario. Clean-ish core/features/shared-kernel arch, Riverpod deps, Either/Failure, Firebase DI, no usecase layer."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Guiding Clean Architecture

## Cuándo usar

- Al crear un nuevo feature module (slice vertical)
- Al implementar nuevas entidades de dominio
- Al configurar la cadena de `dependencies` de providers
- Al resolver problemas de integración entre capas

## Capas del proyecto

menuario organiza el código en tres raíces bajo `lib/src/`:

- `lib/src/core/` — transversal: `auth`, `error`, `firebase`, `routing`, `theme`.
- `lib/src/features/` — slices verticales (mayormente **solo presentación**).
- `lib/src/shared/` — **shared kernel**: aquí vive la mayor parte del
  `domain`/`data` (entidades, DTOs, repositorios, servicios de dominio) más el
  único widget compartido (`AppAsyncValueWidget`).

⚠️ La mayoría de los features son **solo presentación**; su `domain`/`data`
reside en `lib/src/shared/domain/**` y `lib/src/shared/data/**`. Solo `today`
tiene un slice completo `domain/data/presentation` en disco.

⚠️ **NO existe capa de usecases** (no hay carpeta `usecases/` en ningún lado).
La lógica de negocio vive en `lib/src/shared/domain/services/`
(`coverage_calculator.dart`, `measurement_converter.dart`,
`provisioning_calculator.dart`, `stock_lens_service.dart`). El flujo de datos es
`Widget → Provider → Repository → DataSource → Firestore`, sin salto de UseCase.

## Gold Standard: `features/today/`

Módulo de referencia con slice completo:

```
features/today/
├── data/
│   ├── datasources/cook_schedule_data_source.dart   (cookScheduleDataSourceProvider)
│   ├── models/cook_schedule_dto.dart (+ .freezed.dart .g.dart), cook_target_dto.dart
│   └── repositories/cook_schedule_repository_impl.dart (CookScheduleRepositoryImpl + provider)
├── domain/
│   ├── entities/cook_schedule.dart (+ .freezed.dart)
│   ├── repositories/cook_schedule_repository.dart    (puerto abstracto)
│   └── value_objects/cook_target.dart
└── presentation/
    ├── models/       (cook_item.dart, day_toggles.dart)   ← view-models de presentación
    ├── providers/    (cook_list_provider, cook_schedule_provider, now_provider,
    │                   today_meals_provider, today_tab_provider)
    ├── screens/      (cook_schedule_screen.dart — ConsumerStatefulWidget)
    ├── widgets/      (_cook_body.dart→_CookBody, _eat_body.dart, _today_header.dart,
    │                   today_meal_detail_sheet.dart)
    ├── today_screen.dart
    └── greeting.dart
```

Los **view-models de presentación** viven en `presentation/models/`
(ej. `cook_item.dart`, `pantry_row.dart`, `shopping_row.dart`) — convención de
menuario para modelos que solo existen para pintar UI.

## Workflow de Implementación

### 1. Implementar Domain Layer

**Orden:** Entity → Repository (puerto). **No hay UseCase.**

- Entity: modelo Freezed puro, sin dependencias externas.
- Repository: contrato abstracto en `domain/repositories/`, métodos que
  retornan `Either<Failure, T>` (dartz importado con `hide Unit`).
- Lógica de negocio compleja → un **Service** de dominio en
  `lib/src/shared/domain/services/` (ej. `CoverageCalculator`,
  `MeasurementConverter`), no un UseCase.

Templates en `assets/templates/` (`entity.dart.template`, `repository.dart.template`).

### 2. Implementar Data Layer

**Orden:** DTO → DataSource → Repository Implementation

- DTO Freezed + json_serializable, archivo `*_dto.dart`, clase `*DTO`, con
  mappers bidireccionales `fromEntity` + `toEntity`.
- DataSource habla con Firestore (`cloud_firestore`), no con Dio/HTTP.
- Repository Impl retorna `Either<Failure, T>` y traduce errores a `Failure`
  (factories de dominio como `Failure.firestore`, `Failure.unauthenticated`).

Templates: `assets/templates/dto.dart.template`, `assets/templates/repository_impl.dart.template`.

### 3. Implementar Presentation Layer

**Orden:** Providers → Screens → Widgets

- Providers: `rules/patterns/providers.md` (`dependencies` OBLIGATORIAS).
- Forms: `rules/patterns/forms.md` (patrón objetivo con reactive_forms).
- Widgets: `rules/patterns/widgets.md` (`AppAsyncValueWidget`).
- Submission: `rules/patterns/submission.md`.

### 4. Verificar Dependencies Chain

Regla CRÍTICA: **TODOS** los providers declaran `dependencies` (incluso
`dependencies: const []` si no dependen de nada). Motivo en menuario:
**testeabilidad** — poder sobreescribir Firebase/auth y repositorios en un
`ProviderContainer` de tests. Ver checklist en `rules/patterns/providers.md`.

## Flujo de Datos

```
firebaseFirestoreProvider + currentUidProvider   (core/firebase, core/auth)
   → <x>DataSourceProvider     dependencies: [firebaseFirestoreProvider, currentUidProvider]
   → <x>RepositoryProvider     dependencies: [<x>DataSourceProvider]
   → controller / list / detail / submission providers
                               dependencies: [<x>RepositoryProvider, ...]
   → Widget

Either<Failure, T> ──fold──> throw FailureException(f)  →  AsyncValue captura el error
```

Sin salto de UseCase. En providers: `result.fold((f) => throw FailureException(f), (data) => data)`.

## Manejo de Errores (2 niveles)

menuario es de **2 niveles**, no 3 (no existe `ErrorPresenter`):

1. `Failure` (dominio) viaja dentro de `Either<Failure, T>`.
2. `FailureException` se lanza en providers para que `AsyncValue` lo capture;
   la UI lee `FailureException.message` (lo hace `AppAsyncValueWidget`).

Ver `rules/shared/error-handling.md`.

## Referencias

- `rules/architecture/clean-architecture.md`
- `rules/architecture/feature-structure.md`
- `rules/patterns/providers.md`
- `rules/shared/error-handling.md`

## Templates

- `assets/templates/entity.dart.template`
- `assets/templates/dto.dart.template`
- `assets/templates/repository.dart.template` (puerto abstracto)
- `assets/templates/repository_impl.dart.template` (impl + DataSource + providers con `dependencies`)

## Features de Referencia

- `lib/src/features/today/` — slice completo (Gold Standard)
- `lib/src/shared/domain/services/` — lógica de negocio (sin usecases)
- `lib/src/features/auth/` — cadena de providers de autenticación
