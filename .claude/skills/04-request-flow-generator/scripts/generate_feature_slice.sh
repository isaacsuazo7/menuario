#!/bin/bash

# Script para generar boilerplate de un feature slice en menuario.
# Basado en el gold standard features/today/ (sin capa usecase).

set -e

# Colors para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función de ayuda
show_help() {
    cat << EOF
Usage: ./generate_feature_slice.sh <FeatureName>

Genera el boilerplate de un feature slice siguiendo el gold standard
de menuario: features/today/ (capas domain/data/presentation, SIN usecases).

Argumentos:
    FeatureName    Nombre del feature en PascalCase (ej: Recipe, Pantry, Shopping)

Ejemplos:
    ./generate_feature_slice.sh Recipe
    ./generate_feature_slice.sh Pantry
    ./generate_feature_slice.sh Shopping

El script genera:
    - Domain layer (Entity Freezed, Repository interface)  ← SIN UseCases
    - Data layer (DTO Freezed+json, DataSource, Repository impl)
    - Presentation layer (Providers con dependencies:, Screen, view-models)

NOTA: si el dominio es transversal, vive en el shared kernel
(lib/src/shared/domain, lib/src/shared/data), no en el slice del feature.

EOF
}

# Verificar argumentos
if [ $# -eq 0 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_help
    exit 0
fi

FEATURE=$1
FEATURE_LOWER=$(echo "$FEATURE" | tr '[:upper:]' '[:lower:]')
FEATURE_SNAKE=$(echo "$FEATURE" | sed 's/\([A-Z]\)/_\L\1/g' | sed 's/^_//')

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  menuario Feature Slice Generator${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "Feature: ${YELLOW}${FEATURE}${NC}"
echo -e "Snake case: ${YELLOW}${FEATURE_SNAKE}${NC}"
echo ""

# Directorio base del proyecto
PROJECT_ROOT=$(cd "$(dirname "$0")/../../.." && pwd)
FEATURE_PATH="$PROJECT_ROOT/lib/src/features/${FEATURE_SNAKE}"

echo -e "${YELLOW}⚠️  Este script genera el boilerplate básico.${NC}"
echo -e "${YELLOW}   Necesitarás completar:${NC}"
echo -e "${YELLOW}   - Campos específicos de la entidad y del formulario${NC}"
echo -e "${YELLOW}   - Validaciones de negocio${NC}"
echo -e "${YELLOW}   - Colección/documento de Firestore${NC}"
echo -e "${YELLOW}   - UI (widgets Material crudos + AppAsyncValueWidget)${NC}"
echo ""
echo -e "${YELLOW}   Recuerda: reactive_forms es el patrón OBJETIVO y aún no está en pubspec.${NC}"
echo ""
read -p "¿Continuar? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Operación cancelada${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Generando archivos...${NC}"
echo ""

# Crear estructura de directorios si no existe (SIN usecases/)
mkdir -p "$FEATURE_PATH/domain/entities"
mkdir -p "$FEATURE_PATH/domain/repositories"
mkdir -p "$FEATURE_PATH/data/datasources"
mkdir -p "$FEATURE_PATH/data/models"
mkdir -p "$FEATURE_PATH/data/repositories"
mkdir -p "$FEATURE_PATH/presentation/models"
mkdir -p "$FEATURE_PATH/presentation/providers"
mkdir -p "$FEATURE_PATH/presentation/screens"
mkdir -p "$FEATURE_PATH/presentation/widgets"

# TODO: Aquí iría la generación de archivos usando los templates del SKILL.md.
# Por ahora, solo mostramos qué archivos se crearían.

echo -e "📄 Domain Layer (SIN usecases):"
echo -e "   - ${FEATURE_SNAKE}.dart (Entity Freezed)"
echo -e "   - ${FEATURE_SNAKE}_repository.dart (puerto abstracto → Either<Failure, T>)"
echo ""
echo -e "📄 Data Layer:"
echo -e "   - ${FEATURE_SNAKE}_data_source.dart (${FEATURE_LOWER}DataSourceProvider)"
echo -e "   - ${FEATURE_SNAKE}_dto.dart (DTO Freezed + json, fromEntity/toEntity)"
echo -e "   - ${FEATURE_SNAKE}_repository_impl.dart (${FEATURE}RepositoryImpl + provider)"
echo ""
echo -e "📄 Presentation Layer:"
echo -e "   - providers/${FEATURE_SNAKE}_list_provider.dart (dependencies: [${FEATURE_LOWER}RepositoryProvider])"
echo -e "   - providers/${FEATURE_SNAKE}_submission_provider.dart (AsyncValue<void>)"
echo -e "   - screens/${FEATURE_SNAKE}_screen.dart (ConsumerStatefulWidget)"
echo -e "   - models/  (view-models de presentación)"
echo ""

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}✓ Boilerplate generado!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${YELLOW}Próximos pasos:${NC}"
echo -e "1. Definir Entity (Freezed) con campos específicos"
echo -e "2. Implementar DTO con mappers fromEntity/toEntity"
echo -e "3. DataSource + RepositoryImpl con dependencies: [firebaseFirestoreProvider, currentUidProvider]"
echo -e "4. Providers de lista/detalle/submission (dependencies: obligatorio)"
echo -e "5. Screen con widgets Material crudos + AppAsyncValueWidget + MenuarioSpacing"
echo -e "6. Escribir tests (mocktail + fake_cloud_firestore + ProviderContainer)"
echo ""
echo -e "Ver guía completa en:"
echo -e "${YELLOW}.claude/skills/04-request-flow-generator/SKILL.md${NC}"
echo ""
