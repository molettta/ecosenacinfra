<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Laravel - Bem-vindo</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #333;
        }

        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            padding: 3rem;
            max-width: 800px;
            width: 90%;
            text-align: center;
            animation: fadeIn 0.6s ease-in;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .logo {
            font-size: 4rem;
            font-weight: bold;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 1rem;
        }

        h1 {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            color: #2d3748;
        }

        .subtitle {
            font-size: 1.2rem;
            color: #718096;
            margin-bottom: 2rem;
            line-height: 1.6;
        }

        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
            margin: 2rem 0;
        }

        .feature {
            padding: 1.5rem;
            background: #f7fafc;
            border-radius: 10px;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .feature:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        }

        .feature-icon {
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
        }

        .feature h3 {
            font-size: 1.1rem;
            color: #2d3748;
            margin-bottom: 0.5rem;
        }

        .feature p {
            font-size: 0.9rem;
            color: #718096;
        }

        .buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
            margin-top: 2rem;
        }

        .btn {
            padding: 0.75rem 2rem;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-block;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.4);
        }

        .btn-secondary {
            background: white;
            color: #667eea;
            border: 2px solid #667eea;
        }

        .btn-secondary:hover {
            background: #667eea;
            color: white;
        }

        .info {
            margin-top: 2rem;
            padding: 1.5rem;
            background: #edf2f7;
            border-radius: 10px;
            text-align: left;
        }

        .info h3 {
            color: #2d3748;
            margin-bottom: 1rem;
        }

        .info ul {
            list-style: none;
            color: #4a5568;
        }

        .info li {
            padding: 0.5rem 0;
            padding-left: 1.5rem;
            position: relative;
        }

        .info li:before {
            content: "✓";
            position: absolute;
            left: 0;
            color: #48bb78;
            font-weight: bold;
        }

        .version {
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid #e2e8f0;
            color: #a0aec0;
            font-size: 0.9rem;
        }

        @media (max-width: 768px) {
            .container {
                padding: 2rem 1.5rem;
            }

            .logo {
                font-size: 3rem;
            }

            h1 {
                font-size: 2rem;
            }

            .features {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">Laravel</div>
        <h1>Bem-vindo ao Laravel!</h1>
        <p class="subtitle">
            Seu ambiente Docker está configurado e pronto para uso.<br>
            Comece a desenvolver sua aplicação agora mesmo.
        </p>

        <div class="features">
            <div class="feature">
                <div class="feature-icon">🐳</div>
                <h3>Docker</h3>
                <p>Ambiente containerizado e isolado</p>
            </div>
            <div class="feature">
                <div class="feature-icon">🗄️</div>
                <h3>MySQL</h3>
                <p>Banco de dados configurado</p>
            </div>
            <div class="feature">
                <div class="feature-icon">⚡</div>
                <h3>PHP 8.2</h3>
                <p>Performance e recursos modernos</p>
            </div>
            <div class="feature">
                <div class="feature-icon">🚀</div>
                <h3>Pronto</h3>
                <p>Comece a desenvolver agora</p>
            </div>
        </div>

        <div class="buttons">
            <a href="https://laravel.com/docs" target="_blank" class="btn btn-primary">
                📚 Documentação
            </a>
            <a href="http://localhost:8080" target="_blank" class="btn btn-secondary">
                🗄️ PHPMyAdmin
            </a>
        </div>

        <div class="info">
            <h3>🚀 Próximos Passos:</h3>
            <ul>
                <li>Configure seu arquivo .env com as variáveis de ambiente</li>
                <li>Execute as migrações: <code>docker-compose exec laravel php artisan migrate</code></li>
                <li>Crie seus modelos e controladores</li>
                <li>Desenvolva sua aplicação!</li>
            </ul>
        </div>

        <div class="version">
            Laravel {{ app()->version() }} | PHP {{ PHP_VERSION }} | Docker Ready
        </div>
    </div>
</body>
</html>


