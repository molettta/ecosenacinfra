#!/bin/bash

# Script de inicialização do sistema de hospedagem

echo "🚀 Iniciando Sistema de Hospedagem de Alunos..."
echo ""

# Criar pastas necessárias
echo "📁 Criando estrutura de pastas..."
mkdir -p sites
mkdir -p pure-ftpd/passwd
mkdir -p backups

# Tornar script de gerenciamento executável
chmod +x gerenciar-alunos.sh

# Iniciar containers
echo ""
echo "🐳 Iniciando containers Docker..."
docker compose up -d

echo ""
echo "⏳ Aguardando containers iniciarem..."
sleep 5

# Verificar status
echo ""
echo "📊 Status dos containers:"
docker compose ps

echo ""
echo "✅ Sistema iniciado com sucesso!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Próximos passos:"
echo ""
echo "1. Adicionar um aluno:"
echo "   ./gerenciar-alunos.sh adicionar joao senha123"
echo ""
echo "2. Acessar página inicial:"
echo "   http://localhost:8084/"
echo ""
echo "3. Acessar site do aluno:"
echo "   http://localhost:8084/joao/"
echo ""
echo "4. Conectar via FTP:"
echo "   Host: localhost"
echo "   Porta: 21"
echo "   Usuário: joao"
echo "   Senha: senha123"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📖 Para mais informações, consulte o README.md"
echo ""

