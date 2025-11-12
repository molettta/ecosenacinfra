# Script PowerShell para gerenciar usuarios FTP (alunos)
# Uso: .\gerenciar-alunos.ps1 [adicionar|remover|listar] [usuario] [senha]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("adicionar", "remover", "listar")]
    [string]$Acao,
    
    [Parameter(Mandatory=$false)]
    [string]$Usuario,
    
    [Parameter(Mandatory=$false)]
    [string]$Senha
)

$CONTAINER_NAME = "hospedagem_ftp"
$SITES_DIR = ".\sites"

function Print-Usage {
    Write-Host "================================================================" -ForegroundColor Blue
    Write-Host "         Gerenciador de Alunos - Hospedagem FTP                " -ForegroundColor Blue
    Write-Host "================================================================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Uso:" -ForegroundColor White
    Write-Host "  .\gerenciar-alunos.ps1 adicionar [usuario] [senha]" -ForegroundColor Green
    Write-Host "  .\gerenciar-alunos.ps1 remover [usuario]" -ForegroundColor Green
    Write-Host "  .\gerenciar-alunos.ps1 listar" -ForegroundColor Green
    Write-Host ""
    Write-Host "Exemplos:" -ForegroundColor White
    Write-Host "  .\gerenciar-alunos.ps1 adicionar joao senha123" -ForegroundColor Yellow
    Write-Host "  .\gerenciar-alunos.ps1 remover joao" -ForegroundColor Yellow
    Write-Host "  .\gerenciar-alunos.ps1 listar" -ForegroundColor Yellow
    Write-Host ""
}

function Test-Container {
    $containerOutput = docker ps --filter "name=$CONTAINER_NAME" --format "{{.Names}}" 2>&1
    $container = $containerOutput | Out-String
    $container = $container.Trim()
    if (-not $container -or $container -ne $CONTAINER_NAME) {
        Write-Host "[ERRO] Container $CONTAINER_NAME nao esta rodando!" -ForegroundColor Red
        Write-Host "   Execute: docker compose up -d" -ForegroundColor Yellow
        exit 1
    }
}

function Add-Aluno {
    param(
        [string]$Usuario,
        [string]$Senha
    )
    
    if ([string]::IsNullOrWhiteSpace($Usuario) -or [string]::IsNullOrWhiteSpace($Senha)) {
        Write-Host "[ERRO] Usuario e senha sao obrigatorios!" -ForegroundColor Red
        Print-Usage
        exit 1
    }
    
    # Validar nome de usuario (apenas letras, numeros e underscore)
    if ($Usuario -notmatch '^[a-zA-Z0-9_]+$') {
        Write-Host "[ERRO] Nome de usuario invalido! Use apenas letras, numeros e underscore." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "[INFO] Adicionando aluno: $Usuario" -ForegroundColor Blue
    
    # Criar pasta do aluno
    $usuarioDir = Join-Path $SITES_DIR $Usuario
    if (-not (Test-Path $usuarioDir)) {
        New-Item -ItemType Directory -Path $usuarioDir -Force | Out-Null
    }
    
    # Criar pagina HTML de exemplo
    $htmlContent = @"
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Site de $Usuario</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
            padding: 20px;
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            text-align: center;
            max-width: 600px;
        }
        h1 {
            color: #667eea;
            margin-bottom: 20px;
        }
        p {
            color: #666;
            line-height: 1.6;
        }
        .emoji {
            font-size: 4em;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="emoji">🚀</div>
        <h1>Bem-vindo ao site de $Usuario!</h1>
        <p>Esta e sua pagina inicial. Voce pode editar este arquivo enviando um novo <strong>index.html</strong> via FTP.</p>
        <p style="margin-top: 20px; color: #999;">Faca upload dos seus arquivos HTML, CSS, JavaScript e imagens para personalizar seu site!</p>
    </div>
</body>
</html>
"@
    
    $htmlPath = Join-Path $usuarioDir "index.html"
    $htmlContent | Out-File -FilePath $htmlPath -Encoding UTF8 -Force
    
    # Adicionar usuario FTP no container
    Write-Host "[INFO] Criando usuario FTP..." -ForegroundColor Blue
    
    # Criar comando para adicionar usuario FTP
    # Usar printf para passar senha duas vezes (confirmacao)
    $senhaEscapada = $Senha.Replace("'", "'\''")
    $senhaCmd = "printf '%s\n%s\n' '$senhaEscapada' '$senhaEscapada' | pure-pw useradd $Usuario -u ftpuser -d /home/ftpusers/$Usuario -m"
    
    # Executar comando no container
    $output = docker exec $CONTAINER_NAME sh -c $senhaCmd 2>&1
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -ne 0) {
        $outputStr = $output | Out-String
        if ($outputStr -notmatch "already exists") {
            Write-Host "[AVISO] Erro ao criar usuario: $outputStr" -ForegroundColor Yellow
        }
    }
    
    # Atualizar o banco de dados
    docker exec $CONTAINER_NAME sh -c "pure-pw mkdb" 2>&1 | Out-Null
    
    Write-Host "[OK] Aluno '$Usuario' adicionado com sucesso!" -ForegroundColor Green
    Write-Host "   URL: http://localhost:8084/$Usuario/" -ForegroundColor Green
    Write-Host "   FTP: localhost:21 (usuario: $Usuario, senha: $Senha)" -ForegroundColor Green
}

