# Wiki ADSPG - Plataforma de Conhecimento Colaborativo

## 📚 O que é?

O **Wiki ADSPG** é uma plataforma colaborativa de documentação e compartilhamento de conhecimento, desenvolvida para facilitar o acesso a materiais didáticos, tutoriais, guias e documentação técnica para alunos e professores.

## 🎯 Objetivo

Centralizar todo o conhecimento gerado nas disciplinas, projetos e atividades acadêmicas em um único lugar organizado e acessível, permitindo que:

- **Professores** publiquem materiais didáticos, tutoriais e documentação de disciplinas
- **Alunos** acessem conteúdos, guias práticos e documentação técnica
- **Todos** possam colaborar na construção do conhecimento coletivo

## 🌐 Acesso

- **URL Principal:** https://wiki.adspg.tec.br
- **URL Alternativa (HTTP):** http://wiki.adspg.tec.br

## 👥 Para quem?

### Professores
- Criar e organizar materiais das disciplinas
- Publicar tutoriais e guias passo a passo
- Documentar projetos e experimentos
- Compartilhar boas práticas e exemplos de código
- Manter documentação técnica atualizada

### Alunos
- Acessar materiais das disciplinas
- Consultar tutoriais e guias práticos
- Aprender através de exemplos documentados
- Contribuir com documentação de projetos
- Compartilhar conhecimentos adquiridos

## 📖 Como usar?

### 1. **Acessar o Wiki**
   - Abra https://wiki.adspg.tec.br no navegador
   - Faça login com suas credenciais institucionais

### 2. **Navegar pelo Conteúdo**
   - Use o menu lateral para explorar as categorias
   - Utilize a busca para encontrar tópicos específicos
   - Navegue pelas tags para descobrir conteúdos relacionados

### 3. **Criar Conteúdo (Professores)**
   - Clique no botão "Nova Página"
   - Escolha um título descritivo
   - Selecione a categoria apropriada
   - Use o editor Markdown para formatar o conteúdo
   - Adicione tags relevantes
   - Publique ou salve como rascunho

### 4. **Editar Conteúdo**
   - Clique no botão "Editar" na página desejada
   - Faça as alterações necessárias
   - Adicione uma descrição da mudança
   - Salve as alterações

## 📂 Estrutura de Organização Sugerida

```
📚 Wiki ADSPG
├── 🎓 Disciplinas
│   ├── Programação
│   ├── Redes
│   ├── Banco de Dados
│   └── ...
├── 🛠️ Tutoriais
│   ├── Docker
│   ├── Git/GitHub
│   ├── Linux
│   └── ...
├── 💻 Projetos
│   ├── IoT
│   ├── Automação
│   ├── Web Development
│   └── ...
├── 📋 Documentação Técnica
│   ├── Servidores
│   ├── APIs
│   ├── Infraestrutura
│   └── ...
└── 💡 Boas Práticas
    ├── Código
    ├── Segurança
    └── Colaboração
```

## ✍️ Dicas para Criar Bom Conteúdo

### 1. **Títulos Claros**
   - Use títulos descritivos e objetivos
   - Exemplo: "Como Configurar Docker no Ubuntu" ao invés de "Docker"

### 2. **Estrutura Organizada**
   - Use hierarquia de títulos (H1, H2, H3)
   - Divida conteúdo longo em seções
   - Use listas e tabelas quando apropriado

### 3. **Exemplos Práticos**
   - Inclua exemplos de código
   - Adicione capturas de tela quando necessário
   - Forneça casos de uso reais

### 4. **Código e Comandos**
   ```bash
   # Use blocos de código com syntax highlighting
   docker ps -a
   ```

### 5. **Links e Referências**
   - Referencie outras páginas do wiki
   - Adicione links externos para documentação oficial
   - Cite fontes quando aplicável

### 6. **Tags Relevantes**
   - Use tags para facilitar a busca
   - Seja consistente com as tags existentes
   - Exemplo: `docker`, `tutorial`, `linux`, `iniciante`

## 🔍 Recursos do Wiki

### Markdown Avançado
- Tabelas
- Listas de tarefas
- Diagramas (Mermaid)
- Emojis
- Blocos de código com syntax highlighting
- Notas e avisos
- Ícones

### Versionamento
- Todo conteúdo é versionado automaticamente
- Histórico completo de mudanças
- Possibilidade de reverter alterações
- Comparação entre versões

### Busca Inteligente
- Busca em tempo real
- Busca por conteúdo, título e tags
- Filtros avançados

### Colaboração
- Múltiplos editores simultâneos
- Comentários em páginas
- Sistema de permissões por grupo

## 🎨 Exemplos de Uso

### Tutorial Técnico
```markdown
# Como Instalar Node.js no Ubuntu

## Pré-requisitos
- Ubuntu 20.04 ou superior
- Acesso sudo

## Passo 1: Atualizar o sistema
\`\`\`bash
sudo apt update && sudo apt upgrade -y
\`\`\`

## Passo 2: Instalar Node.js
\`\`\`bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
\`\`\`

## Passo 3: Verificar instalação
\`\`\`bash
node --version
npm --version
\`\`\`
```

### Documentação de Projeto
```markdown
# Sistema de Hospedagem de Alunos

## Descrição
Sistema para gerenciar hospedagem de sites estáticos dos alunos.

## Componentes
- Nginx (Servidor Web)
- Pure-FTPd (Servidor FTP)
- Docker Compose (Orquestração)

## Portas
- 8084: Servidor Web
- 21: FTP
- 30000-30009: FTP Passivo

## Acesso
URL: https://static.adspg.tec.br
```

### Material de Aula
```markdown
# Aula 05 - Introdução ao Docker

## Objetivos
- Entender conceitos de containers
- Criar primeiro container
- Usar Docker Compose

## Conteúdo
1. O que são containers?
2. Diferença entre VM e Container
3. Comandos básicos do Docker
4. Exercício prático

## Recursos
- [Slides da aula](link)
- [Exercícios](link)
- [Vídeo da aula](link)
```

## 🔐 Segurança e Boas Práticas

1. **Não compartilhe senhas** no wiki
2. **Não publique informações sensíveis** (IPs internos, credenciais, etc.)
3. **Revise antes de publicar** conteúdo público
4. **Use rascunhos** para conteúdo em desenvolvimento
5. **Mantenha backup** de conteúdo importante fora do wiki

## 🆘 Suporte

### Problemas Técnicos
- Verifique a documentação do Wiki.js: https://docs.requarks.io
- Entre em contato com o administrador do sistema

### Dúvidas sobre Conteúdo
- Use os comentários na página específica
- Entre em contato com o professor responsável

## 🛠️ Tecnologia

O Wiki ADSPG utiliza:
- **Wiki.js** - Motor do wiki (https://js.wiki)
- **PostgreSQL** - Banco de dados
- **Docker** - Containerização
- **Caddy** - Proxy reverso com SSL automático

## 📊 Estatísticas e Backup

- ✅ Backup automático do banco de dados
- ✅ Versionamento completo de conteúdo
- ✅ Alta disponibilidade
- ✅ SSL/HTTPS automático via Cloudflare

## 🚀 Comece Agora!

1. Acesse https://wiki.adspg.tec.br
2. Faça login com suas credenciais
3. Explore o conteúdo existente
4. Contribua com seu conhecimento!

---

**Última atualização:** Outubro 2025  
**Versão:** 1.0  
**Mantido por:** Equipe ADSPG

