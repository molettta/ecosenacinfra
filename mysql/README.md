# MySQL + phpMyAdmin

MySQL com phpMyAdmin para gerenciamento de banco de dados.

## Configuração Inicial

1. Copie o arquivo de exemplo:
```bash
cp .env.example .env
```

2. Edite o arquivo `.env` e configure suas senhas:
```bash
nano .env
```

3. Ajuste o `init.sql` se precisar criar bancos e usuários adicionais

## Deploy

```bash
cd mysql
docker-compose up -d
```

## Acesso

- **MySQL**: `localhost:3306` (ou porta configurada no .env)
- **phpMyAdmin**: `http://localhost:8080` (ou porta configurada no .env)

## Estrutura

- `docker-compose.yml`: Configuração dos containers
- `.env`: Variáveis de ambiente (senhas, portas)
- `init.sql`: Script de inicialização do banco
- `my.cnf`: Configurações customizadas do MySQL
- `_data/`: Dados persistentes (não versionado)

## Backup

Use o script na pasta `/scripts` do repositório:
```bash
../scripts/backup-mysql.sh
```

