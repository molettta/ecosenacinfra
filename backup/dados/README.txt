╔═══════════════════════════════════════════════════════════════════╗
║                   DIRETÓRIO DE BACKUPS                            ║
╚═══════════════════════════════════════════════════════════════════╝

Este diretório armazena os arquivos de backup da infraestrutura Docker.

📦 FORMATO DOS BACKUPS
─────────────────────────────────────────────────────────────────────
infra-backup-YYYY-MM-DD_HH-MM-SS.tar.gz

Exemplo: infra-backup-2025-10-23_02-00-00.tar.gz


📂 CONTEÚDO DE CADA BACKUP
─────────────────────────────────────────────────────────────────────
✓ Dumps de bancos de dados (MySQL/PostgreSQL)
✓ Todos os volumes Docker
✓ Todos os projetos Docker Compose
✓ Arquivos de configuração
✓ Metadata (containers e networks)


🔄 ROTAÇÃO AUTOMÁTICA
─────────────────────────────────────────────────────────────────────
Backups são mantidos por 7 dias (configurável)
Backups mais antigos são removidos automaticamente


💾 ESPAÇO EM DISCO
─────────────────────────────────────────────────────────────────────
Cada backup pode ocupar vários GB dependendo dos dados.
Monitore o espaço disponível regularmente:

  df -h /opt
  du -sh /opt/backup/dados/


📋 COMANDOS ÚTEIS
─────────────────────────────────────────────────────────────────────
# Listar backups
backup listar

# Ver conteúdo de um backup
tar tzf infra-backup-*.tar.gz

# Verificar tamanho
ls -lh

# Remover backups antigos manualmente
find . -name "*.tar.gz" -mtime +30 -delete

═══════════════════════════════════════════════════════════════════

