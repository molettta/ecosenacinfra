# ⚡ Início Rápido - Laravel Docker

## 🚀 Começar em 3 Passos

### 1️⃣ Instalar Laravel (primeira vez)

**Windows:**
```cmd
docker run --rm -v "%cd%\app:/app" composer create-project laravel/laravel .
```

**Linux/Mac:**
```bash
docker run --rm -v "$(pwd)/app:/app" composer create-project laravel/laravel .
```

### 2️⃣ Iniciar Containers

```bash
docker-compose up -d
```

### 3️⃣ Configurar Laravel

```bash
# Gerar chave da aplicação
docker-compose exec laravel php artisan key:generate

# Executar migrações (se houver)
docker-compose exec laravel php artisan migrate
```

## 🌐 Acessos

- **Laravel**: http://localhost:8001
- **PHPMyAdmin**: http://localhost:8080
  - Usuário: `laravel`
  - Senha: `laravel`

## 📋 Comandos Úteis

```bash
# Ver logs
docker-compose logs -f laravel

# Acessar container
docker-compose exec laravel bash

# Parar containers
docker-compose down

# Criar modelo
docker-compose exec laravel php artisan make:model NomeModel

# Criar controller
docker-compose exec laravel php artisan make:controller NomeController
```

## ✅ Pronto!

Agora você pode começar a desenvolver sua aplicação Laravel!


