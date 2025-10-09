# Reverse Proxy (Caddy)

Reverse proxy usando Caddy para rotear tráfego HTTP para os diferentes serviços.

## Serviços Configurados

- `leantime.adspg.tec.br` → Leantime (porta 8080)
- `n8n.adspg.tec.br` → n8n (porta 5678)
- `nodered.adspg.tec.br` → Node-RED (porta 1880)
- `churras.adspg.tec.br` → Node-RED Churrasqueira (porta 1880)
- `adspg.tec.br` / `www.adspg.tec.br` → WordPress (porta 80)

## Deploy

```bash
cd reverse-proxy
docker-compose up -d
```

## Observações

- O Caddy está configurado para `auto_https off` porque o HTTPS é gerenciado pelo Cloudflare
- Headers de segurança (HSTS, CSP) estão configurados para cada serviço
- O proxy força HTTPS através dos headers X-Forwarded-Proto

