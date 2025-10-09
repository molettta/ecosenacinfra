# Mosquitto MQTT Broker

Broker MQTT para comunicação IoT.

## Configuração Inicial

1. Copie o arquivo de exemplo:
```bash
cp .env.example .env
```

2. Crie usuários para o MQTT:
```bash
# Entrar no container
docker exec -it mosquitto sh

# Criar usuário (será solicitada a senha)
mosquitto_passwd -c /mosquitto/config/passwd username

# Adicionar mais usuários (sem -c para não sobrescrever)
mosquitto_passwd /mosquitto/config/passwd another_user
```

3. Configure as ACL (permissões) em `config/acl`

4. Reinicie o serviço:
```bash
docker-compose restart
```

## Deploy

```bash
cd mosquitto
docker-compose up -d
```

## Acesso

- **MQTT Port**: `1883`
- **WebSocket Port**: `9001`

## Estrutura

- `docker-compose.yml`: Configuração do container
- `.env`: Variáveis de ambiente
- `config/mosquitto.conf`: Configuração do broker
- `config/passwd`: Arquivo de senhas (não versionado - crie manualmente)
- `config/acl`: Controle de acesso
- `data/`: Dados persistentes - não versionado
- `log/`: Logs - não versionado

## Segurança

- **IMPORTANTE**: O arquivo `passwd` não é versionado. Crie-o localmente após o deploy.
- Autenticação está habilitada (`allow_anonymous false`)
- Configure as ACLs apropriadamente para cada usuário

