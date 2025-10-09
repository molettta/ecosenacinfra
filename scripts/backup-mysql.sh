#!/bin/bash
# Script para fazer backup do MySQL
# Uso: ./backup-mysql.sh

set -e

echo "💾 Iniciando backup do MySQL..."

# Configurações
BACKUP_DIR="/root/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
CONTAINER_NAME="princ_mysql"

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Criar diretório de backup se não existir
mkdir -p "$BACKUP_DIR"

# Verificar se o container está rodando
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED}❌ Container MySQL não está rodando!${NC}"
    exit 1
fi

# Ler senha do .env ou solicitar
if [ -f "../mysql/.env" ]; then
    source ../mysql/.env
    MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}"
else
    read -sp "Digite a senha root do MySQL: " MYSQL_ROOT_PASSWORD
    echo ""
fi

# Fazer backup de todos os bancos
echo "📦 Fazendo backup de todos os bancos de dados..."
docker exec $CONTAINER_NAME mysqldump \
    -u root \
    -p"${MYSQL_ROOT_PASSWORD}" \
    --all-databases \
    --single-transaction \
    --quick \
    --lock-tables=false \
    | gzip > "${BACKUP_DIR}/mysql_all_databases_${DATE}.sql.gz"

# Verificar se o backup foi criado
if [ -f "${BACKUP_DIR}/mysql_all_databases_${DATE}.sql.gz" ]; then
    SIZE=$(du -h "${BACKUP_DIR}/mysql_all_databases_${DATE}.sql.gz" | cut -f1)
    echo -e "${GREEN}✅ Backup criado com sucesso!${NC}"
    echo "📁 Arquivo: ${BACKUP_DIR}/mysql_all_databases_${DATE}.sql.gz"
    echo "📊 Tamanho: ${SIZE}"
    
    # Manter apenas os últimos 7 backups
    echo "🧹 Limpando backups antigos (mantendo últimos 7)..."
    cd "$BACKUP_DIR"
    ls -t mysql_all_databases_*.sql.gz | tail -n +8 | xargs -r rm
    
    echo -e "${GREEN}✨ Backup concluído!${NC}"
else
    echo -e "${RED}❌ Erro ao criar backup!${NC}"
    exit 1
fi

