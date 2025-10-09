# Node-RED Churrasqueira

Instância separada do Node-RED para o projeto Churrasqueira.

## Configuração Inicial

1. Copie o arquivo de exemplo:
```bash
cp .env.example .env
```

2. Edite o `.env` e configure usuário/senha de acesso

## Deploy

```bash
cd node-red-churrasqueira
docker-compose up -d
```

## Acesso

- **Local**: `http://localhost:1881`
- **Via proxy**: `http://churras.adspg.tec.br`

## Estrutura

- `docker-compose.yml`: Configuração do container
- `.env`: Variáveis de ambiente
- `data/`: Dados do Node-RED (flows, nodes instalados) - não versionado

