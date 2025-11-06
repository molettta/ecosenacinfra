# 🚀 Guia Rápido - Laravel Docker Starter

## ⚡ Início em 3 Passos

### 1️⃣ Instalar Laravel (primeira vez apenas)

```bash
docker run --rm -v "%cd%\app:/app" composer create-project laravel/laravel .
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

# Reiniciar
docker-compose restart
```

## 🎯 Próximos Passos

1. Edite `app/.env` com suas configurações
2. Crie seus modelos: `docker-compose exec laravel php artisan make:model NomeModel`
3. Crie suas rotas em `app/routes/web.php`
4. Desenvolva sua aplicação!


