#!/usr/bin/env bash
set -euo pipefail

########################
# CONFIGURAÇÃO
########################
BACKUP_ROOT="/opt/backup/dados"      # pasta onde ficarão os backups
RETENTION_DAYS=7                     # quantos dias manter localmente
DATE="$(date +%F_%H-%M-%S)"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

########################
# FUNÇÕES
########################

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
# PREPARO
########################
mkdir -p "${BACKUP_ROOT}"
TMP_DIR="$(mktemp -d)"

log_info "=== Iniciando backup ${DATE} ==="
log_info "Diretório temporário: ${TMP_DIR}"

########################
# BACKUP DOS BANCOS DE DADOS
########################

log_info "--- Fazendo backup dos bancos de dados ---"

# MySQL/MariaDB
MYSQL_CONTAINERS=$(docker ps --filter "ancestor=mysql" --filter "ancestor=mariadb" --format "{{.Names}}" 2>/dev/null || true)
if [ -n "${MYSQL_CONTAINERS}" ]; then
    log_info "Encontrados containers MySQL/MariaDB:"
    for CONTAINER in ${MYSQL_CONTAINERS}; do
        log_info "  - Fazendo dump de: ${CONTAINER}"
        
        # Tenta pegar a senha root
        MYSQL_PASS=$(docker exec "${CONTAINER}" printenv MYSQL_ROOT_PASSWORD 2>/dev/null || true)
        
        if [ -n "${MYSQL_PASS}" ]; then
            docker exec "${CONTAINER}" sh -c \
                "mysqldump --all-databases --single-transaction --routines --triggers -uroot -p'${MYSQL_PASS}'" \
                > "${TMP_DIR}/mysql_${CONTAINER}.sql" 2>/dev/null || log_warning "Falha no dump de ${CONTAINER}"
            
            if [ -f "${TMP_DIR}/mysql_${CONTAINER}.sql" ]; then
                SIZE=$(du -h "${TMP_DIR}/mysql_${CONTAINER}.sql" | cut -f1)
                log_success "Dump MySQL ${CONTAINER}: ${SIZE}"
            fi
        else
            log_warning "MYSQL_ROOT_PASSWORD não encontrado para ${CONTAINER}"
        fi
    done
else
    log_info "Nenhum container MySQL/MariaDB encontrado"
fi

# PostgreSQL
POSTGRES_CONTAINERS=$(docker ps --filter "ancestor=postgres" --format "{{.Names}}" 2>/dev/null || true)
if [ -n "${POSTGRES_CONTAINERS}" ]; then
    log_info "Encontrados containers PostgreSQL:"
    for CONTAINER in ${POSTGRES_CONTAINERS}; do
        log_info "  - Fazendo dump de: ${CONTAINER}"
        
        # Tenta pegar a senha
        POSTGRES_PASS=$(docker exec "${CONTAINER}" printenv POSTGRES_PASSWORD 2>/dev/null || true)
        POSTGRES_USER=$(docker exec "${CONTAINER}" printenv POSTGRES_USER 2>/dev/null || echo "postgres")
        
        if [ -n "${POSTGRES_PASS}" ]; then
            docker exec -e PGPASSWORD="${POSTGRES_PASS}" "${CONTAINER}" \
                pg_dumpall -U "${POSTGRES_USER}" \
                > "${TMP_DIR}/postgres_${CONTAINER}.sql" 2>/dev/null || log_warning "Falha no dump de ${CONTAINER}"
            
            if [ -f "${TMP_DIR}/postgres_${CONTAINER}.sql" ]; then
                SIZE=$(du -h "${TMP_DIR}/postgres_${CONTAINER}.sql" | cut -f1)
                log_success "Dump PostgreSQL ${CONTAINER}: ${SIZE}"
            fi
        else
            log_warning "POSTGRES_PASSWORD não encontrado para ${CONTAINER}"
        fi
    done
else
    log_info "Nenhum container PostgreSQL encontrado"
fi

########################
# BACKUP DOS VOLUMES
########################

log_info "--- Fazendo backup dos volumes Docker ---"

# Pega todos os volumes
VOLUMES=$(docker volume ls -q)
VOLUME_COUNT=$(echo "${VOLUMES}" | wc -l)

log_info "Encontrados ${VOLUME_COUNT} volumes para backup"

VOLUME_BACKUP_DIR="${TMP_DIR}/volumes"
mkdir -p "${VOLUME_BACKUP_DIR}"

