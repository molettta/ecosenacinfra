# Infraestrutura EcoSenac

Repositório de configuração da infraestrutura de serviços do EcoSenac usando Docker Compose.

## 📋 Serviços

Este repositório gerencia os seguintes serviços:

- **[Reverse Proxy (Caddy)](./reverse-proxy)** - Proxy reverso HTTP para todos os serviços
- **[MySQL + phpMyAdmin](./mysql)** - Banco de dados relacional
- **[WordPress](./wordpress)** - Site institucional (adspg.tec.br)
- **[Leantime](./leantime)** - Gerenciamento de projetos
- **[n8n](./n8n)** - Automação de workflows
- **[Node-RED](./node-red)** - Automação baseada em fluxos
- **[Node-RED Churrasqueira](./node-red-churrasqueira)** - Instância dedicada para projeto específico
- **[Mosquitto](./mosquitto)** - Broker MQTT para IoT

## 🚀 Quick Start

### Pré-requisitos

- Docker Engine 20.10+
- Docker Compose V2+
- Git

### Instalação

1. Clone o repositório:
```bash
git clone https://github.com/molettta/ecosenacinfra.git
cd ecosenacinfra
```

2. Configure cada serviço:
```bash
# Para cada serviço, copie o .env.example para .env
cd mysql
cp .env.example .env
nano .env  # Edite com suas configurações

# Repita para cada serviço que for usar
```

3. Inicie os serviços (na ordem):
```bash
# 1. MySQL primeiro (outros dependem dele)
cd mysql
docker-compose up -d

# 2. Demais serviços
cd ../leantime && docker-compose up -d
cd ../wordpress && docker-compose up -d
cd ../n8n && docker-compose up -d
cd ../node-red && docker-compose up -d
cd ../node-red-churrasqueira && docker-compose up -d
cd ../mosquitto && docker-compose up -d

# 3. Reverse proxy por último
cd ../reverse-proxy && docker-compose up -d
```

Ou use o script de deploy:
```bash
./scripts/deploy-all.sh
```

## 🌐 Acessos

### Produção (via Cloudflare/Proxy)
- WordPress: https://adspg.tec.br
- Leantime: https://leantime.adspg.tec.br
- n8n: https://n8n.adspg.tec.br
- Node-RED: https://nodered.adspg.tec.br
- Node-RED Churras: https://churras.adspg.tec.br

### Local (desenvolvimento)
- MySQL: localhost:3306
- phpMyAdmin: http://localhost:8080
- WordPress: http://localhost:8000
- Leantime: http://localhost:8081
- n8n: http://localhost:5678
- Node-RED: http://localhost:1880
- Node-RED Churras: http://localhost:1881
- Mosquitto MQTT: localhost:1883

## 📁 Estrutura do Repositório

```
ecosenacinfra/
├── .gitignore                    # Arquivos ignorados pelo git
├── README.md                     # Este arquivo
├── backup/                       # 🆕 Sistema completo de backup
│   ├── install.sh                # Instalador do sistema
│   ├── backup                    # Script principal
│   ├── scripts/                  # Scripts do sistema
│   │   ├── backup-infra.sh
│   │   ├── restore-infra.sh
│   │   ├── list-backups.sh
│   │   ├── setup-backup-cron.sh
│   │   └── setup-backup-sync.sh
│   ├── dados/                    # Dados de backup (não versionados)
│   ├── README.md                 # Documentação completa
│   ├── GUIA-RAPIDO.txt          # Referência rápida
│   └── INSTALACAO.txt           # Guia de instalação
├── reverse-proxy/                # Caddy reverse proxy
│   ├── Caddyfile
│   ├── docker-compose.yml
│   └── README.md
├── mysql/                        # MySQL + phpMyAdmin
│   ├── docker-compose.yml
│   ├── .env.example
│   ├── init.sql                  # Script de inicialização
│   ├── my.cnf                    # Configurações MySQL
│   └── README.md
├── wordpress/                    # WordPress
│   ├── docker-compose.yml
│   ├── .env.example
│   ├── uploads.ini               # Configurações PHP
│   └── README.md
├── leantime/                     # Leantime
│   ├── docker-compose.yml
│   ├── .env.example
│   └── README.md
├── n8n/                          # n8n
│   ├── docker-compose.yml
│   ├── .env.example
│   └── README.md
├── node-red/                     # Node-RED
│   ├── docker-compose.yml
│   ├── .env.example
│   └── README.md
├── node-red-churrasqueira/       # Node-RED Churrasqueira
│   ├── docker-compose.yml
│   ├── .env.example
│   └── README.md
├── mosquitto/                    # Mosquitto MQTT
│   ├── docker-compose.yml
│   ├── .env.example
│   ├── config/
│   │   ├── mosquitto.conf
│   │   └── acl
│   └── README.md
└── scripts/                      # Scripts de automação
    ├── deploy-all.sh
    ├── backup-all.sh             # Script de backup legado
    ├── backup-mysql.sh           # Script de backup MySQL legado
    └── stop-all.sh
```

