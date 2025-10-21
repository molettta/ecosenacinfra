# PostgreSQL Docker - Servidor de Banco de Dados

## 📊 O que é?

Servidor PostgreSQL containerizado com Docker, utilizado como banco de dados compartilhado para múltiplos serviços da infraestrutura ADSPG, incluindo o Wiki.js.

## 🎯 Objetivo

Fornecer um banco de dados PostgreSQL centralizado, confiável e de alta disponibilidade para aplicações que necessitam de persistência de dados relacionais.

## 🏗️ Arquitetura

O projeto inclui três serviços principais:

### 1. **PostgreSQL**
- Banco de dados relacional
- Porta: 5432
- Versão: latest (PostgreSQL 18.0)
- Volume persistente para dados

### 2. **pgAdmin**
- Interface web para gerenciamento do PostgreSQL
- Porta: 8083
- Acesso: http://localhost:8083

### 3. **Rede Docker**
- Rede compartilhada: `princ_network`
- Permite comunicação entre containers de diferentes docker-composes

## 🔧 Configuração

### Variáveis de Ambiente

```yaml
POSTGRES_DB: princ           # Banco de dados padrão
POSTGRES_USER: prof          # Usuário principal
POSTGRES_PASSWORD: prof123   # Senha do usuário
```

### Portas Expostas

- **5432**: PostgreSQL
- **8083**: pgAdmin

### Volumes

- `postgres_data`: Dados do PostgreSQL (persistente)
- `./init.sql`: Script de inicialização

### Configurações Customizadas

- `listen_addresses = '*'`: Aceita conexões de qualquer interface
- `max_connections = 200`: Máximo de conexões simultâneas
- `shared_buffers = 256MB`: Buffer de memória compartilhada

## 📝 Script de Inicialização

O arquivo `init.sql` cria automaticamente:

```sql
-- Banco de dados de teste
CREATE DATABASE teste;

-- Usuário de teste
CREATE USER testuser WITH PASSWORD 'test123';

-- Concessão de privilégios
GRANT ALL PRIVILEGES ON DATABASE teste TO testuser;
ALTER USER testuser CREATEDB;
```

## 🚀 Como Usar

### Iniciar os serviços

```bash
cd /opt/postgresql
docker compose up -d
```

### Parar os serviços

```bash
docker compose down
```

### Verificar logs

```bash
docker logs princ_postgresql
docker logs princ_pgadmin
```

### Acessar o PostgreSQL via linha de comando

```bash
docker exec -it princ_postgresql psql -U prof -d princ
```

## 🔐 Acesso ao pgAdmin

1. Acesse: http://localhost:8083
2. Login: `admin@princ.com`
3. Senha: `admin123`

### Adicionar Servidor no pgAdmin

1. Clique em "Add New Server"
2. **General Tab:**
   - Name: `PostgreSQL Local`
3. **Connection Tab:**
   - Host: `princ_postgresql`
   - Port: `5432`
   - Username: `prof`
   - Password: `prof123`

## 📦 Bancos de Dados Criados

### Banco Principal: `princ`
- Usuário: `prof` / `prof123`
- Uso: Geral

### Banco Wiki.js: `wikijs`
- Usuário: `prof` / `prof123`
- Uso: Wiki.js

### Banco Teste: `teste`
- Usuário: `testuser` / `test123`
- Uso: Desenvolvimento e testes

## 🔗 Conectando Aplicações

### Via Docker (mesma rede)

```yaml
services:
  sua_aplicacao:
    environment:
      DB_HOST: princ_postgresql
      DB_PORT: 5432
      DB_USER: prof
      DB_PASS: prof123
      DB_NAME: princ
    networks:
      - princ_network

networks:
  princ_network:
    external: true
```

### Via Host (localhost)

```bash
Host: localhost
Port: 5432
User: prof
Password: prof123
Database: princ
```

## 🛠️ Comandos Úteis

### Backup de Banco de Dados

```bash
docker exec princ_postgresql pg_dump -U prof -d wikijs > backup_wikijs.sql
```

### Restaurar Backup

```bash
cat backup_wikijs.sql | docker exec -i princ_postgresql psql -U prof -d wikijs
```

### Criar Novo Banco de Dados

```bash
docker exec princ_postgresql psql -U prof -d princ -c "CREATE DATABASE novo_banco;"
```

### Criar Novo Usuário

```bash
docker exec princ_postgresql psql -U prof -d princ -c "CREATE USER novo_usuario WITH PASSWORD 'senha123';"
docker exec princ_postgresql psql -U prof -d princ -c "GRANT ALL PRIVILEGES ON DATABASE novo_banco TO novo_usuario;"
```

### Listar Bancos de Dados

```bash
docker exec princ_postgresql psql -U prof -c "\l"
```

### Listar Usuários

```bash
docker exec princ_postgresql psql -U prof -c "\du"
```

## 🔍 Monitoramento

### Verificar Status

```bash
docker ps --filter "name=princ_postgresql"
```

### Ver Conexões Ativas

```bash
docker exec princ_postgresql psql -U prof -d princ -c "SELECT * FROM pg_stat_activity;"
```

### Ver Tamanho dos Bancos

```bash
docker exec princ_postgresql psql -U prof -c "SELECT pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) AS size FROM pg_database;"
```

## 📂 Estrutura de Arquivos

```
/opt/postgresql/
├── docker-compose.yml    # Configuração dos serviços
├── .gitignore           # Arquivos ignorados pelo Git
├── README.md            # Esta documentação
├── init.sql             # Script de inicialização
├── conf.d/              # Configurações do PostgreSQL
│   └── postgres.conf    # Configuração customizada
└── _data/               # Dados do PostgreSQL (não versionado)
```

## 🔒 Segurança

### Boas Práticas

1. **Alterar senhas padrão** em produção
2. **Restringir acesso** via firewall se necessário
3. **Fazer backups regulares** dos dados
4. **Monitorar logs** para atividades suspeitas
5. **Atualizar** regularmente a imagem do PostgreSQL

### Alterar Senha do Usuário

```bash
docker exec princ_postgresql psql -U prof -d princ -c "ALTER USER prof WITH PASSWORD 'nova_senha_forte';"
```

## 📊 Serviços que Utilizam este PostgreSQL

- ✅ **Wiki.js** - Sistema de documentação colaborativa
- 🔜 Outros serviços podem ser adicionados

## 🆘 Troubleshooting

### PostgreSQL não inicia

```bash
# Verificar logs
docker logs princ_postgresql

# Verificar permissões do volume
ls -la /opt/postgresql/_data/
```

### Erro de conexão

```bash
# Verificar se está escutando em todas as interfaces
docker exec princ_postgresql psql -U prof -d princ -c "SHOW listen_addresses;"

# Deve retornar: *
```

### Backup automático falhou

```bash
# Verificar espaço em disco
df -h

# Verificar permissões
ls -la /opt/backups/
```

## 🚀 Atualizações

### Atualizar PostgreSQL

```bash
cd /opt/postgresql
docker compose pull
docker compose down
docker compose up -d
```

**⚠️ Importante:** Sempre faça backup antes de atualizar!

## 📚 Documentação Oficial

- PostgreSQL: https://www.postgresql.org/docs/
- pgAdmin: https://www.pgadmin.org/docs/
- Docker: https://docs.docker.com/

---

**Última atualização:** Outubro 2025  
**Versão PostgreSQL:** 18.0  
**Mantido por:** Equipe ADSPG

