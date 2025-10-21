#!/bin/bash

# Script para gerenciar usuários FTP (alunos)
# Uso: ./gerenciar-alunos.sh [adicionar|remover|listar] [usuario] [senha]

CONTAINER_NAME="hospedagem_ftp"
SITES_DIR="./sites"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function print_usage() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         Gerenciador de Alunos - Hospedagem FTP           ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Uso:"
    echo -e "  ${GREEN}./gerenciar-alunos.sh adicionar <usuario> <senha>${NC}"
    echo -e "  ${GREEN}./gerenciar-alunos.sh remover <usuario>${NC}"
    echo -e "  ${GREEN}./gerenciar-alunos.sh listar${NC}"
    echo ""
    echo "Exemplos:"
    echo -e "  ${YELLOW}./gerenciar-alunos.sh adicionar joao senha123${NC}"
    echo -e "  ${YELLOW}./gerenciar-alunos.sh remover joao${NC}"
    echo -e "  ${YELLOW}./gerenciar-alunos.sh listar${NC}"
    echo ""
}

function check_container() {
    if ! docker ps | grep -q $CONTAINER_NAME; then
        echo -e "${RED}❌ Container $CONTAINER_NAME não está rodando!${NC}"
        echo -e "${YELLOW}   Execute: docker compose up -d${NC}"
        exit 1
    fi
}

function adicionar_aluno() {
    local usuario=$1
    local senha=$2
    
    if [ -z "$usuario" ] || [ -z "$senha" ]; then
        echo -e "${RED}❌ Usuário e senha são obrigatórios!${NC}"
        print_usage
        exit 1
    fi
    
    # Validar nome de usuário (apenas letras, números e underscore)
    if ! [[ "$usuario" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo -e "${RED}❌ Nome de usuário inválido! Use apenas letras, números e underscore.${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}📝 Adicionando aluno: $usuario${NC}"
    
    # Criar pasta do aluno
    mkdir -p "$SITES_DIR/$usuario"
    
    # Criar página HTML de exemplo
    cat > "$SITES_DIR/$usuario/index.html" <<EOF
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Site de $usuario</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
            padding: 20px;
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            text-align: center;
            max-width: 600px;
        }
        h1 {
            color: #667eea;
            margin-bottom: 20px;
        }
        p {
            color: #666;
            line-height: 1.6;
        }
        .emoji {
            font-size: 4em;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="emoji">🚀</div>
        <h1>Bem-vindo ao site de $usuario!</h1>
        <p>Esta é sua página inicial. Você pode editar este arquivo enviando um novo <strong>index.html</strong> via FTP.</p>
        <p style="margin-top: 20px; color: #999;">Faça upload dos seus arquivos HTML, CSS, JavaScript e imagens para personalizar seu site!</p>
    </div>
</body>
</html>
EOF
    
    # Adicionar usuário FTP no container
    echo -e "${BLUE}🔐 Criando usuário FTP...${NC}"
    docker exec $CONTAINER_NAME sh -c "printf \"$senha\n$senha\n\" | pure-pw useradd $usuario -u ftpuser -d /home/ftpusers/$usuario -m"
    docker exec $CONTAINER_NAME sh -c "pure-pw mkdb"
    
    # Definir permissões e dono correto
    chmod -R 755 "$SITES_DIR/$usuario"
    chown -R 1000:1000 "$SITES_DIR/$usuario"
    
    echo -e "${GREEN}✅ Aluno '$usuario' adicionado com sucesso!${NC}"
    echo -e "${GREEN}   URL: http://localhost:8084/$usuario/${NC}"
    echo -e "${GREEN}   FTP: localhost:21 (usuário: $usuario, senha: $senha)${NC}"
}

function remover_aluno() {
    local usuario=$1
    
    if [ -z "$usuario" ]; then
        echo -e "${RED}❌ Usuário é obrigatório!${NC}"
        print_usage
        exit 1
    fi
    
    echo -e "${YELLOW}⚠️  Removendo aluno: $usuario${NC}"
    
    # Remover usuário FTP
    docker exec $CONTAINER_NAME sh -c "pure-pw userdel $usuario -m"
    docker exec $CONTAINER_NAME sh -c "pure-pw mkdb"
    
    # Fazer backup antes de remover
    if [ -d "$SITES_DIR/$usuario" ]; then
        BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)_$usuario"
        mkdir -p "./backups"
        mv "$SITES_DIR/$usuario" "$BACKUP_DIR"
        echo -e "${GREEN}📦 Backup salvo em: $BACKUP_DIR${NC}"
    fi
    
    echo -e "${GREEN}✅ Aluno '$usuario' removido com sucesso!${NC}"
}

function listar_alunos() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    Lista de Alunos                        ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ -d "$SITES_DIR" ]; then
        for dir in "$SITES_DIR"/*; do
            if [ -d "$dir" ]; then
                usuario=$(basename "$dir")
                echo -e "${GREEN}👤 $usuario${NC}"
                echo -e "   📂 Pasta: $dir"
                echo -e "   🌐 URL: http://localhost:8084/$usuario/"
                echo ""
            fi
        done
    else
        echo -e "${YELLOW}Nenhum aluno cadastrado ainda.${NC}"
    fi
    
    echo -e "${BLUE}Usuários FTP no container:${NC}"
    docker exec $CONTAINER_NAME sh -c "pure-pw list" 2>/dev/null || echo -e "${YELLOW}Container não está rodando${NC}"
}

# Main
case "$1" in
    adicionar)
        check_container
        adicionar_aluno "$2" "$3"
        ;;
    remover)
        check_container
        remover_aluno "$2"
        ;;
    listar)
        listar_alunos
        ;;
    *)
        print_usage
        exit 1
        ;;
esac

