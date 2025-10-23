#!/usr/bin/env bash
set -euo pipefail

########################
# SCRIPT DE RESTAURAÇÃO
########################

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

########################
# VALIDAÇÃO
########################

if [ $# -lt 1 ]; then
    echo "Uso: $0 <arquivo-backup.tar.gz> [opções]"
    echo ""
    echo "Opções:"
    echo "  --only-volumes       Restaura apenas os volumes Docker"
    echo "  --only-projects      Restaura apenas os projetos (docker-compose)"
    echo "  --only-databases     Restaura apenas os dumps de banco de dados"
    echo "  --project=NOME       Restaura apenas um projeto específico"
    echo "  --volume=NOME        Restaura apenas um volume específico"
    echo ""
    echo "Exemplos:"
    echo "  $0 infra-backup-2025-10-23_02-00-00.tar.gz"
    echo "  $0 backup.tar.gz --only-volumes"
    echo "  $0 backup.tar.gz --project=wordpress-compose"
    exit 1
fi

BACKUP_FILE="$1"
shift

if [ ! -f "${BACKUP_FILE}" ]; then
    log_error "Arquivo de backup não encontrado: ${BACKUP_FILE}"
    exit 1
fi

# Opções
RESTORE_VOLUMES=true
RESTORE_PROJECTS=true
RESTORE_DATABASES=true
SPECIFIC_PROJECT=""
SPECIFIC_VOLUME=""

while [ $# -gt 0 ]; do
    case "$1" in
        --only-volumes)
            RESTORE_PROJECTS=false
            RESTORE_DATABASES=false
            ;;
        --only-projects)
            RESTORE_VOLUMES=false
            RESTORE_DATABASES=false
            ;;
        --only-databases)
            RESTORE_VOLUMES=false
            RESTORE_PROJECTS=false
            ;;
        --project=*)
            SPECIFIC_PROJECT="${1#*=}"
            RESTORE_VOLUMES=false
            RESTORE_DATABASES=false
            ;;
        --volume=*)
            SPECIFIC_VOLUME="${1#*=}"
            RESTORE_PROJECTS=false
            RESTORE_DATABASES=false
            ;;
        *)
            log_error "Opção desconhecida: $1"
            exit 1
            ;;
    esac
    shift
done

########################
# EXTRAÇÃO
########################

TMP_DIR="$(mktemp -d)"
log_info "Extraindo backup para ${TMP_DIR}..."

tar xzf "${BACKUP_FILE}" -C "${TMP_DIR}"
log_success "Backup extraído"

########################
# RESTAURAÇÃO DE PROJETOS
########################