function Remove-Aluno {
    param([string]$Usuario)
    
    if ([string]::IsNullOrWhiteSpace($Usuario)) {
        Write-Host "[ERRO] Usuario e obrigatorio!" -ForegroundColor Red
        Print-Usage
        exit 1
    }
    
    Write-Host "[AVISO] Removendo aluno: $Usuario" -ForegroundColor Yellow
    
    # Remover usuario FTP
    docker exec $CONTAINER_NAME sh -c "pure-pw userdel $Usuario -m" 2>&1 | Out-Null
    docker exec $CONTAINER_NAME sh -c "pure-pw mkdb" 2>&1 | Out-Null
    
    # Fazer backup antes de remover
    $usuarioDir = Join-Path $SITES_DIR $Usuario
    if (Test-Path $usuarioDir) {
        $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $backupDir = ".\backups\${timestamp}_$Usuario"
        if (-not (Test-Path ".\backups")) {
            New-Item -ItemType Directory -Path ".\backups" -Force | Out-Null
        }
        Move-Item -Path $usuarioDir -Destination $backupDir -Force
        Write-Host "[OK] Backup salvo em: $backupDir" -ForegroundColor Green
    }
    
    Write-Host "[OK] Aluno '$Usuario' removido com sucesso!" -ForegroundColor Green
}

function List-Alunos {
    Write-Host "================================================================" -ForegroundColor Blue
    Write-Host "                    Lista de Alunos                            " -ForegroundColor Blue
    Write-Host "================================================================" -ForegroundColor Blue
    Write-Host ""
    
    if (Test-Path $SITES_DIR) {
        $diretorios = Get-ChildItem -Path $SITES_DIR -Directory -ErrorAction SilentlyContinue
        if ($diretorios) {
            foreach ($dir in $diretorios) {
                $usuario = $dir.Name
                Write-Host "[*] $usuario" -ForegroundColor Green
                Write-Host "   Pasta: $($dir.FullName)"
                Write-Host "   URL: http://localhost:8084/$usuario/"
                Write-Host ""
            }
        } else {
            Write-Host "Nenhum aluno cadastrado ainda." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Nenhum aluno cadastrado ainda." -ForegroundColor Yellow
    }
    
    Write-Host "Usuarios FTP no container:" -ForegroundColor Blue
    try {
        $ftpUsersOutput = docker exec $CONTAINER_NAME sh -c "pure-pw list" 2>&1
        $ftpUsers = $ftpUsersOutput | Out-String
        $ftpUsers = $ftpUsers.Trim()
        if ($ftpUsers -and $ftpUsers -ne "") {
            Write-Host $ftpUsers
        } else {
            Write-Host "Container nao esta rodando" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Container nao esta rodando" -ForegroundColor Yellow
    }
}

# Main
switch ($Acao) {
    "adicionar" {
        Test-Container
        if ([string]::IsNullOrWhiteSpace($Usuario) -or [string]::IsNullOrWhiteSpace($Senha)) {
            Write-Host "[ERRO] Usuario e senha sao obrigatorios para adicionar!" -ForegroundColor Red
            Print-Usage
            exit 1
        }
        Add-Aluno -Usuario $Usuario -Senha $Senha
    }
    "remover" {
        Test-Container
        if ([string]::IsNullOrWhiteSpace($Usuario)) {
            Write-Host "[ERRO] Usuario e obrigatorio para remover!" -ForegroundColor Red
            Print-Usage
            exit 1
        }
        Remove-Aluno -Usuario $Usuario
    }
    "listar" {
        List-Alunos
    }
    default {
        Print-Usage
        exit 1
    }
}
