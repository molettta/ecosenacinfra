# 🔄 Sistema de Backup da Infraestrutura Docker

Sistema completo de backup e restauração para toda infraestrutura Docker em `/opt`.

## 📂 Estrutura de Pastas

```
/opt/backup/
├── backup                      # Script principal (use este!)
├── scripts/                    # Scripts do sistema
│   ├── backup-infra.sh
│   ├── restore-infra.sh
│   ├── list-backups.sh
│   ├── setup-backup-cron.sh
│   └── setup-backup-sync.sh
├── dados/                      # Onde os backups são salvos
│   └── infra-backup-*.tar.gz
├── README.md                   # Esta documentação
└── GUIA-RAPIDO.txt            # Referência rápida

```

## 📋 O que é backupeado?

- ✅ **Bancos de dados**: Dumps completos de MySQL/MariaDB e PostgreSQL
- ✅ **Volumes Docker**: Todos os volumes (nomeados e anônimos)
- ✅ **Projetos**: Todos os docker-compose.yml, .env, Caddyfile, etc
- ✅ **Metadata**: Lista de containers e networks para referência

## 🚀 Como usar

### Modo Simples (Recomendado)

De qualquer diretório, execute:

```bash
backup
```

Um menu interativo será exibido com todas as opções!

### 1️⃣ Fazer backup manual

```bash
backup fazer
# ou
/opt/backup/scripts/backup-infra.sh
```

O backup será salvo em `/opt/backup/dados/infra-backup-YYYY-MM-DD_HH-MM-SS.tar.gz`

### 2️⃣ Listar backups disponíveis

```bash
backup listar
# ou
/opt/backup/scripts/list-backups.sh
```

### 3️⃣ Agendar backups automáticos

```bash
backup agendar
# ou
/opt/backup/scripts/setup-backup-cron.sh
```

Escolha a frequência:
- Diariamente às 02:00 ou 03:00
- A cada 12 horas
- Semanalmente
- Personalizado

### 4️⃣ Transferir backup para outro servidor

#### Via SCP
```bash
scp /opt/backup/dados/infra-backup-*.tar.gz usuario@servidor:/destino/
```

#### Via rsync (recomendado)
```bash
rsync -avz --progress /opt/backup/dados/ usuario@servidor:/destino/backups/
```

#### Sync automático
```bash
backup sync
# ou
/opt/backup/scripts/setup-backup-sync.sh
```

### 5️⃣ Restaurar backup

#### Restauração completa
```bash
backup restaurar /opt/backup/dados/infra-backup-2025-10-23_02-00-00.tar.gz
# ou
/opt/backup/scripts/restore-infra.sh /opt/backup/dados/backup.tar.gz
```

#### Restaurar apenas volumes
```bash
/opt/backup/scripts/restore-infra.sh backup.tar.gz --only-volumes
```

#### Restaurar apenas um projeto
```bash
/opt/backup/scripts/restore-infra.sh backup.tar.gz --project=wordpress-compose
```

#### Restaurar apenas um volume
```bash
/opt/backup/scripts/restore-infra.sh backup.tar.gz --volume=portainer_data
```

## 📊 Estrutura do backup

```
infra-backup-2025-10-23_02-00-00.tar.gz
├── mysql_princ_mysql.sql              # Dump do MySQL
├── postgres_princ_postgresql.sql      # Dump do PostgreSQL
├── volumes/
│   ├── portainer_data.tar.gz
│   ├── postgresql_postgres_data.tar.gz
│   └── anon_3ce307ef3102.tar.gz       # Volumes anônimos
├── projects/
│   ├── mysql.tar.gz
│   ├── postgresql.tar.gz
│   ├── wordpress-compose.tar.gz
│   ├── wiki.tar.gz
│   └── ...
├── docker-networks.txt                # Lista de networks
└── docker-containers.txt              # Estado dos containers
```

## 🔧 Configurações

### Alterar pasta de backup

