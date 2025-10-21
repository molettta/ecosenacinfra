#!/bin/bash

# Script para parar o sistema de hospedagem

echo "🛑 Parando Sistema de Hospedagem de Alunos..."
echo ""

docker compose down

echo ""
echo "✅ Sistema parado com sucesso!"
echo ""
echo "Para iniciar novamente, execute:"
echo "  ./iniciar.sh"
echo ""

