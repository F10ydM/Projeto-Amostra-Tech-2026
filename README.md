<div align="center">

# 🏛️ UNIUBE Via Centro · GPS Interno 3D

### Trabalho Integrador · Amostra Tech 2026 · Estande E2

**[🌐 Demo ao vivo](https://projeto-amostra-tech-2026-nrqt.vercel.app)** ·
**[📺 Vídeo de apresentação](#)** ·
**[📋 Kanban do projeto](https://projeto-amostra-tech-2026-nrqt.vercel.app/#kanban)**

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/F10ydM/Projeto-Amostra-Tech-2026)
[![Three.js](https://img.shields.io/badge/Three.js-r160-000000?logo=three.js&logoColor=white)](https://threejs.org)
[![Supabase](https://img.shields.io/badge/Supabase-Postgres-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Vercel](https://img.shields.io/badge/Vercel-Hobby-000000?logo=vercel&logoColor=white)](https://vercel.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

---

## 📌 Visão geral

Sistema 3D navegável do **1º pavimento do campus UNIUBE Via Centro** (Av. João Pinheiro, Uberlândia/MG) que resolve o problema de orientação espacial de alunos novatos, visitantes da Amostra Tech, professores em trânsito e **pessoas com mobilidade reduzida**.

O usuário escaneia um **QR-Code físico** instalado em um checkpoint estratégico do prédio, escolhe o destino numa lista e recebe uma **rota navegável em primeira pessoa**, calculada por **Dijkstra** sobre um grafo que diferencia caminhos padrão (escada rolante) e **rotas acessíveis** (rampa em U / elevador).

### Por que isso importa

- 🏛️ **Topologia confusa** do prédio: escada rolante dupla, rampa em U, mezaninos, dois pavimentos e um galpão de engenharias anexo (pé-direito de 6 m).
- ♿ **Fluxos PCD invisíveis** na sinalização estática atual.
- 🆕 Alunos novatos chegam atrasados às aulas por não conhecer o layout.
- 🚨 Ponto de encontro de emergência pouco claro (recurso de alarme integrado).

---

## 🏗️ Arquitetura

```
┌──────────────────────────────────────────────────────────────┐
│                        CAMPUS FÍSICO                          │
│                                                                │
│   QR Code 1 ──┐                                ┌── QR Code N   │
│   (Saguão)    │                                │   (Lab 116)   │
│               │                                │                │
└───────────────┼────────────────────────────────┼────────────────┘
                │  📱 scan via câmera             │
                ▼                                ▼
        ┌────────────────────────────────────────────┐
        │  FRONTEND · Vercel (CDN global · HTTPS)    │
        │  ─────────────────────────────────────────  │
        │  • index.html (SPA single-file)             │
        │  • Three.js r160 (WebGL · cena 3D)          │
        │  • Dijkstra client-side · 27 nós · 13 QRs   │
        │  • UI responsiva (mobile-first)             │
        └────────────────────┬───────────────────────┘
                             │ REST + Realtime
                             ▼
        ┌────────────────────────────────────────────┐
        │  BACKEND · Supabase (Postgres + Auth)       │
        │  ─────────────────────────────────────────  │
        │  Tables: rooms · checkpoints · edges · logs │
        │  RLS: leitura pública / escrita autenticada │
        └────────────────────┬───────────────────────┘
                             │
                             ▼
        ┌────────────────────────────────────────────┐
        │  IA · Anthropic Claude API                  │
        │  ─────────────────────────────────────────  │
        │  Edge Function (/api/chatbot)               │
        │  Modo Cicerone (histórico-tour)             │
        │  Modo Acessibilidade (PCD)                  │
        └────────────────────────────────────────────┘
```

---

## 🧰 Stack tecnológica

| Camada | Tecnologia | Propósito |
|---|---|---|
| **Modelagem 2D** | AutoCAD 2024 | Vetorização da planta do 1º pavimento |
| **Modelagem 3D** | 3ds Max 2024 | Extrude, Boolean, export glTF/FBX |
| **Render 3D web** | Three.js r160 | Cena WebGL, materiais, luzes, animações |
| **Pathfinding** | Dijkstra (JS puro) | Grafo de 27 nós · diferencia rota acessível |
| **Frontend** | HTML5 + CSS3 + ES2022 | SPA single-file (sem build step) |
| **Backend** | Supabase Postgres | Tabelas + REST + Realtime |
| **AR mobile** | Unity 2022 LTS + ARCore/ARKit | App nativo com ZXing (QR scan) |
| **IA** | Anthropic Claude API | Chatbot Cicerone + Acessibilidade |
| **Hosting** | Vercel (Hobby) | CDN global · HTTPS · CI/CD |
| **CI/CD** | GitHub Actions | Deploy automático em `push origin main` |
| **Versionamento** | Git + Conventional Commits | `feat:`, `fix:`, `docs:`, `refactor:`… |

---

## 📂 Estrutura do repositório

```
Projeto-Amostra-Tech-2026/
├── index.html                # Frontend completo (SPA single-file · ~3.800 linhas)
├── vercel.json               # Configuração Vercel + cabeçalhos de segurança
├── .env.example              # Template de variáveis de ambiente
├── README.md                 # Este arquivo
├── LICENSE                   # MIT
├── api/
│   └── chatbot.js            # Edge function · proxy para Anthropic API
├── supabase/
│   ├── schema.sql            # DDL das tabelas
│   ├── seed.sql              # Dados iniciais (salas, QRs, arestas)
│   └── policies.sql          # Row Level Security (RLS)
├── unity/                    # App AR mobile (Unity 2022 LTS)
│   ├── Assets/
│   ├── ProjectSettings/
│   └── Packages/
├── docs/
│   ├── topologia.md          # Mapeamento in loco · 81 fotos
│   ├── disciplinas.md        # Rastreabilidade com 11 disciplinas
│   └── api.md                # Contrato da API by_qr
└── .github/
    └── workflows/
        └── deploy.yml        # GitHub Actions · deploy Vercel
```

---

## 🎓 Disciplinas integradas (11)

| Disciplina | Evidência no código |
|---|---|
| **Programação Web** | `index.html` com JS ES2022 modular, sem build |
| **Computação Gráfica** | Cena Three.js: `Scene`, `PerspectiveCamera`, `WebGLRenderer`, materiais Lambert, luzes hemi + diretional |
| **Estrutura de Dados e Algoritmos** | Dijkstra com matriz de adjacência sobre grafo de 27 nós (rotas padrão vs acessíveis) |
| **Banco de Dados** | Tabelas Postgres no Supabase: `rooms`, `checkpoints`, `edges`, `nav_logs` |
| **Inteligência Artificial** | API Anthropic Claude no chatbot (modos Cicerone / Acessibilidade) |
| **Engenharia de Software** | Arquitetura modular (T · Nav · Tour · Demo · GPS · UI · Kanban), commits semânticos |
| **Interface Humano-Computador (IHC)** | Mobile-first, alto contraste, modo PCD, redução de movimento, atalhos de teclado |
| **Redes de Computadores** | Vercel CDN global, HTTPS/TLS 1.3, HTTP/2, Supabase Realtime via WebSocket |
| **Gestão de Projetos** (nota 8.5) | Sprints Scrum + Kanban funcional dentro do próprio site |
| **Segurança e Auditoria** (2026/1) | `vercel.json` com CSP, HSTS, X-Frame-Options, Permissions-Policy, RLS no Supabase |
| **Análise e Projeto de Sistemas** | Requisitos funcionais (Kanban, pathfinding, IA) + não-funcionais (segurança, performance) |

---

## 🗺️ Topologia mapeada

Levantamento **in loco** com 81 fotografias do campus, traduzidas em coordenadas métricas:

- **Origem (0,0,0)** = canto sudoeste do prédio principal
- **Prédio principal**: 50 (X) × 36 (Z) × 3 (Y) metros
- **Galpão das Engenharias**: 22 × 28 × 6 metros · offset (X=50, Z=4)
- **27 nós** no grafo · **13 QR-Codes físicos**

### Pontos icônicos modelados

- Marquise + fachada UNIUBE iluminada (Av. João Pinheiro)
- Saguão com forro de pingentes de cristal emissivo + faixas LED no piso
- Escada rolante dupla com banner "Gaudium Hall · 5 ambientes diferentes"
- Rampa em U (acessível) com guarda-corpos de vidro verde-água
- Parede do Mandela (azul cobalto + frase em vinil)
- Parede amarela "laboratórios" + Parede do Gorila ("CURSO TÉCNICO")
- Biblioteca 163 (estantes + mesas redondas + balcão)
- Galpão das Engenharias com treliças metálicas e sublabs 116-A/B/C/D
- Saída secundária com escadaria + 2 pontos de ônibus + cruz cristã (universidade metodista)

---

## ▶️ Como executar localmente

Como o frontend é um único `index.html` estático **sem build step**, basta servir o diretório com qualquer servidor HTTP local. **Evite abrir via `file://`** — quebra CORS dos CDNs.

```bash
# 1. Clonar
git clone https://github.com/F10ydM/Projeto-Amostra-Tech-2026.git
cd Projeto-Amostra-Tech-2026

# 2. Configurar variáveis de ambiente
cp .env.example .env.local
# Editar .env.local: SUPABASE_URL, SUPABASE_ANON_KEY, ANTHROPIC_API_KEY

# 3. Servir localmente (escolha um):
python3 -m http.server 8000          # Python (mais simples)
npx serve .                          # Node
php -S localhost:8000                # PHP

# 4. Abrir no navegador
# http://localhost:8000
```

### Atalhos de teclado

| Tecla | Ação |
|---|---|
| `1` `2` `3` `4` | Vistas: Iso · Topo · Entrada · Galpão |
| `E` | Acionar elevador |
| `L` | Mostrar/ocultar labels das salas |
| `Q` | Destacar QR-Codes |
| `C` | Mostrar/ocultar teto |
| `N` | Iniciar navegação (após cálculo de rota) |
| `H` | Abrir menu lateral |
| `K` | Abrir Kanban |
| `⇧A` | Alarme de incêndio |
| `Esc` | Encerrar fluxo atual |
| `Espaço` | Pausar navegação |

---

## 🗄️ Modelagem de dados (Supabase)

### Tabelas principais

```sql
-- rooms: salas e ambientes
CREATE TABLE rooms (
  id           text PRIMARY KEY,
  name         text NOT NULL,
  num          text,
  category     text NOT NULL,            -- 'admin' | 'aula' | 'lab_eng' | 'biblio' | 'wc' | 'apoio' | 'elev' | 'circ'
  floor        smallint NOT NULL DEFAULT 1,
  x            real NOT NULL,            -- canto SO em metros
  z            real NOT NULL,
  w            real NOT NULL,            -- largura X
  d            real NOT NULL,            -- profundidade Z
  is_external  boolean DEFAULT false,
  created_at   timestamptz DEFAULT now()
);

-- checkpoints: QR-Codes físicos
CREATE TABLE checkpoints (
  id           text PRIMARY KEY,         -- 'qr_saguao', 'qr_biblio'...
  name         text NOT NULL,
  room_id      text REFERENCES rooms(id),
  x            real NOT NULL,
  z            real NOT NULL,
  y            real NOT NULL DEFAULT 1.5,
  floor        smallint NOT NULL DEFAULT 1,
  qr_url       text UNIQUE,              -- URL embarcada no QR
  active       boolean DEFAULT true
);

-- edges: arestas do grafo de pathfinding
CREATE TABLE edges (
  id           bigserial PRIMARY KEY,
  from_node    text NOT NULL,
  to_node      text NOT NULL,
  distance     real NOT NULL,
  accessible   boolean NOT NULL DEFAULT true,
  is_vertical  boolean NOT NULL DEFAULT false  -- escada rolante / elevador
);

-- nav_logs: telemetria anônima de uso (analytics)
CREATE TABLE nav_logs (
  id           bigserial PRIMARY KEY,
  from_qr      text,
  to_room      text,
  accessible   boolean,
  distance     real,
  duration_ms  integer,
  device_type  text,                     -- 'mobile' | 'desktop'
  ts           timestamptz DEFAULT now()
);
```

### Row Level Security (RLS)

```sql
ALTER TABLE rooms        ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkpoints  ENABLE ROW LEVEL SECURITY;
ALTER TABLE edges        ENABLE ROW LEVEL SECURITY;
ALTER TABLE nav_logs     ENABLE ROW LEVEL SECURITY;

-- Leitura pública (não exige login)
CREATE POLICY "public_read_rooms"       ON rooms       FOR SELECT USING (true);
CREATE POLICY "public_read_checkpoints" ON checkpoints FOR SELECT USING (active = true);
CREATE POLICY "public_read_edges"       ON edges       FOR SELECT USING (true);

-- Insert público em logs (sem identificação)
CREATE POLICY "public_insert_logs"      ON nav_logs    FOR INSERT WITH CHECK (true);

-- Escrita só com service_role (admin)
```

---

## 🚀 Deploy

CI/CD configurado via **GitHub Actions + Vercel**. Todo `git push origin main` dispara o workflow em `.github/workflows/deploy.yml`, que autentica na Vercel via secrets (`VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`) e publica em produção (`--prod`) em ~30 segundos.

### Cabeçalhos de segurança (`vercel.json`)

```json
{
  "headers": [{
    "source": "/(.*)",
    "headers": [
      { "key": "Strict-Transport-Security", "value": "max-age=63072000; includeSubDomains; preload" },
      { "key": "X-Content-Type-Options",    "value": "nosniff" },
      { "key": "X-Frame-Options",           "value": "SAMEORIGIN" },
      { "key": "Referrer-Policy",           "value": "strict-origin-when-cross-origin" },
      { "key": "Permissions-Policy",        "value": "camera=(self), geolocation=(self), microphone=()" },
      { "key": "Content-Security-Policy",   "value": "default-src 'self'; script-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com https://cdn.jsdelivr.net; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; connect-src 'self' https://*.supabase.co https://api.anthropic.com; img-src 'self' data: blob:" }
    ]
  }]
}
```

---

## 📐 Convenção de commits

Adotamos **Conventional Commits** alinhados a sprints Scrum (Gestão de Projetos · nota 8.5):

| Prefixo | Uso |
|---|---|
| `feat:` | Nova funcionalidade |
| `fix:` | Correção de bug |
| `docs:` | Documentação |
| `style:` | Formatação/CSS (sem mudar lógica) |
| `refactor:` | Reestruturação sem alterar comportamento |
| `perf:` | Otimização de performance |
| `deploy:` | Ajustes de infraestrutura |
| `security:` | Hardening, headers, validações |

---

## 👥 Equipe

| Papel | Nome | LinkedIn | GitHub |
|---|---|---|---|
| 👨‍💻 Desenvolvedor · Autor | **Arthur Moreira Martins** | [@arthur-martins](https://www.linkedin.com/in/arthur-martins-677a193a4) | [@F10ydM](https://github.com/F10ydM) |
| 👩‍💻 Desenvolvedora · Co-autora | **Maria Eduarda** | [@maria-eduarda](https://www.linkedin.com/in/maria-eduarda-a3a9142a9) | [@Mio-exe](https://github.com/Mio-exe) |

### 🎓 Professores Orientadores

**Camilo · Renato · Romualdo · Maxwell · Kênia**

---

## 🗺️ Roadmap

- [x] Modelagem 3D do 1º pavimento (50×36m + galpão 22×28×6m)
- [x] Pathfinding Dijkstra com modo acessível
- [x] 13 QR-Codes em checkpoints estratégicos
- [x] Navegação 1ª pessoa com HUD + minimap 2D
- [x] Tour guiado + Demo auto-executável
- [x] Kanban funcional com Problema/Solução
- [x] Deploy contínuo na Vercel
- [ ] Schema Supabase + RLS + seed de dados
- [ ] Edge Function `/api/chatbot` (Claude API)
- [ ] 2º pavimento (Gaudium Hall + Cantina + Labs Info)
- [ ] App AR mobile (Unity + ARCore/ARKit)
- [ ] Testes de usabilidade com 10 alunos + 2 PCDs

---

## 📚 Referências (ABNT NBR 6023:2018)

ANTHROPIC. **Claude API documentation**. San Francisco, 2026. Disponível em: https://docs.claude.com. Acesso em: 27 maio 2026.

CORMEN, T. H. et al. **Algoritmos: teoria e prática**. 3. ed. Rio de Janeiro: Elsevier, 2012.

DIJKSTRA, E. W. A note on two problems in connexion with graphs. **Numerische Mathematik**, v. 1, p. 269–271, 1959.

ELMASRI, R.; NAVATHE, S. B. **Sistemas de banco de dados**. 7. ed. São Paulo: Pearson, 2018.

GITHUB. **GitHub Actions documentation**. San Francisco, 2026. Disponível em: https://docs.github.com/actions.

MOZILLA. **MDN Web Docs — Content Security Policy (CSP)**. Mountain View, 2026.

PRESSMAN, R. S.; MAXIM, B. R. **Engenharia de software: uma abordagem profissional**. 8. ed. Porto Alegre: AMGH, 2016.

SCHWABER, K.; SUTHERLAND, J. **The Scrum Guide**. 2020. Disponível em: https://scrumguides.org.

SOMMERVILLE, I. **Engenharia de software**. 10. ed. São Paulo: Pearson, 2019.

SUPABASE. **Supabase documentation**. 2026. Disponível em: https://supabase.com/docs.

TANENBAUM, A. S.; WETHERALL, D. **Redes de computadores**. 5. ed. São Paulo: Pearson, 2011.

THREE.JS. **Three.js documentation — r160**. 2026. Disponível em: https://threejs.org/docs.

VERCEL. **Vercel documentation — Headers and rewrites**. 2026. Disponível em: https://vercel.com/docs.

W3C. **WCAG 2.2 — Web Content Accessibility Guidelines**. 2023. Disponível em: https://www.w3.org/TR/WCAG22.

---

## 📄 Licença

Este projeto está sob a [Licença MIT](LICENSE).

---

<div align="center">

**© 2026 Arthur Moreira Martins · Análise e Desenvolvimento de Sistemas · UNIUBE**

Trabalho Integrador · Amostra Tech 2026 · Estande E2

*Universidade de Uberaba · Mantenedora: Igreja Metodista*

</div>
