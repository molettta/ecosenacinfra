# 🪟 Guia Rápido - Windows

## 📋 Pré-requisitos

1. **Docker Desktop** instalado e rodando
   - Baixe em: https://www.docker.com/products/docker-desktop/
   - Certifique-se de que o Docker Desktop está iniciado (ícone na bandeja do sistema)

## 🚀 Como Usar

### 1. Iniciar os serviços Docker

```powershell
docker compose up -d
```

Isso vai iniciar:
- **Servidor FTP** na porta 21
- **Servidor Web** na porta 8084

### 2. Adicionar um aluno

```powershell
.\gerenciar-alunos.ps1 adicionar joao senha123
```

Isso vai:
- Criar uma pasta para o aluno em `.\sites\joao\`
- Criar um usuário FTP com as credenciais fornecidas
- Gerar uma página HTML de exemplo
- Configurar as permissões necessárias

### 3. Acessar o site do aluno

- **Web**: http://localhost:8084/joao/
- **Página inicial**: http://localhost:8084/

### 4. Conectar via FTP (Cliente)

**Configuração do FileZilla (ou outro cliente FTP):**
- **Host**: localhost
- **Porta**: 21
- **Usuário**: joao
- **Senha**: senha123
- **Modo**: Passivo

### 5. Listar todos os alunos

```powershell
.\gerenciar-alunos.ps1 listar
```

### 6. Remover um aluno

```powershell
.\gerenciar-alunos.ps1 remover joao
```

⚠️ Um backup será criado em `.\backups\` antes da remoção!

## 🔧 Comandos Úteis

### Ver logs do FTP
```powershell
docker compose logs -f ftpd_server
```

### Ver logs do Web Server
```powershell
docker compose logs -f webserver
```

### Parar os serviços
```powershell
docker compose down
```

### Reiniciar os serviços
```powershell
docker compose restart
```

## ⚠️ Notas Importantes para Windows

1. **Docker Desktop deve estar rodando** antes de executar os comandos
2. **Use PowerShell** (não CMD) para executar os scripts
3. Se encontrar erros de permissão, execute PowerShell como Administrador
4. Os scripts `.sh` são para Linux/Mac. Use `.ps1` no Windows

## 🔒 Segurança

- Cada aluno só tem acesso à sua própria pasta
- Senhas são criptografadas
- FTP usa modo passivo para melhor compatibilidade
- Backups automáticos ao remover alunos

## ⚡ Troubleshooting

### Problema: "Docker não está rodando"
1. Abra o Docker Desktop
2. Aguarde até o ícone ficar verde na bandeja do sistema
3. Tente novamente

### Problema: "Container não está rodando"
```powershell
docker compose up -d
```

### Problema: "Permission denied" no script PowerShell
1. Execute PowerShell como Administrador
2. Ou execute: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

### Problema: Não consigo conectar via FTP
1. Verifique se o container está rodando: `docker ps`
2. Verifique as portas: `netstat -ano | findstr :21`
3. Certifique-se de usar o modo **Passivo** no cliente FTP

### Problema: Site não aparece
1. Verifique se o arquivo `index.html` existe na pasta do aluno
2. Veja os logs: `docker compose logs webserver`