COUNTER=0
for VOL in ${VOLUMES}; do
    COUNTER=$((COUNTER + 1))
    # Limita nome do arquivo para volumes com hash
    if [[ "${VOL}" =~ ^[a-f0-9]{64}$ ]]; then
        # Volume anônimo (hash)
        VOL_NAME="anon_${VOL:0:12}"
    else
        # Volume nomeado
        VOL_NAME="${VOL}"
    fi
    
    log_info "[${COUNTER}/${VOLUME_COUNT}] Backupeando volume: ${VOL}"
    
    docker run --rm \
        -v "${VOL}":/data:ro \
        -v "${VOLUME_BACKUP_DIR}":/backup \
        busybox tar czf "/backup/${VOL_NAME}.tar.gz" -C /data . 2>/dev/null || log_warning "Falha no backup de ${VOL}"
    
    if [ -f "${VOLUME_BACKUP_DIR}/${VOL_NAME}.tar.gz" ]; then
        SIZE=$(du -h "${VOLUME_BACKUP_DIR}/${VOL_NAME}.tar.gz" | cut -f1)
        log_success "Volume ${VOL}: ${SIZE}"
    fi
done

########################
# BACKUP DOS PROJETOS DOCKER COMPOSE
########################

log_info "--- Fazendo backup dos projetos Docker Compose ---"

PROJECTS_DIR="${TMP_DIR}/projects"
mkdir -p "${PROJECTS_DIR}"

# Lista todos os diretórios em /opt que contêm docker-compose.yml
for PROJECT_DIR in /opt/*/; do
    PROJECT_NAME=$(basename "${PROJECT_DIR}")
    
    if [ -f "${PROJECT_DIR}/docker-compose.yml" ] || [ -f "${PROJECT_DIR}/docker-compose.yaml" ]; then
        log_info "Backupeando projeto: ${PROJECT_NAME}"
        
        # Cria um tar.gz de todo o diretório do projeto
        tar czf "${PROJECTS_DIR}/${PROJECT_NAME}.tar.gz" \
            -C "/opt" \
            "${PROJECT_NAME}" \
            2>/dev/null || log_warning "Falha parcial no backup de ${PROJECT_NAME}"
        
        if [ -f "${PROJECTS_DIR}/${PROJECT_NAME}.tar.gz" ]; then
            SIZE=$(du -h "${PROJECTS_DIR}/${PROJECT_NAME}.tar.gz" | cut -f1)
            log_success "Projeto ${PROJECT_NAME}: ${SIZE}"
        fi
    fi
done

########################
# BACKUP DAS NETWORKS
########################

log_info "--- Salvando informações das networks Docker ---"

docker network ls > "${TMP_DIR}/docker-networks.txt"
log_success "Lista de networks salva"

########################
# BACKUP DA LISTA DE CONTAINERS
########################

log_info "--- Salvando estado dos containers ---"

docker ps -a > "${TMP_DIR}/docker-containers.txt"
log_success "Lista de containers salva"

########################
# PACOTE FINAL
########################

FINAL="${BACKUP_ROOT}/infra-backup-${DATE}.tar.gz"
log_info "--- Empacotando tudo em ${FINAL} ---"

tar czf "${FINAL}" -C "${TMP_DIR}" . 2>/dev/null

if [ -f "${FINAL}" ]; then
    FINAL_SIZE=$(du -h "${FINAL}" | cut -f1)
    log_success "Backup final criado: ${FINAL} (${FINAL_SIZE})"
else
    log_error "Falha ao criar backup final!"
    exit 1
fi

log_info "Limpando arquivos temporários..."
rm -rf "${TMP_DIR}"

########################
# ROTAÇÃO LOCAL
########################

log_info "--- Rotação de backups locais ---"
log_info "Mantendo backups dos últimos ${RETENTION_DAYS} dias"

DELETED=$(find "${BACKUP_ROOT}" -type f -name "infra-backup-*.tar.gz" -mtime +${RETENTION_DAYS} -delete -print | wc -l)

if [ "${DELETED}" -gt 0 ]; then
    log_success "Removidos ${DELETED} backups antigos"
else
    log_info "Nenhum backup antigo para remover"
fi

########################
# RESUMO
########################

log_success "========================================="
log_success "BACKUP CONCLUÍDO COM SUCESSO!"
log_success "========================================="
log_info "Arquivo: ${FINAL}"
log_info "Tamanho: ${FINAL_SIZE}"
log_info ""
log_info "Para transferir este backup para outro servidor, use:"
log_info "  scp ${FINAL} usuario@servidor-destino:/caminho/destino/"
log_info ""
log_info "Ou via rsync:"
log_info "  rsync -avz --progress ${FINAL} usuario@servidor-destino:/caminho/destino/"
log_success "========================================="

