#!/usr/bin/env bash
set -euo pipefail

########################
# CONFIGURADOR DE SYNC REMOTO
########################

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Configurador de Sync Remoto de Backups ===${NC}"
echo ""
echo "Este script configura a sincronização automática dos backups"
echo "para outro servidor usando rsync via SSH."
echo ""

# Coleta informações
read -p "🖥️  IP ou hostname do servidor remoto: " REMOTE_HOST
read -p "👤 Usuário SSH: " REMOTE_USER
read -p "📁 Caminho de destino no servidor remoto: " REMOTE_PATH
read -p "🔑 Porta SSH [22]: " SSH_PORT
SSH_PORT=${SSH_PORT:-22}

echo ""
echo -e "${YELLOW}⚠️  IMPORTANTE:${NC}"
echo "Para sincronização automática funcionar, você precisa configurar"
echo "autenticação SSH por chave pública (sem senha)."
echo ""
echo "Se ainda não configurou, execute:"
echo "  ssh-keygen -t ed25519 -C 'backup@$(hostname)'"
echo "  ssh-copy-id -p ${SSH_PORT} ${REMOTE_USER}@${REMOTE_HOST}"
echo ""

read -p "Continuar? [s/N]: " CONTINUAR

if [[ ! "${CONTINUAR}" =~ ^[Ss]$ ]]; then
    echo "Configuração cancelada."
    exit 0
fi

# Testa conexão
echo ""
echo "🔍 Testando conexão SSH..."

if ssh -p "${SSH_PORT}" -o ConnectTimeout=5 "${REMOTE_USER}@${REMOTE_HOST}" "exit" 2>/dev/null; then
    echo -e "${GREEN}✓ Conexão SSH OK!${NC}"
else
    echo "❌ Falha na conexão SSH!"
    echo "Verifique:"
    echo "  - Servidor está acessível"
    echo "  - Porta SSH está correta"
    echo "  - Credenciais estão corretas"
    echo "  - Chave SSH está configurada"
    exit 1
fi

# Testa se o diretório remoto existe
echo "🔍 Verificando diretório remoto..."

if ssh -p "${SSH_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" "mkdir -p '${REMOTE_PATH}' && test -d '${REMOTE_PATH}'" 2>/dev/null; then
    echo -e "${GREEN}✓ Diretório remoto OK!${NC}"
else
    echo "❌ Não foi possível acessar/criar: ${REMOTE_PATH}"
    exit 1
fi

# Cria script de sync
SYNC_SCRIPT="/opt/backup/scripts/sync-backups.sh"

cat > "${SYNC_SCRIPT}" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Configuração (gerada automaticamente)
REMOTE_USER="REPLACE_USER"
REMOTE_HOST="REPLACE_HOST"
REMOTE_PATH="REPLACE_PATH"
SSH_PORT="REPLACE_PORT"
BACKUP_ROOT="/opt/backup/dados"

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_info "Iniciando sincronização de backups..."
log_info "Destino: ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"

# Verifica se há backups
if [ ! -d "${BACKUP_ROOT}" ] || [ -z "$(ls -A ${BACKUP_ROOT}/*.tar.gz 2>/dev/null || true)" ]; then
    log_info "Nenhum backup para sincronizar"
    exit 0
fi

# Sincroniza
rsync -avz \
    --progress \
    --delete \
    -e "ssh -p ${SSH_PORT}" \
    "${BACKUP_ROOT}/" \
    "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/" \
    2>&1 | while read line; do
        echo "  ${line}"
    done

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    log_success "Sincronização concluída com sucesso!"
    
    # Estatísticas
    LOCAL_COUNT=$(ls -1 ${BACKUP_ROOT}/*.tar.gz 2>/dev/null | wc -l || echo 0)
    LOCAL_SIZE=$(du -sh ${BACKUP_ROOT} 2>/dev/null | cut -f1 || echo "0")
    
    log_info "Backups sincronizados: ${LOCAL_COUNT}"
    log_info "Tamanho total: ${LOCAL_SIZE}"
else
    log_error "Falha na sincronização!"
    exit 1
fi
EOF

# Substitui variáveis
sed -i "s/REPLACE_USER/${REMOTE_USER}/g" "${SYNC_SCRIPT}"
sed -i "s/REPLACE_HOST/${REMOTE_HOST}/g" "${SYNC_SCRIPT}"
sed -i "s|REPLACE_PATH|${REMOTE_PATH}|g" "${SYNC_SCRIPT}"
sed -i "s/REPLACE_PORT/${SSH_PORT}/g" "${SYNC_SCRIPT}"

chmod +x "${SYNC_SCRIPT}"

echo ""
echo -e "${GREEN}✓ Script de sync criado: ${SYNC_SCRIPT}${NC}"
echo ""

# Testa sync
read -p "Deseja testar a sincronização agora? [s/N]: " TESTAR

if [[ "${TESTAR}" =~ ^[Ss]$ ]]; then
    echo ""
    "${SYNC_SCRIPT}"
fi

echo ""
echo "Deseja agendar sync automático no cron?"
echo "  1) Após cada backup (recomendado)"
echo "  2) A cada hora"
echo "  3) Diariamente às 04:00"
echo "  4) Não agendar agora"
echo ""
read -p "Opção [1-4]: " CRON_OPCAO

case ${CRON_OPCAO} in
    1)
        # Adiciona ao final do backup-infra.sh
        if ! grep -q "sync-backups.sh" /opt/backup/scripts/backup-infra.sh; then
            echo "" >> /opt/backup/scripts/backup-infra.sh
            echo "# Sync remoto automático" >> /opt/backup/scripts/backup-infra.sh
            echo "/opt/backup/scripts/sync-backups.sh" >> /opt/backup/scripts/backup-infra.sh
            echo -e "${GREEN}✓ Sync adicionado ao script de backup${NC}"
        else
            echo -e "${YELLOW}⚠️  Sync já está configurado no backup${NC}"
        fi
        ;;
    2)
        CRON_LINE="0 * * * * /opt/backup/scripts/sync-backups.sh >> /var/log/backup-sync.log 2>&1"
        (crontab -l 2>/dev/null | grep -v "sync-backups.sh"; echo "${CRON_LINE}") | crontab -
        echo -e "${GREEN}✓ Sync agendado a cada hora${NC}"
        ;;
    3)
        CRON_LINE="0 4 * * * /opt/backup/scripts/sync-backups.sh >> /var/log/backup-sync.log 2>&1"
        (crontab -l 2>/dev/null | grep -v "sync-backups.sh"; echo "${CRON_LINE}") | crontab -
        echo -e "${GREEN}✓ Sync agendado diariamente às 04:00${NC}"
        ;;
    4)
        echo "Sync não agendado. Execute manualmente: ${SYNC_SCRIPT}"
        ;;
esac

echo ""
echo -e "${GREEN}=== Configuração Concluída ===${NC}"
echo ""
echo "📋 Comandos úteis:"
echo "  - Sincronizar agora: ${SYNC_SCRIPT}"
echo "  - Ver backups locais: /opt/backup/scripts/list-backups.sh"
echo "  - Fazer backup: /opt/backup/scripts/backup-infra.sh"
echo ""
echo "🔐 Lembre-se:"
echo "  - Backups são sincronizados para: ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"
echo "  - Use --delete remove backups remotos que não existem localmente"
echo ""

