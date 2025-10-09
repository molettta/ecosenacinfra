# n8n - Workflow Automation

Plataforma de automação de workflows.

## Configuração Inicial

1. Copie o arquivo de exemplo:
```bash
cp .env.example .env
```

2. Gere uma chave de criptografia forte:
```bash
openssl rand -base64 32
```

3. Edite o `.env` e adicione a chave gerada

## Deploy

```bash
cd n8n
docker-compose up -d
```

## Acesso

- **Local**: `http://localhost:5678`
- **Via proxy**: `http://n8n.adspg.tec.br`

## Estrutura

- `docker-compose.yml`: Configuração do container
- `.env`: Variáveis de ambiente
- `data/`: Dados do n8n (workflows, credenciais) - não versionado
- `local-files/`: Arquivos locais acessíveis pelos workflows - não versionado

## Backup

Os workflows e credenciais estão em `./data` - faça backup regular deste diretório.