## 🔒 Segurança

### Arquivos Sensíveis

Os seguintes arquivos **NÃO** são versionados (estão no .gitignore):
- `.env` - Contém senhas e secrets
- `**/data/` - Dados dos volumes Docker
- `**/_data/` - Dados persistentes
- `*.log` - Arquivos de log
- Certificados SSL
- Backups

### Boas Práticas

1. **Nunca comite arquivos `.env`** - Use apenas `.env.example` como template
2. **Gere senhas fortes** para todos os serviços
3. **Gere chaves únicas** para WordPress e n8n
4. **Configure backups regulares** usando os scripts fornecidos
5. **Mantenha o Docker atualizado**

## 🔧 Manutenção

### Sistema de Backup Completo

Este repositório inclui um sistema completo de backup e restauração para toda a infraestrutura Docker.

#### Instalação do Sistema de Backup

```bash
cd backup
sudo ./install.sh
```

Isso instalará o sistema em `/opt/backup/` e criará o comando `backup` no PATH.

#### Uso Rápido

```bash
# Menu interativo (recomendado)
backup

# Atalhos diretos
backup fazer          # Faz backup completo agora
backup listar         # Lista backups disponíveis
backup restaurar      # Restaura um backup
backup agendar        # Configura backup automático (cron)
backup sync           # Configura sincronização remota
```

#### O que é backupeado?

- ✅ **Bancos de dados**: Dumps completos de MySQL/MariaDB e PostgreSQL
- ✅ **Volumes Docker**: Todos os volumes (nomeados e anônimos)
- ✅ **Projetos**: Todos os docker-compose.yml, .env, Caddyfile, etc
- ✅ **Metadata**: Lista de containers e networks para referência

#### Localização dos Backups

Os backups são salvos em: `/opt/backup/dados/infra-backup-YYYY-MM-DD_HH-MM-SS.tar.gz`

#### Documentação Completa

Veja a documentação completa em [backup/README.md](./backup/README.md)

### Scripts de Backup Legados

Os scripts simples ainda estão disponíveis para casos específicos:

```bash
# Backup de todos os serviços (legado)
./scripts/backup-all.sh

# Backup apenas do MySQL (legado)
./scripts/backup-mysql.sh
```

### Atualização de Imagens

```bash
# Atualizar todas as imagens
cd <servico>
docker-compose pull
docker-compose up -d
```

### Logs

```bash
# Ver logs de um serviço
cd <servico>
docker-compose logs -f

# Ou direto do container
docker logs -f <container_name>
```

### Parar Serviços

```bash
# Parar um serviço específico
cd <servico>
docker-compose down

# Parar todos
./scripts/stop-all.sh
```

## 🔄 Redes Docker

Os serviços usam redes Docker para comunicação:
- `mysql_default` - Rede compartilhada do MySQL
- `leantime_default` - Rede do Leantime
- `n8n_default` - Rede do n8n
- `nodered_default` - Rede do Node-RED
- `nodered_churras_default` - Rede do Node-RED Churrasqueira
- `mosquitto_default` - Rede do Mosquitto

## 📖 Documentação Adicional

Cada serviço possui seu próprio README com instruções específicas:
- **[Sistema de Backup](./backup/README.md)** - 🆕 Sistema completo de backup e restauração
- [Reverse Proxy](./reverse-proxy/README.md)
- [MySQL](./mysql/README.md)
- [WordPress](./wordpress/README.md)
- [Leantime](./leantime/README.md)
- [n8n](./n8n/README.md)
- [Node-RED](./node-red/README.md)
- [Node-RED Churrasqueira](./node-red-churrasqueira/README.md)
- [Mosquitto](./mosquitto/README.md)

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📝 Licença

Este projeto é de uso interno do EcoSenac.

## 👥 Contato

Para questões sobre a infraestrutura, entre em contato com a equipe de TI.

