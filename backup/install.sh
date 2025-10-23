#!/usr/bin/env bash
set -euo pipefail

########################
# INSTALADOR DO SISTEMA DE BACKUP
########################

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════╗
║           INSTALADOR DO SISTEMA DE BACKUP                         ║
║                  Infraestrutura Docker                            ║
╚═══════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Verificar se está rodando como root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Este script precisa ser executado como root ou com sudo${NC}"
    exit 1
fi

# Diretório de instalação
INSTALL_DIR="/opt/backup"

echo -e "${BLUE}➜${NC} Instalando sistema de backup em: ${INSTALL_DIR}"
echo ""

# Verifica se já existe
if [ -d "${INSTALL_DIR}" ]; then
    echo -e "${YELLOW}⚠️  O diretório ${INSTALL_DIR} já existe!${NC}"
    read -p "Deseja sobrescrever? [s/N]: " RESPOSTA
    
    if [[ ! "${RESPOSTA}" =~ ^[Ss]$ ]]; then
        echo "Instalação cancelada."
        exit 0
    fi
    
    echo -e "${YELLOW}Fazendo backup da instalação anterior...${NC}"
    if [ -d "${INSTALL_DIR}.backup" ]; then
        rm -rf "${INSTALL_DIR}.backup"
    fi
    mv "${INSTALL_DIR}" "${INSTALL_DIR}.backup"
    echo -e "${GREEN}✓${NC} Backup salvo em: ${INSTALL_DIR}.backup"
fi

# Cria estrutura de diretórios
echo -e "${BLUE}➜${NC} Criando estrutura de diretórios..."
mkdir -p "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}/scripts"
mkdir -p "${INSTALL_DIR}/dados"

# Copia arquivos
echo -e "${BLUE}➜${NC} Copiando arquivos..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cp "${SCRIPT_DIR}/backup" "${INSTALL_DIR}/"
cp "${SCRIPT_DIR}/scripts/"*.sh "${INSTALL_DIR}/scripts/"
cp "${SCRIPT_DIR}/README.md" "${INSTALL_DIR}/"
cp "${SCRIPT_DIR}/GUIA-RAPIDO.txt" "${INSTALL_DIR}/"
cp "${SCRIPT_DIR}/INSTALACAO.txt" "${INSTALL_DIR}/"
cp "${SCRIPT_DIR}/dados/.gitignore" "${INSTALL_DIR}/dados/"
cp "${SCRIPT_DIR}/dados/README.txt" "${INSTALL_DIR}/dados/"

# Permissões
echo -e "${BLUE}➜${NC} Configurando permissões..."
chmod +x "${INSTALL_DIR}/backup"
chmod +x "${INSTALL_DIR}/scripts/"*.sh

# Cria link simbólico no PATH
echo -e "${BLUE}➜${NC} Criando comando 'backup' no PATH..."
if [ -f "/usr/local/bin/backup" ]; then
    rm -f "/usr/local/bin/backup"
fi
ln -s "${INSTALL_DIR}/backup" /usr/local/bin/backup

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           INSTALAÇÃO CONCLUÍDA COM SUCESSO!                       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📂 Sistema instalado em:${NC} ${INSTALL_DIR}"
echo -e "${BLUE}💾 Backups serão salvos em:${NC} ${INSTALL_DIR}/dados/"
echo ""
echo -e "${GREEN}🚀 Primeiros Passos:${NC}"
echo ""
echo "  1. Teste o comando principal:"
echo -e "     ${YELLOW}backup${NC}"
echo ""
echo "  2. Faça seu primeiro backup:"
echo -e "     ${YELLOW}backup fazer${NC}"
echo ""
echo "  3. Configure backup automático:"
echo -e "     ${YELLOW}backup agendar${NC}"
echo ""
echo "  4. Configure sincronização remota (opcional):"
echo -e "     ${YELLOW}backup sync${NC}"
echo ""
echo -e "${BLUE}📖 Documentação:${NC}"
echo "  - Completa:    cat ${INSTALL_DIR}/README.md"
echo "  - Guia rápido: cat ${INSTALL_DIR}/GUIA-RAPIDO.txt"
echo "  - Ajuda:       backup --help"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
echo ""

