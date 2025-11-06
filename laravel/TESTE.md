# 🧪 Guia de Teste - Laravel Docker

## 📋 Checklist de Testes

### 1. Pré-requisitos
- [ ] Docker instalado e rodando
- [ ] Docker Compose instalado
- [ ] Portas 8001 e 8080 disponíveis

### 2. Instalação do Laravel

**Primeira vez - Instalar Laravel:**
```bash
cd laravel
docker run --rm -v "%cd%\app:/app" composer create-project laravel/laravel .
```

**Ou no Linux/Mac:**
```bash
cd laravel
docker run --rm -v "$(pwd)/app:/app" composer create-project laravel/laravel .
```

### 3. Configuração do Ambiente

**Copiar arquivo .env:**
```bash
# Windows
copy env.example app\.env

# Linux/Mac
cp env.example app/.env
```

### 4. Construir e Iniciar Containers

```bash
# Construir as imagens
docker compose build

# Iniciar os containers
docker compose up -d

# Ver logs
docker compose logs -f laravel
```

### 5. Configurar Laravel

```bash
# Gerar chave da aplicação
docker compose exec laravel php artisan key:generate

# Verificar configuração
docker compose exec laravel php artisan config:clear
docker compose exec laravel php artisan cache:clear
```

### 6. Testes de Funcionalidade

#### Teste 1: Acessar Landing Page
- [ ] Abrir http://localhost:8001
- [ ] Verificar se a página carrega
- [ ] Verificar se não há erros

#### Teste 2: PHPMyAdmin
- [ ] Abrir http://localhost:8080
- [ ] Fazer login com:
  - Usuário: `laravel`
  - Senha: `laravel`
- [ ] Verificar se consegue acessar o banco `laravel`

#### Teste 3: Conexão com Banco de Dados
```bash
docker compose exec laravel php artisan tinker
```
No tinker:
```php
DB::connection()->getPdo();
// Deve retornar informações do PDO sem erros
exit
```

#### Teste 4: Rotas
```bash
# Listar rotas
docker compose exec laravel php artisan route:list

# Testar rota de health
curl http://localhost:8001/health
```

#### Teste 5: Artisan Commands
```bash
# Verificar versão do Laravel
docker compose exec laravel php artisan --version

# Verificar ambiente
docker compose exec laravel php artisan env
```

### 7. Verificação de Logs

```bash
# Logs do Laravel
docker compose logs laravel

# Logs do MySQL
docker compose logs mysql

# Logs de todos os serviços
docker compose logs
```

### 8. Problemas Comuns

#### Erro: "APP_KEY não definida"
```bash
docker compose exec laravel php artisan key:generate
```

#### Erro: "Cannot connect to MySQL"
- Verificar se o MySQL está rodando: `docker compose ps`
- Verificar logs: `docker compose logs mysql`
- Aguardar alguns segundos para o MySQL inicializar

#### Erro: "Permission denied" no storage
```bash
docker compose exec laravel chmod -R 775 storage bootstrap/cache
```

#### Erro: "Class not found"
```bash
docker compose exec laravel composer dump-autoload
```

### 9. Limpeza e Reinício

```bash
# Parar containers
docker compose down

# Parar e remover volumes (CUIDADO: apaga dados do banco)
docker compose down -v

# Reconstruir tudo
docker compose build --no-cache
docker compose up -d
```

### 10. Status dos Containers

```bash
# Ver status
docker compose ps

# Ver uso de recursos
docker stats

# Inspecionar container
docker compose exec laravel bash
```

## ✅ Testes Bem-Sucedidos

Após todos os testes passarem, você deve ter:
- ✅ Laravel rodando em http://localhost:8001
- ✅ PHPMyAdmin rodando em http://localhost:8080
- ✅ Conexão com MySQL funcionando
- ✅ Landing page carregando corretamente
- ✅ Artisan commands funcionando
- ✅ Sem erros nos logs

## 🐛 Reportar Problemas

Se encontrar problemas, verifique:
1. Logs dos containers
2. Arquivo .env está configurado corretamente
3. Portas não estão em uso
4. Docker tem recursos suficientes (memória, CPU)


