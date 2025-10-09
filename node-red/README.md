# Node-RED

Plataforma de automação baseada em fluxos.

## Configuração Inicial

1. Copie o arquivo de exemplo:
```bash
cp .env.example .env
```

2. Edite o `.env` e configure usuário/senha de acesso

## Deploy

```bash
cd node-red
docker-compose up -d
```

## Acesso

- **Local**: `http://localhost:1880`
- **Via proxy**: `http://nodered.adspg.tec.br`

## Estrutura

- `docker-compose.yml`: Configuração do container
- `.env`: Variáveis de ambiente
- `data/`: Dados do Node-RED (flows, nodes instalados) - não versionado

## Backup

Os flows estão em `./data` - faça backup regular deste diretório.

