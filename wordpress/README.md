# WordPress

WordPress conectado ao MySQL existente.

## Configuração Inicial

1. Copie o arquivo de exemplo:
```bash
cp .env.example .env
```

2. Edite o arquivo `.env` e configure:
   - Credenciais do banco de dados
   - Gere chaves de segurança em: https://api.wordpress.org/secret-key/1.1/salt/

3. Crie o banco de dados no MySQL (se ainda não existir):
```sql
CREATE DATABASE wordpress;
CREATE USER 'wordpress_user'@'%' IDENTIFIED BY 'sua_senha_aqui';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress_user'@'%';
FLUSH PRIVILEGES;
```

## Deploy

```bash
cd wordpress
docker-compose up -d
```

## Acesso

- **WordPress**: `http://localhost:8000` (ou porta configurada no .env)
- Acesso via reverse proxy: `http://adspg.tec.br`

## Estrutura

- `docker-compose.yml`: Configuração do container
- `.env`: Variáveis de ambiente (senhas, configurações)
- `uploads.ini`: Configurações PHP (limites de upload)
- `wp-content/`: Arquivos do WordPress (plugins, temas, uploads) - não versionado

## Observações

- O diretório `wp-content` não é versionado (contém uploads e arquivos customizados)
- Configure backups regulares do banco de dados e wp-content
- As chaves de segurança devem ser únicas em cada instalação

