# 🚀 Comandos Rápidos - Laravel Docker

## ⚡ Início Rápido

### 1. Certifique-se que o Docker Desktop está rodando

### 2. Navegue até a pasta
```bash
cd ecosenacinfra\laravel
```

### 3. Construa e inicie os containers
```bash
# Construir as imagens
docker compose build

# Iniciar os containers
docker compose up -d

# Ver logs
docker compose logs -f laravel
```

### 4. Configure o Laravel (primeira vez)
```bash
# Gerar chave da aplicação
docker compose exec laravel php artisan key:generate

# Limpar cache
docker compose exec laravel php artisan config:clear
docker compose exec laravel php artisan cache:clear
```

### 5. Acesse
- **Laravel**: http://localhost:8001
- **PHPMyAdmin**: http://localhost:8080
  - Usuário: `laravel`
  - Senha: `laravel`

## 📋 Comandos Úteis

### Gerenciar Containers
```bash
# Ver status
docker compose ps

# Parar containers
docker compose down

# Reiniciar containers
docker compose restart

# Ver logs
docker compose logs -f laravel
docker compose logs -f mysql
```

### Comandos Laravel
```bash
# Acessar container
docker compose exec laravel bash

# Artisan commands
docker compose exec laravel php artisan [comando]

# Exemplos:
docker compose exec laravel php artisan migrate
docker compose exec laravel php artisan route:list
docker compose exec laravel php artisan make:controller NomeController
```

### Composer
```bash
docker compose exec laravel composer install
docker compose exec laravel composer require nome/pacote
```

### NPM
```bash
docker compose exec laravel npm install
docker compose exec laravel npm run dev
```

## 🐛 Solução de Problemas

### Docker não está rodando
```bash
# Inicie o Docker Desktop e aguarde inicializar
```

### Erro de permissões
```bash
docker compose exec laravel chmod -R 775 storage bootstrap/cache
```

### Limpar e recriar
```bash
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

### Ver logs de erro
```bash
docker compose logs laravel
docker compose logs mysql
```

## ✅ Checklist de Teste

- [ ] Docker Desktop rodando
- [ ] Containers iniciados (`docker compose ps`)
- [ ] Laravel acessível em http://localhost:8001
- [ ] PHPMyAdmin acessível em http://localhost:8080
- [ ] Sem erros nos logs


