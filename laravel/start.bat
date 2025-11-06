@echo off
echo 🚀 Iniciando projeto Laravel...

REM Verificar se o Laravel já está instalado
if not exist "app\composer.json" (
    echo 📦 Laravel não encontrado. Instalando Laravel...
    docker run --rm -v "%cd%\app:/app" composer create-project laravel/laravel .
    echo ✅ Laravel instalado com sucesso!
) else (
    echo ✅ Laravel já está instalado!
)

REM Verificar se o .env existe
if not exist "app\.env" (
    echo 📝 Criando arquivo .env...
    copy env.example app\.env
    echo ✅ Arquivo .env criado!
)

REM Iniciar containers
echo 🐳 Iniciando containers Docker...
docker-compose up -d

echo.
echo ✅ Projeto Laravel está rodando!
echo 🌐 Acesse: http://localhost:8001
echo 🗄️  PHPMyAdmin: http://localhost:8080
echo.
echo 📋 Comandos úteis:
echo    - Ver logs: docker-compose logs -f laravel
echo    - Acessar container: docker-compose exec laravel bash
echo    - Parar containers: docker-compose down
echo.
echo ⚠️  Não esqueça de executar: docker-compose exec laravel php artisan key:generate

pause


