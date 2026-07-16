# Reglas de Desarrollo menuario

Sistema de reglas modulares para el desarrollo de la app `menuario`.

## Estructura

```
rules/
├── architecture/       # Clean Architecture y estructura de features
│   ├── clean-architecture.md
│   └── feature-structure.md
├── conventions/        # Formato, imports y nomenclatura
│   ├── formatting.md
│   ├── imports.md
│   ├── naming.md
│   └── dot-shorthands.md   # Dot shorthands (Dart 3.10+)
├── patterns/           # Patrones de código (CRÍTICOS)
│   ├── providers.md    # Dependencies obligatorias
│   ├── forms.md        # Patrón objetivo reactive_forms
│   ├── dtos.md
│   ├── submission.md
│   └── widgets.md
├── quality/            # Anti-patrones y checklist
│   ├── errors-to-avoid.md
│   └── pre-code-checklist.md
└── shared/             # Componentes, tema y errores
    ├── components.md
    ├── theme.md
    └── error-handling.md
```

## Path Targeting

Cada archivo de reglas incluye un frontmatter con `paths:` que indica cuándo aplica:

```yaml
---
paths:
  - "**/providers/**/*.dart"
  - "**/*_provider.dart"
---
```

## Gold Standard

Para nuevos slices verticales, usar el módulo **`features/today/`** como referencia
(es el único con el slice domain/data/presentation completo en disco):
- Provider: `features/today/presentation/providers/cook_schedule_provider.dart`
- Screen: `features/today/presentation/screens/cook_schedule_screen.dart`
- DTO: `features/today/data/models/cook_schedule_dto.dart`
- Repository: `features/today/data/repositories/cook_schedule_repository_impl.dart`
- DataSource: `features/today/data/datasources/cook_schedule_data_source.dart`
- Puerto abstracto: `features/today/domain/repositories/cook_schedule_repository.dart`

La mayoría del resto de features son solo presentación; su dominio/datos viven en el
shared kernel (`lib/src/shared/domain/**`, `lib/src/shared/data/**`).

## Prioridad de Reglas

1. **patterns/** - Reglas críticas (providers, forms, submission)
2. **architecture/** - Estructura del proyecto
3. **conventions/** - Estilo de código
4. **shared/** - Referencia de componentes
5. **quality/** - Validación pre-código
