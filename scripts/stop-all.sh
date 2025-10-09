#!/bin/bash
# Script para parar todos os serviços
# Uso: ./stop-all.sh

set -e

echo "🛑 Parando todos os serviços..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Diretório base
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

stop_service() {
    local service=$1
    local dir="${BASE_DIR}/${service}"
    
    if [ ! -d "$dir" ]; then
        return
    fi
    
    echo -e "${RED}⏹️  Stopping ${service}...${NC}"
    cd "$dir"
    
    if [ -f "docker-compose.yml" ]; then
        docker-compose down
        echo -e "${GREEN}✅ ${service} stopped${NC}"
    fi
}

# Parar reverse-proxy primeiro
stop_service "reverse-proxy"

# Parar demais serviços
stop_service "leantime"
stop_service "wordpress"
stop_service "n8n"
stop_service "node-red"
stop_service "node-red-churrasqueira"
stop_service "mosquitto"

# MySQL por último
stop_service "mysql"

echo ""
echo -e "${GREEN}✅ Todos os serviços foram parados!${NC}"

