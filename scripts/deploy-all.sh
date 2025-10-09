#!/bin/bash
# Script para fazer deploy de todos os serviços
# Uso: ./deploy-all.sh

set -e

echo "🚀 Iniciando deploy de todos os serviços..."

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Diretório base
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

deploy_service() {
    local service=$1
    local dir="${BASE_DIR}/${service}"
    
    if [ ! -d "$dir" ]; then
        echo -e "${YELLOW}⚠️  Diretório ${service} não encontrado, pulando...${NC}"
        return
    fi
    
    echo -e "${GREEN}📦 Deploying ${service}...${NC}"
    cd "$dir"
    
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}⚠️  Arquivo .env não encontrado em ${service}. Copie .env.example para .env primeiro!${NC}"
        return
    fi
    
    docker-compose up -d
    echo -e "${GREEN}✅ ${service} deployed${NC}"
    echo ""
}

# Deploy na ordem correta (MySQL primeiro, reverse-proxy por último)
echo "1️⃣ Iniciando MySQL..."
deploy_service "mysql"
sleep 5

echo "2️⃣ Iniciando serviços de aplicação..."
deploy_service "leantime"
deploy_service "wordpress"
deploy_service "n8n"
deploy_service "node-red"
deploy_service "node-red-churrasqueira"
deploy_service "mosquitto"
sleep 3

echo "3️⃣ Iniciando reverse proxy..."
deploy_service "reverse-proxy"

echo ""
echo -e "${GREEN}✨ Deploy completo!${NC}"
echo ""
echo "📊 Status dos containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

