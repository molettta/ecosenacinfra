#!/usr/bin/env bash
set -euo pipefail

echo "=== Configurador de Backup Automático ==="
echo ""
echo "Este script vai configurar o backup automático no cron."
echo ""
echo "Escolha a frequência:"
echo "  1) Diariamente às 02:00"
echo "  2) Diariamente às 03:00"
echo "  3) A cada 12 horas (02:00 e 14:00)"
echo "  4) Semanalmente (Domingo às 02:00)"
echo "  5) Personalizado"
echo ""
read -p "Opção [1-5]: " OPCAO

case ${OPCAO} in
    1)
        CRON_EXPR="0 2 * * *"
        DESC="Diariamente às 02:00"
        ;;
    2)
        CRON_EXPR="0 3 * * *"
        DESC="Diariamente às 03:00"
        ;;
    3)
        CRON_EXPR="0 2,14 * * *"
        DESC="A cada 12 horas (02:00 e 14:00)"
        ;;
    4)
        CRON_EXPR="0 2 * * 0"
        DESC="Semanalmente (Domingo às 02:00)"
        ;;
    5)
        echo ""
        echo "Digite a expressão cron personalizada:"
        echo "Formato: MIN HORA DIA MÊS DIA_SEMANA"
        echo "Exemplo: 0 3 * * * (todo dia às 03:00)"
        read -p "Expressão cron: " CRON_EXPR
        DESC="Personalizado: ${CRON_EXPR}"
        ;;
    *)
        echo "Opção inválida!"
        exit 1
        ;;
esac

echo ""
echo "Configuração: ${DESC}"
echo "Expressão cron: ${CRON_EXPR}"
echo ""

# Cria um arquivo de log para os backups
BACKUP_LOG="/var/log/backup-infra.log"
sudo touch "${BACKUP_LOG}" 2>/dev/null || BACKUP_LOG="/opt/backup/backup-infra.log"

# Adiciona ao crontab
CRON_LINE="${CRON_EXPR} /opt/backup/scripts/backup-infra.sh >> ${BACKUP_LOG} 2>&1"

# Verifica se já existe
CURRENT_CRON=$(crontab -l 2>/dev/null || true)

if echo "${CURRENT_CRON}" | grep -q "backup-infra.sh"; then
    echo "⚠️  Já existe um agendamento para backup-infra.sh no cron!"
    echo ""
    echo "${CURRENT_CRON}" | grep "backup-infra.sh"
    echo ""
    read -p "Deseja substituir? [s/N]: " RESPOSTA
    
    if [[ "${RESPOSTA}" =~ ^[Ss]$ ]]; then
        # Remove a linha antiga e adiciona a nova
        NEW_CRON=$(echo "${CURRENT_CRON}" | grep -v "backup-infra.sh" || true)
        if [ -n "${NEW_CRON}" ]; then
            (echo "${NEW_CRON}"; echo "${CRON_LINE}") | crontab -
        else
            echo "${CRON_LINE}" | crontab -
        fi
        echo "✓ Agendamento atualizado!"
    else
        echo "Operação cancelada."
        exit 0
    fi
else
    # Adiciona ao cron
    if [ -n "${CURRENT_CRON}" ]; then
        (echo "${CURRENT_CRON}"; echo "${CRON_LINE}") | crontab -
    else
        echo "${CRON_LINE}" | crontab -
    fi
    echo "✓ Agendamento criado!"
fi

echo ""
echo "=== Configuração Concluída ==="
echo "Frequência: ${DESC}"
echo "Log: ${BACKUP_LOG}"
echo ""
echo "Para ver o crontab atual: crontab -l"
echo "Para remover o agendamento: crontab -e (e apagar a linha do backup)"
echo "Para testar o backup agora: /opt/backup/scripts/backup-infra.sh"
echo ""

