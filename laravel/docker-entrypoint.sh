#!/bin/bash
set -e

# Aguardar MySQL estar pronto
echo "Aguardando MySQL estar pronto..."
max_attempts=30
attempt=0
DB_USER="${DB_USERNAME:-laravel}"
DB_PASS="${DB_PASSWORD:-laravel}"

while [ $attempt -lt $max_attempts ]; do
    if php -r "\$pdo = new PDO('mysql:host=mysql;port=3306', '$DB_USER', '$DB_PASS'); echo 'OK';" 2>/dev/null; then
        echo "MySQL está pronto!"
        break
    fi
    attempt=$((attempt + 1))
    echo "Tentativa $attempt/$max_attempts - Aguardando MySQL..."
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "Aviso: Não foi possível conectar ao MySQL após $max_attempts tentativas"
fi

# Criar diretórios se não existirem
mkdir -p storage/framework/sessions storage/framework/views storage/framework/cache
mkdir -p storage/logs bootstrap/cache

# Ajustar permissões
chmod -R 775 storage bootstrap/cache 2>/dev/null || true

# Gerar chave da aplicação se não existir e .env existir
if [ -f .env ] && ! grep -q "APP_KEY=base64:" .env 2>/dev/null; then
    echo "Gerando chave da aplicação..."
    php artisan key:generate --force 2>/dev/null || echo "Aviso: Não foi possível gerar a chave. Execute: php artisan key:generate"
fi

# Executar migrações (opcional, descomente se necessário)
# php artisan migrate --force

# Executar o comando passado
exec "$@"

