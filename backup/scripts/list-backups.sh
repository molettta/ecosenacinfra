#!/usr/bin/env bash

########################
# LISTA E GERENCIA BACKUPS
########################

BACKUP_ROOT="/opt/backup/dados"

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Backups Disponíveis ===${NC}"
echo ""

if [ ! -d "${BACKUP_ROOT}" ]; then
    echo "❌ Diretório de backups não encontrado: ${BACKUP_ROOT}"
    exit 1
fi

# Lista backups
BACKUPS=$(find "${BACKUP_ROOT}" -name "infra-backup-*.tar.gz" -type f | sort -r)

if [ -z "${BACKUPS}" ]; then
    echo "Nenhum backup encontrado em ${BACKUP_ROOT}"
    exit 0
fi

TOTAL=0
TOTAL_SIZE=0

echo "📦 Backups encontrados:"
echo ""

while IFS= read -r BACKUP; do
    TOTAL=$((TOTAL + 1))
    
    FILENAME=$(basename "${BACKUP}")
    SIZE=$(du -h "${BACKUP}" | cut -f1)
    DATE=$(stat -c %y "${BACKUP}" | cut -d' ' -f1,2 | cut -d'.' -f1)
    AGE_DAYS=$(( ($(date +%s) - $(stat -c %Y "${BACKUP}")) / 86400 ))
    
    # Extrai data do nome do arquivo
    if [[ "${FILENAME}" =~ ([0-9]{4}-[0-9]{2}-[0-9]{2})_([0-9]{2}-[0-9]{2}-[0-9]{2}) ]]; then
        BACKUP_DATE="${BASH_REMATCH[1]} ${BASH_REMATCH[2]//-/:}"
    else
        BACKUP_DATE="${DATE}"
    fi
    
    # Cor baseada na idade
    if [ ${AGE_DAYS} -le 7 ]; then
        COLOR="${GREEN}"
    else
        COLOR="${YELLOW}"
    fi
    
    echo -e "${COLOR}${TOTAL}.${NC} ${FILENAME}"
    echo "   📅 Data: ${BACKUP_DATE} (${AGE_DAYS} dias atrás)"
    echo "   💾 Tamanho: ${SIZE}"
    echo "   📁 Caminho: ${BACKUP}"
    echo ""
    
    # Soma tamanho total (em KB para precisão)
    SIZE_KB=$(du -k "${BACKUP}" | cut -f1)
    TOTAL_SIZE=$((TOTAL_SIZE + SIZE_KB))
    
done <<< "${BACKUPS}"

# Converte tamanho total para formato legível
if [ ${TOTAL_SIZE} -gt 1048576 ]; then
    TOTAL_SIZE_H="$(echo "scale=2; ${TOTAL_SIZE} / 1048576" | bc)G"
elif [ ${TOTAL_SIZE} -gt 1024 ]; then
    TOTAL_SIZE_H="$(echo "scale=2; ${TOTAL_SIZE} / 1024" | bc)M"
else
    TOTAL_SIZE_H="${TOTAL_SIZE}K"
fi

echo -e "${BLUE}=== Resumo ===${NC}"
echo "📊 Total de backups: ${TOTAL}"
echo "💾 Espaço ocupado: ${TOTAL_SIZE_H}"
echo ""

# Espaço disponível
DISK_AVAIL=$(df -h "${BACKUP_ROOT}" | tail -1 | awk '{print $4}')
echo "🖥️  Espaço disponível: ${DISK_AVAIL}"
echo ""

# Menu de ações
if [ "$1" != "--list-only" ]; then
    echo "Ações disponíveis:"
    echo "  1) Fazer novo backup agora"
    echo "  2) Restaurar um backup"
    echo "  3) Limpar backups antigos (mais de 7 dias)"
    echo "  4) Ver conteúdo de um backup"
    echo "  5) Sair"
    echo ""
    read -p "Escolha uma opção [1-5]: " OPCAO
    
    case ${OPCAO} in
        1)
            echo ""
            /opt/backup/scripts/backup-infra.sh
            ;;
        2)
            echo ""
            echo "Digite o número do backup para restaurar (1-${TOTAL}):"
            read -p "Número: " NUM
            
            if [ "${NUM}" -ge 1 ] && [ "${NUM}" -le "${TOTAL}" ]; then
                SELECTED=$(echo "${BACKUPS}" | sed -n "${NUM}p")
                echo ""
                echo "Restaurando: $(basename "${SELECTED}")"
                /opt/backup/scripts/restore-infra.sh "${SELECTED}"
            else
                echo "❌ Número inválido"
            fi
            ;;
        3)
            echo ""
            echo "Removendo backups com mais de 7 dias..."
            REMOVED=$(find "${BACKUP_ROOT}" -name "infra-backup-*.tar.gz" -mtime +7 -type f -delete -print)
            
            if [ -n "${REMOVED}" ]; then
                echo "✓ Backups removidos:"
                echo "${REMOVED}"
            else
                echo "Nenhum backup antigo para remover"
            fi
            ;;
        4)
            echo ""
            echo "Digite o número do backup para ver conteúdo (1-${TOTAL}):"
            read -p "Número: " NUM
            
            if [ "${NUM}" -ge 1 ] && [ "${NUM}" -le "${TOTAL}" ]; then
                SELECTED=$(echo "${BACKUPS}" | sed -n "${NUM}p")
                echo ""
                echo "Conteúdo de: $(basename "${SELECTED}")"
                echo ""
                tar tzf "${SELECTED}" | head -50
                echo ""
                echo "(mostrando primeiros 50 arquivos)"
            else
                echo "❌ Número inválido"
            fi
            ;;
        5)
            echo "Saindo..."
            ;;
        *)
            echo "❌ Opção inválida"
            ;;
    esac
fi

