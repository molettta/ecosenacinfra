# 🚀 Laravel Docker Starter

Um ambiente Docker completo e pronto para uso com Laravel e MySQL, incluindo uma landing page inicial.

## 📋 Pré-requisitos

- Docker
- Docker Compose

## 🚀 Início Rápido

### 1. Clone ou baixe este repositório

### 2. Configure as variáveis de ambiente (opcional)

Edite o arquivo `.env.example` e renomeie para `.env` se quiser personalizar as configurações:

```bash
cp .env.example .env
```

### 3. Inicie o projeto

**Opção 1: Usando o script de inicialização (recomendado)**

**Windows:**
```bash
start.bat
```

**Linux/Mac:**
```bash
chmod +x start.sh
./start.sh
```

**Opção 2: Manualmente**

**Windows:**
```bash
# 1. Instalar Laravel (se ainda não tiver)
docker run --rm -v "%cd%\app:/app" composer create-project laravel/laravel .

# 2. Copiar arquivo .env
copy env.example app\.env

# 3. Iniciar containers
docker-compose up -d

# 4. Gerar chave da aplicação
docker-compose exec laravel php artisan key:generate

# 5. Executar migrações (se houver)
docker-compose exec laravel php artisan migrate
```

**Linux/Mac:**
```bash
# 1. Instalar Laravel (se ainda não tiver)
docker run --rm -v "$(pwd)/app:/app" composer create-project laravel/laravel .

# 2. Copiar arquivo .env
cp env.example app/.env

# 3. Iniciar containers
docker-compose up -d

# 4. Gerar chave da aplicação
docker-compose exec laravel php artisan key:generate

# 5. Executar migrações (se houver)
docker-compose exec laravel php artisan migrate
```

## 🌐 Acessos

- **Aplicação Laravel**: http://localhost:8001
- **PHPMyAdmin**: http://localhost:8080
  - Usuário: `laravel`
  - Senha: `laravel`

## 📁 Estrutura do Projeto

```
laravel/
├── app/                    # Diretório da aplicação Laravel
│   ├── app/
│   ├── bootstrap/
│   ├── config/
│   ├── database/
│   ├── public/
│   ├── resources/
│   ├── routes/
│   └── ...
├── mysql/
│   └── init.sql           # Script de inicialização do MySQL
├── php/
│   └── php.ini            # Configurações do PHP
├── docker-compose.yml     # Configuração dos containers
├── Dockerfile             # Imagem Docker do Laravel
├── .env.example           # Exemplo de variáveis de ambiente
├── start.sh               # Script de inicialização
└── README.md              # Este arquivo
```

## 🛠️ Comandos Úteis

### Gerenciar Containers

```bash
# Iniciar containers
docker-compose up -d

# Parar containers
docker-compose down

# Ver logs
docker-compose logs -f laravel

# Reiniciar containers
docker-compose restart
```

### Comandos Laravel

```bash
# Acessar container Laravel
docker-compose exec laravel bash

# Executar comandos Artisan
docker-compose exec laravel php artisan [comando]

# Exemplos:
docker-compose exec laravel php artisan migrate
docker-compose exec laravel php artisan make:controller NomeController
docker-compose exec laravel php artisan make:model NomeModel
docker-compose exec laravel php artisan route:list
```

### Composer

```bash
# Instalar dependências
docker-compose exec laravel composer install

# Adicionar pacote
docker-compose exec laravel composer require nome/pacote
```

### NPM

```bash
# Instalar dependências
docker-compose exec laravel npm install

# Compilar assets
docker-compose exec laravel npm run dev
docker-compose exec laravel npm run build
```

## 🗄️ Banco de Dados

### Configuração

As credenciais padrão do banco de dados são:

- **Host**: mysql (dentro do Docker) ou localhost:3306 (fora do Docker)
- **Database**: laravel
- **Username**: laravel
- **Password**: laravel
- **Root Password**: rootpassword

### Migrações

```bash
# Executar migrações
docker-compose exec laravel php artisan migrate

# Reverter última migração
docker-compose exec laravel php artisan migrate:rollback

# Criar nova migração
docker-compose exec laravel php artisan make:migration nome_da_migracao
```

## 🎨 Landing Page

O projeto inclui uma landing page inicial localizada em `app/resources/views/welcome.blade.php`. Você pode personalizá-la conforme necessário.

## 🔧 Personalização

### Alterar Portas

Edite o arquivo `docker-compose.yml`:

```yaml
ports:
  - "8001:8000"  # Altere 8001 (porta externa) para a porta desejada, 8000 é a porta interna do container
```

### Configurações do PHP

Edite o arquivo `php/php.ini` para ajustar as configurações do PHP.

### Variáveis de Ambiente

Edite o arquivo `.env` dentro do diretório `app/` para configurar a aplicação Laravel.

## 🐛 Solução de Problemas

### Erro de permissões

```bash
# No Linux/Mac, ajustar permissões
sudo chown -R $USER:$USER app/
```

### Limpar e recriar containers

```bash
docker-compose down -v
docker-compose up -d --build
```

### Ver logs de erro

```bash
docker-compose logs laravel
docker-compose logs mysql
```

## 📚 Recursos

- [Documentação Laravel](https://laravel.com/docs)
- [Documentação Docker](https://docs.docker.com/)
- [Documentação Docker Compose](https://docs.docker.com/compose/)

## 📝 Licença

Este projeto é open source e está disponível para uso livre.

## 🤝 Contribuindo

Sinta-se à vontade para fazer fork, criar issues e pull requests!

