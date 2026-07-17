# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

`menuario` is a **feature-complete, standalone Flutter app** for meal planning,
pantry coverage and shopping — it replaces a Notion "Nutrición" workspace. It is
NOT a scaffold. Four tabs ship in production:

- **Hoy** — what to cook today (cook schedule) + today's meals by slot
- **Semana** — weekly planning: recipes assigned to each day's meal slots
- **Abastecer** — Despensa (stock) + Comprar (calculated shopping list) + coverage
- **Recetario** — recipe CRUD (BOM, videos, enable/disable) + ingredient CRUD

Backed by **Cloud Firestore** (per-user, Google Sign-In). Stack: **Riverpod 3**,
**Freezed**, **dartz** (`Either<Failure, T>`), **go_router**, **reactive_forms**,
**json_serializable**. Android is the configured platform.

> The toolchain is managed with **FVM** — prefix commands with `fvm`.

## Commands

- Install deps: `fvm flutter pub get`
- Run (device/emulator attached): `fvm flutter run`
- Static analysis: `fvm flutter analyze`
- Format: `fvm dart format .`
- All tests: `fvm flutter test`
- One file: `fvm flutter test test/src/features/recipes/...`
- By name: `fvm flutter test --name "<substring>"`
- Codegen (after editing Freezed/JSON models): `fvm dart run build_runner build --delete-conflicting-outputs`
- Release APK: `fvm flutter build apk`

Requires Firebase config that is **not committed** (`android/app/google-services.json`,
`lib/firebase_options.dart` via `flutterfire configure`). Toolchain: Dart `^3.12.2`.

## Architecture

```
lib/src/
├── core/      # auth, error (Failure/FailureException), firebase, routing, theme
├── features/  # auth, ingredients, provisioning, recipes, shopping, today, week (mostly presentation)
└── shared/    # SHARED KERNEL: domain (entities, value_objects, services), data (DTOs, datasources, repos),
              #   presentation/widgets/app_async_value_widget.dart (the only shared widget)
```

- **No UseCase layer.** Data flow: `Widget → Provider → Repository → DataSource → Firestore`.
  Business logic lives in `shared/domain/services/` (coverage_calculator, measurement_converter,
  provisioning_calculator, stock_lens_service, shopping_list_builder).
- Most features are presentation-only; their domain/data live in the shared kernel.
  **`lib/src/features/today/` is the gold-standard slice** (full domain/data/presentation).
- **DI is Firebase-based**: `firebaseFirestoreProvider` + `currentUidProvider` → `<x>DataSourceProvider`
  → `<x>RepositoryProvider` → controllers/list/detail/submission providers. **Every provider declares
  `dependencies:`** (for test overridability).
- Errors are **2-tier**: `Failure` (domain, in `Either`) → `FailureException` (thrown in providers so
  `AsyncValue` captures it) → UI reads `.message` via `AppAsyncValueWidget`. There is NO `ErrorPresenter`.

## Conventions

The authoritative rulebook lives in **`.claude/rules/**`** and skills in **`.claude/skills/**`**
(architecture, providers, forms, dtos, submission, widgets, theme, testing). Key rules:

- Absolute imports `package:menuario/src/...` (never relative). No per-feature barrels.
- `flutter_lints` via `analysis_options.yaml`; `dart format`; ≤ 80 cols; trailing commas; `const` where possible.
- `AppAsyncValueWidget` for `AsyncValue` (never `.when()` directly). `MenuarioSpacing.*` / `MenuarioTypography.*`
  (qualified). `log()` from `dart:developer` (never `print`); typed catch (`on FailureException` / `on Exception`).
- **Forms** use `reactive_forms` (`NotifierProvider.autoDispose<XFormController, FormGroup>`, `Notifier<FormGroup>`
  under Riverpod 3 — NOT `AutoDisposeNotifier`). **`ref.listen` goes at the root of `build()`, NEVER in
  `initState`/`listenManual`** (that mistake shipped a `setState during build` crash). Edit prefill = watch the
  async value in `build()`, guard with a flag, seed via `WidgetsBinding.instance.addPostFrameCallback`.

## Testing

Strict TDD. `flutter_test` + `mocktail` + `fake_cloud_firestore` + `mock_exceptions`;
providers via `ProviderContainer` overriding `firebaseFirestoreProvider`/`currentUidProvider`
or repository providers. `test/` mirrors `lib/src/`.

> Tests are unit/widget only — they do NOT exercise the app on a real device. Navigation-transition
> crashes and layout overflow are invisible to `fvm flutter test`; verify UI changes on a device.
