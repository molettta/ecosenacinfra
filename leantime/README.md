# Leantime

Sistema de gerenciamento de projetos.

## Configuração Inicial

1. Copie o arquivo de exemplo:
```bash
cp .env.example .env
```

2. Edite o arquivo `.env` e configure as credenciais do banco de dados

3. Crie o banco de dados no MySQL:
```sql
CREATE DATABASE leantime;
CREATE USER 'leantime_user'@'%' IDENTIFIED BY 'sua_senha_aqui';
GRANT ALL PRIVILEGES ON leantime.* TO 'leantime_user'@'%';
FLUSH PRIVILEGES;
```

## Deploy

```bash
cd leantime
docker-compose up -d
```

## Acesso

- **Local**: `http://localhost:8081`
- **Via proxy**: `http://leantime.adspg.tec.br`

## Estrutura

- `docker-compose.yml`: Configuração do container
- `.env`: Variáveis de ambiente

