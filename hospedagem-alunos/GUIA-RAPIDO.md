# ⚡ Guia Rápido - Hospedagem de Alunos

## 🚀 Início Rápido (3 passos)

### 1️⃣ Iniciar o sistema
```bash
cd ~/ecosenacinfra/hospedagem-alunos
chmod +x iniciar.sh
./iniciar.sh
```

### 2️⃣ Adicionar alunos
```bash
./gerenciar-alunos.sh adicionar joao senha123
./gerenciar-alunos.sh adicionar maria senha456
./gerenciar-alunos.sh adicionar pedro senha789
```

### 3️⃣ Acessar
- **Página inicial**: http://localhost:8084/
- **Site do João**: http://localhost:8084/joao/
- **Site da Maria**: http://localhost:8084/maria/

---

## 📤 Instruções para os Alunos

### Como enviar seu site via FTP:

#### Opção 1: FileZilla (Recomendado)
1. Baixe: https://filezilla-project.org/
2. Abra o FileZilla
3. Preencha no topo:
   - **Host**: `IP_DO_SERVIDOR` (ex: 192.168.1.100)
   - **Username**: seu_usuario (ex: joao)
   - **Password**: sua_senha
   - **Port**: 21
4. Clique em "Quickconnect"
5. Arraste seus arquivos HTML para a janela da direita

#### Opção 2: Linha de comando
```bash
ftp IP_DO_SERVIDOR
# Digite seu usuário e senha
put index.html
put style.css
bye
```

---

## 📁 Estrutura do Site do Aluno

Os alunos devem criar esta estrutura:

```
Meu Site/
├── index.html          ← Página principal (OBRIGATÓRIO)
├── style.css           ← Estilos CSS
├── script.js           ← JavaScript
├── imagens/
│   ├── logo.png
│   ├── foto.jpg
│   └── banner.gif
└── paginas/
    ├── sobre.html
    └── contato.html
```

### Exemplo de index.html básico:
```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Meu Site</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>Bem-vindo ao meu site!</h1>
    <p>Esta é minha primeira página web.</p>
    <img src="imagens/foto.jpg" alt="Minha foto">
    <script src="script.js"></script>
</body>
</html>
```

---

## 🔧 Comandos Úteis para o Professor

### Gerenciar Alunos
```bash
# Listar todos os alunos
./gerenciar-alunos.sh listar

# Adicionar aluno
./gerenciar-alunos.sh adicionar nome senha

# Remover aluno (cria backup automático)
./gerenciar-alunos.sh remover nome
```

### Gerenciar Sistema
```bash
# Iniciar sistema
./iniciar.sh

# Parar sistema
./parar.sh

# Ver logs do FTP
docker compose logs -f ftpd_server

# Ver logs do Web Server
docker compose logs -f webserver

# Reiniciar sistema
docker compose restart

# Ver status
docker compose ps
```

### Monitoramento
```bash
# Ver quem está conectado no FTP
docker exec hospedagem_ftp sh -c "pure-ftpwho"

# Ver tamanho dos sites
du -sh sites/*

# Ver total de espaço usado
du -sh sites/
```

---

## 🌐 Acesso Externo (Internet)

Para permitir que alunos acessem de casa:

### 1. Descobrir seu IP público
```bash
curl ifconfig.me
```

### 2. Configurar firewall
```bash
sudo ufw allow 21/tcp      # FTP
sudo ufw allow 8080/tcp    # Web
sudo ufw allow 30000:30009/tcp  # FTP Passivo
```

### 3. Editar docker compose.yml
Substitua `localhost` pelo seu IP público:
```yaml
PUBLICHOST: "SEU_IP_PUBLICO"
```

### 4. Configurar roteador
No painel do roteador, configure Port Forwarding:
- Porta Externa 21 → Porta Interna 21 (IP do servidor)
- Porta Externa 8080 → Porta Interna 8080 (IP do servidor)
- Portas 30000-30009 → Portas 30000-30009 (IP do servidor)

### 5. Reiniciar
```bash
docker compose down
docker compose up -d
```

Agora os alunos podem acessar:
- **FTP**: `ftp://SEU_IP_PUBLICO:21`
- **Web**: `http://SEU_IP_PUBLICO:8084/usuario/`

---

## ❓ Problemas Comuns

### "Permission denied" ao executar scripts
```bash
chmod +x iniciar.sh gerenciar-alunos.sh parar.sh
```

### "Container not running"
```bash
docker compose up -d
```

### Aluno não consegue conectar via FTP
1. Verificar se o usuário foi criado: `./gerenciar-alunos.sh listar`
2. Verificar se o container está rodando: `docker ps`
3. Testar localmente: `ftp localhost 21`

### Site não aparece
1. Verificar se existe `index.html` na pasta do aluno
2. Ver logs: `docker compose logs webserver`
3. Verificar permissões: `ls -la sites/`

### "Port already in use"
Algum serviço está usando a porta 21 ou 8080:
```bash
# Ver o que está usando a porta
sudo lsof -i :21
sudo lsof -i :8084

# Parar o serviço ou mudar as portas no docker compose.yml
```

---

## 📊 Estatísticas

### Ver total de alunos
```bash
ls -1 sites/ | wc -l
```

### Ver alunos com mais arquivos
```bash
for dir in sites/*/; do
    echo "$(find "$dir" -type f | wc -l) - $(basename "$dir")"
done | sort -rn
```

### Gerar relatório completo
```bash
echo "=== Relatório de Hospedagem ==="
echo "Data: $(date)"
echo ""
echo "Total de alunos: $(ls -1 sites/ | wc -l)"
echo ""
echo "Espaço usado por aluno:"
du -sh sites/* | sort -h
echo ""
echo "Total: $(du -sh sites/ | cut -f1)"
```

---

## 🎓 Dicas Pedagógicas

### Projeto Sugerido 1: Portfolio Pessoal
- index.html (sobre mim)
- projetos.html (meus trabalhos)
- contato.html (formulário)
- style.css (design responsivo)

### Projeto Sugerido 2: Site de Restaurante
- index.html (página inicial)
- cardapio.html (menu)
- localizacao.html (mapa)
- imagens/ (fotos dos pratos)

### Projeto Sugerido 3: Blog Pessoal
- index.html (últimas postagens)
- post1.html, post2.html
- sobre.html
- style.css (tema personalizado)

---

## 🔒 Segurança

✅ Cada aluno só acessa sua própria pasta  
✅ Senhas são criptografadas  
✅ Backups automáticos ao remover  
✅ Logs de acesso mantidos  
✅ Isolamento entre containers  

---

## 📞 Checklist de Implantação

- [ ] Executar `./iniciar.sh`
- [ ] Adicionar alunos com `./gerenciar-alunos.sh adicionar`
- [ ] Testar acesso web: `http://localhost:8084/`
- [ ] Testar FTP localmente
- [ ] (Opcional) Configurar firewall para acesso externo
- [ ] (Opcional) Configurar port forwarding no roteador
- [ ] Enviar credenciais FTP para os alunos
- [ ] Enviar URL de acesso web para os alunos

---

**Pronto! Seu sistema de hospedagem está configurado! 🎉**

Para dúvidas detalhadas, consulte o `README.md` completo.

