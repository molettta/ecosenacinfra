FROM php:8.2-cli

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Instalar Node.js e NPM
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Configurar diretório de trabalho
WORKDIR /var/www/html

# Copiar apenas composer.json e package.json primeiro (para cache do Docker)
COPY app/composer.json* app/package.json* ./

# Instalar dependências do Composer (se composer.json existir)
RUN if [ -f "composer.json" ]; then \
    composer install --no-interaction --prefer-dist --no-scripts --no-autoloader; \
    fi

# Copiar o resto dos arquivos
COPY app/ /var/www/html/

# Completar instalação do Composer
RUN if [ -f "composer.json" ]; then \
    composer dump-autoload --optimize; \
    fi

# Instalar dependências do NPM (se package.json existir)
RUN if [ -f "package.json" ]; then \
    npm install; \
    fi

# Criar diretórios necessários e ajustar permissões
RUN mkdir -p storage/framework/sessions storage/framework/views storage/framework/cache \
    storage/logs bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache || true

# Expor porta 8000
EXPOSE 8000

# Script de inicialização
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]