Edite `/opt/backup/scripts/backup-infra.sh`:
```bash
BACKUP_ROOT="/seu/caminho/backups"
```

### Alterar retenção (quantos dias manter)

Edite `/opt/backup/scripts/backup-infra.sh`:
```bash
RETENTION_DAYS=14  # Manter por 14 dias
```

## 🌐 Backup Off-site (Nuvem)

### Opção 1: Sync automático via rsync + cron

```bash
backup sync
```

Ou adicione manualmente ao cron (crontab -e):
```bash
0 4 * * * rsync -avz --delete /opt/backup/dados/ usuario@servidor-remoto:/backups/
```

### Opção 2: Restic (Backblaze B2, AWS S3, etc)

```bash
# Instalar
apt install restic

# Configurar no final do backup-infra.sh:
export RESTIC_REPOSITORY="b2:seu-bucket:/backups"
export RESTIC_PASSWORD="senha-forte"
export B2_ACCOUNT_ID="xxxx"
export B2_ACCOUNT_KEY="xxxx"

# Descomente no script:
restic snapshots || restic init
restic backup "${FINAL}"
restic forget --prune --keep-daily 7 --keep-weekly 4
```

### Opção 3: rclone (Google Drive, Dropbox, etc)

```bash
# Instalar e configurar
apt install rclone
rclone config

# Adicionar ao final do backup-infra.sh:
rclone copy "${FINAL}" "gdrive:backups/"
```

## 📝 Logs

Ver o log dos backups automáticos:
```bash
tail -f /var/log/backup-infra.log
# ou
tail -f /opt/backup/backup-infra.log
```

## 💡 Comandos Rápidos

```bash
# Menu principal
backup

# Atalhos diretos
backup fazer          # Faz backup agora
backup listar         # Lista backups
backup restaurar      # Menu de restauração
backup agendar        # Configura cron
backup sync           # Configura sync remoto
backup ajuda          # Mostra ajuda

# Scripts individuais
/opt/backup/scripts/backup-infra.sh
/opt/backup/scripts/list-backups.sh
/opt/backup/scripts/restore-infra.sh

# Ver espaço usado
du -sh /opt/backup/dados/

# Ver último backup
ls -lht /opt/backup/dados/ | head -2
```

## ⚠️ Importante

1. **Teste os backups regularmente**: Execute uma restauração de teste!
2. **Verifique o espaço em disco**: Backups podem ocupar muito espaço
3. **Senhas dos bancos**: Estão configuradas nos containers (MySQL: cachorro, Postgres: prof123)
4. **Volumes anônimos**: Precisam ser mapeados manualmente na restauração
5. **Backups locais**: Mantidos por 7 dias (configurável)

## 🆘 Troubleshooting

### Backup muito grande?

Exclua volumes temporários ou de cache editando o script.

### Erro "permission denied"?

Execute com sudo ou ajuste permissões:
```bash
sudo backup fazer
```

### Container não encontrado no restore?

Siga as instruções exibidas para restauração manual dos dumps SQL.

### Backup travou?

Verifique espaço em disco:
```bash
df -h /opt
df -h /tmp
```

### Como limpar backups antigos manualmente?

```bash
# Remover backups com mais de 30 dias
find /opt/backup/dados/ -name "*.tar.gz" -mtime +30 -delete

# Ou use o menu interativo
backup listar
```

## 📞 Suporte

Para problemas, verifique:
1. Logs do script
2. `docker ps` - containers rodando
3. `docker volume ls` - volumes existentes
4. Espaço em disco: `df -h`
5. Permissões: `ls -la /opt/backup/`

## 🎯 Projetos Detectados

O sistema faz backup automático de todos os projetos em `/opt/`:
- mysql
- postgresql
- wordpress-compose
- wiki
- n8n
- node-red
- node-red-churrasqueira
- hospedagem-alunos
- leantime-compose
- reverse-proxy (Caddy)
- mosquitto

---

**Criado em**: Outubro 2025  
**Localização**: `/opt/backup/`  
**Comando principal**: `backup`
