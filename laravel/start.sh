#!/bin/bash

# Script para iniciar o projeto Laravel
# Este script verifica se o Laravel já está instalado, caso contrário, instala

echo "🚀 Iniciando projeto Laravel..."

# Verificar se o Laravel já está instalado
if [ ! -f "app/composer.json" ]; then
    echo "📦 Laravel não encontrado. Instalando Laravel..."
    
    # Criar projeto Laravel
    docker run --rm -v "$(pwd)/app:/app" composer create-project laravel/laravel .
    
    echo "✅ Laravel instalado com sucesso!"
else
    echo "✅ Laravel já está instalado!"
fi

# Verificar se o .env existe
if [ ! -f "app/.env" ]; then
    echo "📝 Criando arquivo .env..."
    cp .env.example app/.env
    echo "✅ Arquivo .env criado!"
fi

# Gerar chave da aplicação se necessário
echo "🔑 Verificando chave da aplicação..."
docker-compose exec laravel php artisan key:generate --force 2>/dev/null || echo "⚠️  Execute 'docker-compose exec laravel php artisan key:generate' após iniciar os containers"

# Iniciar containers
echo "🐳 Iniciando containers Docker..."
docker-compose up -d

echo ""
echo "✅ Projeto Laravel está rodando!"
echo "🌐 Acesse: http://localhost:8001"
echo "🗄️  PHPMyAdmin: http://localhost:8080"
echo ""
echo "📋 Comandos úteis:"
echo "   - Ver logs: docker-compose logs -f laravel"
echo "   - Acessar container: docker-compose exec laravel bash"
echo "   - Parar containers: docker-compose down"


