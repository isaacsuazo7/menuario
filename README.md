# menuario

<div align="center">
  <h3>Planificador de comidas, despensa y compras</h3>
  <p>App Flutter personal que reemplaza un sistema de "Nutrición" hecho en Notion:
  recetario, planificación semanal, cobertura de despensa y lista de compras — todo
  respaldado en Cloud Firestore por usuario.</p>

  [![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-^3.12.2-0175C2?logo=dart)](https://dart.dev)
  [![Riverpod](https://img.shields.io/badge/Riverpod-3.x-42a5f5)](https://riverpod.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%2B%20Auth-FFCA28?logo=firebase)](https://firebase.google.com)
  [![Tests](https://img.shields.io/badge/tests-870%2B-blue)](test/)
  [![License](https://img.shields.io/badge/license-Private-red)](#14-licencia)
</div>

---

## 🚀 Quick start

```bash
fvm install && fvm use            # fija la versión de Flutter (.fvmrc)
fvm flutter pub get               # dependencias
flutterfire configure             # genera firebase_options.dart + google-services.json
fvm dart run build_runner build --delete-conflicting-outputs   # codegen Freezed/JSON
fvm flutter run                   # con device/emulador conectado
```

> **Sin la config de Firebase** (`google-services.json` + `lib/firebase_options.dart`,
> no versionados por ser secretos) **la app no arranca.** Detalle en
> [Instalación](#5-instalación-y-ejecución) · Verás las 4 pestañas: Hoy · Semana · Abastecer · Recetario.

---

## 📋 Tabla de Contenidos

**1.** [Descripción Ejecutiva](#1-descripción-ejecutiva)
**2.** [Motivación](#2-motivación)
**3.** [Características Principales](#3-características-principales)
**4.** [Requisitos Previos](#4-requisitos-previos)
**5.** [Instalación y Ejecución](#5-instalación-y-ejecución)
**6.** [Arquitectura](#6-arquitectura)
**7.** [Modelo de Dominio (unidades flexibles y cobertura)](#7-modelo-de-dominio-unidades-flexibles-y-cobertura)
**8.** [Testing](#8-testing)
**9.** [Comandos Útiles](#9-comandos-útiles)
**10.** [Troubleshooting](#10-troubleshooting)
**11.** [Roadmap](#11-roadmap)
**12.** [Cómo Contribuir](#12-cómo-contribuir)
**13.** [Convenciones de Código](#13-convenciones-de-código)
**14.** [Licencia](#14-licencia)

---

## 1. Descripción Ejecutiva

**menuario** es una aplicación Flutter **standalone** (no un módulo) para planificar
qué cocinar, qué se tiene en la despensa y qué falta comprar. Está construida con
**Clean-ish Architecture**, estado reactivo con **Riverpod 3** y persistencia en
**Cloud Firestore** por usuario (autenticación con Google).

| | |
|---|---|
| **Nombre** | menuario |
| **Tipo** | Aplicación Flutter (standalone) |
| **Toolchain** | Flutter 3.x / Dart `^3.12.2` (gestionado con [FVM](https://fvm.app)) |
| **Backend** | Cloud Firestore + Firebase Auth (Google Sign-In) |
| **Estado** | Feature-complete; 4 pestañas en producción |
| **Audiencia** | Privada / uso personal |

---

## 2. Motivación

menuario nace para reemplazar un sistema de **"Nutrición" armado en Notion**
(recetas, ingredientes por receta, despensa) por una app nativa, offline-capable
y con lógica real de cálculo. Problemas que resuelve:

- ❌ Recetas y despensa en tablas de Notion → ✅ Modelo de dominio con conversión de unidades
- ❌ "¿Qué cocino esta semana?" a mano → ✅ Planificación semanal por slot de comida
- ❌ "¿Qué me falta comprar?" mental → ✅ Cobertura de despensa + lista de compras calculada
- ❌ Cantidades en unidades incompatibles → ✅ Conversión receta ⇄ stock (g/kg, ml/L, taza, unidad, paquete)

---

## 3. Características Principales

La app se organiza en **4 pestañas**:

### 🍳 Hoy
- Qué toca cocinar hoy según el horario de cocción (cook schedule)
- Comidas del día por slot (Pre-gym, Desayuno, Almuerzo, Merienda, Cena…)
- Saludo según la hora del día

### 📅 Semana
- Planificación semanal: asignar recetas a cada slot de cada día
- Detalle de receta por slot; marcador del día actual

### 🛒 Abastecer
- **Despensa**: stock por ingrediente con "lente" de unidad (unidad / paquete / porcentaje)
- **Comprar**: lista de compras calculada a partir del plan semanal vs. la despensa,
  agrupada por categoría, con cantidades de compra redondeadas por presentación
- Cobertura por ingrediente (cubierto / justo / falta)

### 📖 Recetario
- CRUD de recetas: nombre, emoji, tipo de comida, videos, y **BOM** (bill of materials:
  ingredientes + cantidad + unidad derivada del ingrediente)
- CRUD de ingredientes (modo de medición, presentación, factor de conversión)
- Activar/desactivar recetas (las desactivadas quedan visibles en gris y reactivables)
- Formularios con `reactive_forms`

**Transversal**: autenticación con Google, persistencia por usuario en Firestore,
manejo de errores tipado (`Either<Failure, T>`), y un motor de conversión de unidades
que alimenta cobertura y compras.

---

## 4. Requisitos Previos

- **Flutter** 3.x sobre **Dart `^3.12.2`** — se recomienda **[FVM](https://fvm.app)**
  (`fvm use` según `.fvmrc`/`.fvm/`)
- Un **proyecto de Firebase** con Firestore y Authentication (Google) habilitados
- Archivos de configuración de Firebase **NO versionados** (ver `.gitignore`):
  - `android/app/google-services.json`
  - `lib/firebase_options.dart` (generado por `flutterfire configure`)
- Android SDK (la plataforma Android está configurada; iOS/otros requieren
  `flutter create --platforms=<...> .`)

---

## 5. Instalación y Ejecución

```bash
# 1. Clonar
git clone <repo-url> && cd menuario

# 2. Fijar la versión de Flutter (FVM)
fvm install && fvm use

# 3. Dependencias
fvm flutter pub get

# 4. Configurar Firebase (una vez)
#    Requiere firebase-cli + flutterfire_cli instalados y un proyecto Firebase.
flutterfire configure
#    → genera lib/firebase_options.dart y coloca google-services.json

# 5. Generar código (Freezed / json_serializable)
fvm dart run build_runner build --delete-conflicting-outputs

# 6. Correr (con device/emulador conectado)
fvm flutter run
```

> Sin `google-services.json` + `firebase_options.dart` la app no arranca:
> son secretos por proyecto y no están en el repo.

---

## 6. Arquitectura

### 6.1 Capas

```
lib/src/
├── core/                 # Transversal
│   ├── auth/            # Google Sign-In, estado de sesión, currentUid
│   ├── error/           # Failure, FailureException
│   ├── firebase/        # Providers de FirebaseFirestore / Auth
│   ├── routing/         # go_router
│   └── theme/           # ColorScheme (seed), MenuarioSpacing, MenuarioTypography, extensiones
│
├── features/            # Slices verticales (mayormente presentación)
│   ├── auth/  ingredients/  provisioning/  recipes/  shopping/  today/  week/
│
└── shared/              # Shared kernel
    ├── domain/          # Entidades, value objects y SERVICIOS de dominio
    │   └── services/    # coverage_calculator, measurement_converter,
    │                    #   provisioning_calculator, stock_lens_service, shopping_list_builder
    ├── data/            # DTOs (Freezed + json_serializable), datasources (Firestore), repositorios
    └── presentation/    # widgets/app_async_value_widget.dart (único widget compartido)
```

**Puntos clave** (a diferencia de un backend con capa de red):

- **NO hay capa de UseCase.** El flujo es `Widget → Provider → Repository → DataSource → Firestore`.
  La lógica de negocio vive en `shared/domain/services/`.
- La mayoría de los features son **solo presentación**; su dominio/datos viven en el shared kernel.
  El módulo `features/today/` es el **gold standard** con el slice `domain/data/presentation` completo.
- **DI basada en Firebase**: `firebaseFirestoreProvider` + `currentUidProvider` → `<x>DataSourceProvider`
  → `<x>RepositoryProvider` → providers de UI/controllers/submissions. **Todo provider declara `dependencies:`**
  (para poder sobrescribirlo en tests).

### 6.2 Flujo de datos y errores

```
Widget → Provider → Repository → DataSource → Firestore
                          │
                Either<Failure, T> ──fold──▶ throw FailureException  →  AsyncValue captura el error
```

Modelo de errores de **2 niveles**: `Failure` (dominio, dentro de `Either`) y
`FailureException` (se lanza en providers para que `AsyncValue` lo capture; la UI lee
`FailureException.message` vía `AppAsyncValueWidget`).

### 6.3 Patrones

- **Repository Pattern** con puertos abstractos + `Impl` sobre Firestore
- **Either Pattern** (`dartz`) para errores funcionales
- **DTO Pattern** (Freezed + json_serializable, mappers `fromEntity`/`toEntity`)
- **reactive_forms** para formularios (`NotifierProvider<XFormController, FormGroup>`)
- `ref.listen` siempre en `build()`; prefill de edición vía `WidgetsBinding.addPostFrameCallback`

---

## 7. Modelo de Dominio (unidades flexibles y cobertura)

El corazón de menuario es la conversión **receta ⇄ stock** y el cálculo de cobertura:

- **`MeasurementMode`** por ingrediente: `mass`, `count`, `packageBase`, `packageAbstract`, `boolean`.
- **`Unit`** con dimensión: `gram`/`kilogram` (masa), `milliliter`/`liter` (volumen),
  `count` (unidad), `cup`/`tablespoon` (cocina), más unidades de paquete.
- **`MeasurementConverter`** convierte la cantidad de una línea de BOM a la unidad de stock
  del ingrediente (aplicando un pre-pass métrico kg→g, ml→L y el `conversionFactor` del ingrediente).
- **`recipeUnitsFor(Ingredient)`** decide qué unidades ofrece el editor de BOM por ingrediente
  (solo unidades convertibles).
- **`CoverageCalculator` / `ProvisioningCalculator` / `ShoppingListBuilder`** cruzan el plan
  semanal con la despensa para producir cobertura y la lista de compras.

---

## 8. Testing

**TDD estricto.** Stack de test: `flutter_test` + `mocktail` + `fake_cloud_firestore`
(`FakeFirebaseFirestore` en memoria) + `mock_exceptions`. Los providers se prueban con
`ProviderContainer` sobrescribiendo `firebaseFirestoreProvider` / `currentUidProvider`
o los repository providers.

```bash
fvm flutter test                 # toda la suite (~870+ tests)
fvm flutter test test/src/features/recipes   # un feature
fvm flutter test --name "round-trip"         # por nombre
```

El árbol de `test/` es espejo de `lib/src/`. Se cubren datasources (round-trip contra
`FakeFirebaseFirestore`, mapeo de errores, aislamiento por usuario), repositorios (DTO ⇄ Entity),
servicios de dominio, providers (`AsyncValue`) y widgets.

> ⚠️ Los tests son unit/widget: **no** ejercen la app en un device real. Cambios de UI
> con transiciones de navegación o layout deben verificarse manualmente en un dispositivo.

---

## 9. Comandos Útiles

```bash
fvm flutter pub get                                          # dependencias
fvm flutter run                                              # correr (device/emulador)
fvm flutter analyze                                          # análisis estático
fvm flutter test                                             # tests
fvm dart format .                                            # formato
fvm dart run build_runner build --delete-conflicting-outputs # codegen (Freezed/JSON)
fvm flutter build apk                                        # APK release
```

---

## 10. Troubleshooting

**La app no arranca / error de Firebase** → falta `lib/firebase_options.dart` o
`android/app/google-services.json`. Correr `flutterfire configure`.

**Errores de `*.freezed.dart` / `*.g.dart` no encontrados** → correr
`fvm dart run build_runner build --delete-conflicting-outputs` tras modificar entidades/DTOs.

**`setState()/markNeedsBuild() called during build`** → un `ref.listen` mal ubicado.
`ref.listen` va **siempre al root de `build()`**, nunca en `initState`/`listenManual`
(ver `.claude/rules/patterns/forms.md`).

**"No se pudieron calcular: <ingrediente>"** en Comprar → el ingrediente no tiene una
conversión válida entre la unidad de la receta y su unidad de stock (revisar `MeasurementMode`
y `conversionFactor` del ingrediente).

---

## 11. Roadmap

- [x] Persistencia en Firestore por usuario (auth Google, offline)
- [x] Recetario (CRUD, BOM, videos, activar/desactivar)
- [x] Despensa + smart-stock + CRUD de ingredientes
- [x] Planificación semanal (Semana) y horario de cocción (Hoy)
- [x] Unidades flexibles (modos de medición + conversión)
- [x] Cobertura de despensa + lista de compras (Abastecer)
- [x] Slot de comida `Pre-gym` (`MealType.pregym`)
- [ ] Escaneo de código de barras (Open Food Facts) para identidad de producto
- [ ] Limpieza de campos legacy remanentes en datos históricos

---

## 12. Cómo Contribuir

1. **Rama por cambio** (nunca `main` directo): `feature/…`, `fix/…`, `refactor/…`, `docs/…`.
2. **Commits Convencionales**: `type(scope): descripción` (`feat`, `fix`, `refactor`, `docs`, `test`, `chore`…).
3. **PRs apilados a main**; se mergea cada slice antes del siguiente (no apilar profundo).
4. **TDD**: toda funcionalidad/bugfix con tests que lo validen; sin regresiones.

---

## 13. Convenciones de Código

El proyecto trae un **rulebook** propio en `.claude/rules/**` y skills en `.claude/skills/**`
(arquitectura, providers, forms, DTOs, submission, widgets, tema, testing). Resumen:

- Imports absolutos `package:menuario/src/...` (sin relativos)
- `flutter_lints` vía `analysis_options.yaml`; `dart format`; ≤ 80 columnas; trailing commas
- Providers con `dependencies:`; `AppAsyncValueWidget` para `AsyncValue`
- `MenuarioSpacing.*` / `MenuarioTypography.*` (cualificados); `Failure`/`FailureException`
- `log()` de `dart:developer` (nunca `print`); catch tipado

Referencia de módulo: **`lib/src/features/today/`** (slice completo).

---

## 14. Licencia

Software privado / de uso personal. © 2026 Isaac Suazo. Todos los derechos reservados.

<div align="center">
  <sub>Hecho con Flutter · Riverpod · Firebase</sub>
</div>
