---
paths:
  - "lib/src/features/**/*.dart"
  - "lib/src/shared/**/*.dart"
---

# Estructura de Features

## Patrón de Referencia: `features/today/`

El módulo **`today`** es el **gold standard**: es el único slice con capas
`domain/data/presentation` completas en disco, por lo que se usa como referencia
para nuevos features.

### Árbol de Referencia

```
features/today/
├── data/
│   ├── datasources/
│   │   └── cook_schedule_data_source.dart   # cookScheduleDataSourceProvider
│   ├── models/
│   │   ├── cook_schedule_dto.dart           # (+ .freezed.dart .g.dart)
│   │   └── cook_target_dto.dart
│   └── repositories/
│       └── cook_schedule_repository_impl.dart  # CookScheduleRepositoryImpl + provider
├── domain/
│   ├── entities/
│   │   └── cook_schedule.dart               # (+ .freezed.dart)
│   ├── repositories/
│   │   └── cook_schedule_repository.dart     # port abstracto
│   └── value_objects/
│       └── cook_target.dart
└── presentation/
    ├── models/                              # view-models de presentación
    │   ├── cook_item.dart
    │   └── day_toggles.dart
    ├── providers/                           # cook_list_provider, cook_schedule_provider,
    │   │                                    #   now_provider, today_meals_provider,
    │   │                                    #   today_tab_provider
    ├── screens/
    │   └── cook_schedule_screen.dart        # ConsumerStatefulWidget
    ├── widgets/                             # _cook_body.dart → _CookBody,
    │   │                                    #   _eat_body.dart, _today_header.dart,
    │   │                                    #   today_meal_detail_sheet.dart
    ├── today_screen.dart
    └── greeting.dart
```

> ⚠️ La mayoría de features son **solo presentación**: su `domain`/`data` viven
> en `lib/src/shared/domain/**` y `lib/src/shared/data/**`. Crear `domain/data`
> dentro del feature solo cuando el slice lo justifique (como `today/`).

## Checklist para Nuevos Features

### Domain Layer (solo si el slice es completo)
- [ ] Entidad con Freezed (`@freezed abstract class`)
- [ ] Propiedades inmutables
- [ ] Value objects donde aplique
- [ ] Contrato de repositorio (port abstracto)
- [ ] Sin lógica de presentación
- [ ] Lógica de negocio pura → domain Service en `shared/domain/services/`
      (NO existe capa de use cases)

### Data Layer (solo si el slice es completo)
- [ ] DTO con `fromJson` factory (Freezed + json_serializable)
- [ ] `fromEntity()` static method para Entity → DTO
- [ ] `toEntity()` extension method para DTO → Entity
- [ ] Extension con sufijo `X` (ej: `CookScheduleDTOX`)
- [ ] DataSource contra Firestore con su provider
- [ ] `*RepositoryImpl` implementando el port, con su provider

### Presentation Layer
- [ ] View-models bajo `presentation/models/`
- [ ] Providers con `dependencies:` declaradas
- [ ] Screen es `ConsumerStatefulWidget` (para forms/estado local)
- [ ] Widgets privados como `_PascalCase`
- [ ] Uso de `AppAsyncValueWidget<T>` para datos async

## Estructura de Archivos

### Nomenclatura
- **Entidades**: `[nombre].dart` (ej: `cook_schedule.dart`)
- **DTOs**: `[nombre]_dto.dart` (ej: `cook_schedule_dto.dart`)
- **DataSources**: `[nombre]_data_source.dart`
- **Repositorios**: `[nombre]_repository.dart` / `[nombre]_repository_impl.dart`
- **Providers**: `[acción]_provider.dart` (ej: `today_meals_provider.dart`)
- **Screens**: `[nombre]_screen.dart`
- **View-models**: `[nombre].dart` bajo `presentation/models/`

### Barrels
**No existen barrels por feature.** No hay archivos `today.dart`, `recipes.dart`,
etc. Los imports son de ruta explícita y granular, p. ej.:

```dart
import 'package:menuario/src/features/today/presentation/providers/today_meals_provider.dart';
```

Solo existen barrels transversales en `core/` y `shared/` (ver reglas de imports).

## Organización por Funcionalidad

### Features Actuales
- `today/` - Vista del día (gold standard, slice completo)
- `week/` - Plan semanal
- `recipes/` - Recetas
- `auth/` - Autenticación (sign-in)
- (otras features solo-presentación apoyadas en el shared kernel)

### Core (Transversal)
- `auth/` - Estado de autenticación, `currentUidProvider`
- `error/` - `Failure`, `FailureException`
- `firebase/` - `firebaseFirestoreProvider`, `firebaseAuthProvider`
- `routing/` - GoRouter
- `theme/` - `MenuarioTheme`, `MenuarioSpacing`, `MenuarioTypography`, theme extensions

### Shared Kernel
- `shared/domain/` - Entidades, contratos y **services** (`coverage_calculator`,
  `measurement_converter`, `provisioning_calculator`, `stock_lens_service`)
- `shared/data/` - DTOs, datasources y repositorios compartidos
- `shared/presentation/widgets/` - `AppAsyncValueWidget<T>`, `EmojiAvatar`, `MealTypeTag`