if [ "${RESTORE_PROJECTS}" = true ]; then
    log_info "=== Restaurando projetos Docker Compose ==="
    
    if [ -d "${TMP_DIR}/projects" ]; then
        for PROJECT_TAR in "${TMP_DIR}/projects"/*.tar.gz; do
            if [ -f "${PROJECT_TAR}" ]; then
                PROJECT_NAME=$(basename "${PROJECT_TAR}" .tar.gz)
                
                if [ -n "${SPECIFIC_PROJECT}" ] && [ "${PROJECT_NAME}" != "${SPECIFIC_PROJECT}" ]; then
                    continue
                fi
                
                log_info "Restaurando projeto: ${PROJECT_NAME}"
                
                if [ -d "/opt/${PROJECT_NAME}" ]; then
                    log_warning "Projeto ${PROJECT_NAME} já existe em /opt/"
                    read -p "Substituir? [s/N]: " RESPOSTA
                    if [[ ! "${RESPOSTA}" =~ ^[Ss]$ ]]; then
                        log_info "Pulando ${PROJECT_NAME}"
                        continue
                    fi
                    rm -rf "/opt/${PROJECT_NAME}"
                fi
                
                tar xzf "${PROJECT_TAR}" -C /opt/
                log_success "Projeto ${PROJECT_NAME} restaurado"
            fi
        done
    else
        log_warning "Nenhum projeto encontrado no backup"
    fi
fi

########################
# RESTAURAÇÃO DE VOLUMES
########################

if [ "${RESTORE_VOLUMES}" = true ] || [ -n "${SPECIFIC_VOLUME}" ]; then
    log_info "=== Restaurando volumes Docker ==="
    
    if [ -d "${TMP_DIR}/volumes" ]; then
        for VOL_TAR in "${TMP_DIR}/volumes"/*.tar.gz; do
            if [ -f "${VOL_TAR}" ]; then
                VOL_NAME=$(basename "${VOL_TAR}" .tar.gz)
                
                if [ -n "${SPECIFIC_VOLUME}" ] && [ "${VOL_NAME}" != "${SPECIFIC_VOLUME}" ]; then
                    continue
                fi
                
                # Se for volume anônimo, precisa criar um novo
                if [[ "${VOL_NAME}" == anon_* ]]; then
                    log_warning "Volume anônimo detectado: ${VOL_NAME}"
                    log_info "Crie manualmente o volume e execute:"
                    log_info "  docker run --rm -v NOME_VOLUME:/data -v ${TMP_DIR}/volumes:/backup busybox tar xzf /backup/${VOL_NAME}.tar.gz -C /data"
                    continue
                fi
                
                log_info "Restaurando volume: ${VOL_NAME}"
                
                # Verifica se o volume já existe
                if docker volume inspect "${VOL_NAME}" >/dev/null 2>&1; then
                    log_warning "Volume ${VOL_NAME} já existe"
                    read -p "Substituir conteúdo? [s/N]: " RESPOSTA
                    if [[ ! "${RESPOSTA}" =~ ^[Ss]$ ]]; then
                        log_info "Pulando ${VOL_NAME}"
                        continue
                    fi
                else
                    # Cria o volume
                    docker volume create "${VOL_NAME}"
                    log_success "Volume ${VOL_NAME} criado"
                fi
                
                # Restaura o conteúdo
                docker run --rm \
                    -v "${VOL_NAME}":/data \
                    -v "${TMP_DIR}/volumes":/backup \
                    busybox tar xzf "/backup/${VOL_NAME}.tar.gz" -C /data
                
                log_success "Volume ${VOL_NAME} restaurado"
            fi
        done
    else
        log_warning "Nenhum volume encontrado no backup"
    fi
fi

########################
# RESTAURAÇÃO DE BANCOS
########################

if [ "${RESTORE_DATABASES}" = true ]; then
    log_info "=== Restaurando bancos de dados ==="
    
    # MySQL
    for SQL_FILE in "${TMP_DIR}"/mysql_*.sql; do
        if [ -f "${SQL_FILE}" ]; then
            CONTAINER_NAME=$(basename "${SQL_FILE}" .sql | sed 's/^mysql_//')
            log_info "Dump MySQL encontrado para: ${CONTAINER_NAME}"
            
            if docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
                log_warning "Container ${CONTAINER_NAME} está rodando"
                log_info "Para restaurar, execute manualmente:"
                log_info "  docker exec -i ${CONTAINER_NAME} mysql -uroot -p < ${SQL_FILE}"
            else
                log_warning "Container ${CONTAINER_NAME} não está rodando"
                log_info "Inicie o container e restaure com:"
                log_info "  docker exec -i ${CONTAINER_NAME} mysql -uroot -p < ${SQL_FILE}"
            fi
        fi
    done
    
    # PostgreSQL
    for SQL_FILE in "${TMP_DIR}"/postgres_*.sql; do
        if [ -f "${SQL_FILE}" ]; then
            CONTAINER_NAME=$(basename "${SQL_FILE}" .sql | sed 's/^postgres_//')
            log_info "Dump PostgreSQL encontrado para: ${CONTAINER_NAME}"
            
            if docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
                log_warning "Container ${CONTAINER_NAME} está rodando"
                log_info "Para restaurar, execute manualmente:"
                log_info "  docker exec -i ${CONTAINER_NAME} psql -U postgres < ${SQL_FILE}"
            else
                log_warning "Container ${CONTAINER_NAME} não está rodando"
                log_info "Inicie o container e restaure com:"
                log_info "  docker exec -i ${CONTAINER_NAME} psql -U postgres < ${SQL_FILE}"
            fi
        fi
    done
fi

########################
# INFORMAÇÕES ADICIONAIS
########################

log_info "=== Informações do backup ==="

if [ -f "${TMP_DIR}/docker-networks.txt" ]; then
    log_info "Networks disponíveis no backup:"
    cat "${TMP_DIR}/docker-networks.txt"
fi

if [ -f "${TMP_DIR}/docker-containers.txt" ]; then
    log_info "Containers no momento do backup:"
    cat "${TMP_DIR}/docker-containers.txt"
fi

########################
# LIMPEZA
########################

log_warning "Arquivos extraídos mantidos em: ${TMP_DIR}"
log_info "Para limpar manualmente: rm -rf ${TMP_DIR}"

log_success "========================================="
log_success "RESTAURAÇÃO CONCLUÍDA!"
log_success "========================================="
log_info "Lembre-se de:"
log_info "  1. Iniciar os containers: cd /opt/PROJETO && docker compose up -d"
log_info "  2. Verificar logs: docker compose logs -f"
log_info "  3. Restaurar dumps de banco manualmente se necessário"

