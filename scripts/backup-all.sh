#!/bin/bash
# Script para fazer backup completo de todos os serviços
# Uso: ./backup-all.sh

set -e

echo "💾 Iniciando backup completo da infraestrutura..."

# Configurações
BACKUP_DIR="/root/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Criar diretórios de backup
mkdir -p "${BACKUP_DIR}/mysql"
mkdir -p "${BACKUP_DIR}/volumes"

echo ""
echo "1️⃣ Backup do MySQL..."
bash "$(dirname "${BASH_SOURCE[0]}")/backup-mysql.sh"

echo ""
echo "2️⃣ Backup dos volumes de dados..."

backup_volume() {
    local service=$1
    local source_dir="${BASE_DIR}/${service}/data"
    
    if [ -d "$source_dir" ]; then
        echo -e "${GREEN}📦 Fazendo backup de ${service}...${NC}"
        tar -czf "${BACKUP_DIR}/volumes/${service}_${DATE}.tar.gz" -C "${BASE_DIR}/${service}" data
        echo -e "${GREEN}✅ ${service} backup completo${NC}"
    else
        echo -e "${YELLOW}⚠️  Diretório de dados não encontrado para ${service}${NC}"
    fi
}

# Backup dos volumes
backup_volume "n8n"
backup_volume "node-red"
backup_volume "node-red-churrasqueira"
backup_volume "mosquitto"

# Backup do wp-content do WordPress
if [ -d "${BASE_DIR}/wordpress/wp-content" ]; then
    echo -e "${GREEN}📦 Fazendo backup do WordPress...${NC}"
    tar -czf "${BACKUP_DIR}/volumes/wordpress_wp-content_${DATE}.tar.gz" -C "${BASE_DIR}/wordpress" wp-content
    echo -e "${GREEN}✅ WordPress backup completo${NC}"
fi

echo ""
echo -e "${GREEN}✨ Backup completo finalizado!${NC}"
echo "📁 Backups salvos em: ${BACKUP_DIR}"
echo ""
echo "📊 Resumo:"
du -sh "${BACKUP_DIR}/mysql"/* 2>/dev/null | tail -1
du -sh "${BACKUP_DIR}/volumes"/* 2>/dev/null | head -5

# Limpeza de backups antigos (manter últimos 7 dias)
echo ""
echo "🧹 Limpando backups antigos (mantendo últimos 7 dias)..."
find "${BACKUP_DIR}/volumes" -name "*.tar.gz" -mtime +7 -delete
echo -e "${GREEN}✅ Limpeza concluída!${NC}"

