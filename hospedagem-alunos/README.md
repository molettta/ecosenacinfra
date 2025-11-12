# 🌐 Hospedagem de Alunos - FTP + Web Server

Sistema completo de hospedagem web com FTP para alunos enviarem seus sites.

## 📋 O que este sistema oferece

- **Servidor FTP** (porta 21) - Para alunos enviarem arquivos
- **Servidor Web** (porta 8080) - Para visualizar os sites
- **Gerenciamento fácil** - Script para adicionar/remover alunos
- **Isolamento** - Cada aluno tem sua própria pasta
- **Interface bonita** - Página inicial com lista de alunos

## 🚀 Como Usar

### 1. Iniciar os serviços

```bash
cd ~/ecosenacinfra/hospedagem-alunos
docker compose up -d
```

### 2. Adicionar um aluno

```bash
./gerenciar-alunos.sh adicionar joao senha123
```

Isso vai:
- Criar uma pasta para o aluno em `./sites/joao/`
- Criar um usuário FTP com as credenciais fornecidas
- Gerar uma página HTML de exemplo
- Configurar as permissões necessárias

### 3. Acessar o site do aluno

- **Web**: http://localhost:8084/joao/
- **Página inicial**: http://localhost:8084/

### 4. Conectar via FTP (Cliente)

**Configuração do FileZilla (ou outro cliente FTP):**
- **Host**: localhost (ou IP do servidor)
- **Porta**: 21
- **Usuário**: joao
- **Senha**: senha123
- **Modo**: Passivo

### 5. Listar todos os alunos

```bash
./gerenciar-alunos.sh listar
```

### 6. Remover um aluno

```bash
./gerenciar-alunos.sh remover joao
```

⚠️ Um backup será criado em `./backups/` antes da remoção!

## 📁 Estrutura de Diretórios

```
~/ecosenacinfra/hospedagem-alunos/
├── docker compose.yml          # Configuração dos containers
├── gerenciar-alunos.sh         # Script de gerenciamento
├── nginx/
│   ├── default.conf            # Configuração do Nginx
│   └── index.html              # Página inicial
├── sites/                      # Pasta dos alunos
│   ├── joao/
│   │   └── index.html
│   ├── maria/
│   │   └── index.html
│   └── ...
├── pure-ftpd/                  # Dados do FTP
└── backups/                    # Backups de sites removidos
```

## 🔧 Comandos Úteis

### Ver logs do FTP
```bash
docker compose logs -f ftpd_server
```

### Ver logs do Web Server
```bash
docker compose logs -f webserver
```

### Parar os serviços
```bash
docker compose down
```

### Reiniciar os serviços
```bash
docker compose restart
```

## 🌍 Configuração para Acesso Externo

Se você quiser que os alunos acessem de fora da rede local:

1. Edite o `docker compose.yml` e altere:
```yaml
PUBLICHOST: "SEU_IP_PUBLICO"
```

2. Configure o firewall para liberar as portas:
```bash
sudo ufw allow 21/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 30000:30009/tcp
```

3. Configure o port forwarding no seu roteador (se necessário):
   - Porta 21 (FTP)
   - Porta 8080 (Web)
   - Portas 30000-30009 (FTP Passivo)

## 📝 Instruções para os Alunos

### Como enviar arquivos:

1. Baixe o **FileZilla** (https://filezilla-project.org/)
2. Configure a conexão:
   - Host: `IP_DO_SERVIDOR`
   - Porta: `21`
   - Usuário: `seu_usuario`
   - Senha: `sua_senha`
3. Arraste seus arquivos para o servidor
4. Acesse: `http://IP_DO_SERVIDOR:8084/seu_usuario/`

### Estrutura recomendada dos arquivos:

```
/
├── index.html          # Página principal (obrigatório)
├── style.css           # Estilos
├── script.js           # JavaScript
├── imagens/
│   ├── logo.png
│   └── banner.jpg
└── ...
```

## 🔒 Segurança

- Cada aluno só tem acesso à sua própria pasta
- Senhas são criptografadas
- FTP usa modo passivo para melhor compatibilidade
- Backups automáticos ao remover alunos

## ⚡ Troubleshooting

### Problema: "Container não está rodando"
```bash
docker compose up -d
```

### Problema: "Permission denied"
```bash
chmod +x gerenciar-alunos.sh
```

### Problema: Não consigo conectar via FTP
1. Verifique se o container está rodando: `docker ps`
2. Verifique as portas: `netstat -tulpn | grep 21`
3. Teste localmente primeiro: `ftp localhost 21`

### Problema: Site não aparece
1. Verifique se o arquivo `index.html` existe na pasta do aluno
2. Verifique as permissões: `ls -la sites/`
3. Veja os logs: `docker compose logs webserver`

## 📊 Monitoramento

### Ver alunos online no FTP
```bash
docker exec hospedagem_ftp sh -c "pure-ftpwho"
```

### Ver uso de disco por aluno
```bash
du -sh sites/*
```

## 🎓 Exemplos de Uso

### Adicionar vários alunos de uma vez
```bash
#!/bin/bash
alunos=("joao:senha1" "maria:senha2" "pedro:senha3")

for aluno in "${alunos[@]}"; do
    IFS=':' read -r usuario senha <<< "$aluno"
    ./gerenciar-alunos.sh adicionar "$usuario" "$senha"
done
```

### Criar relatório de alunos
```bash
./gerenciar-alunos.sh listar > relatorio_alunos.txt
```

## 📞 Suporte

Para problemas ou dúvidas, verifique:
1. Logs dos containers
2. Permissões de arquivos
3. Configuração do firewall

---

**Desenvolvido para facilitar a hospedagem de sites de alunos! 🚀**

