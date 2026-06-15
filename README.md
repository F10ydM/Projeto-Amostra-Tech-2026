<div align="center">

# 🧭 UniMaps · GPS Interno 3D

### Navegação *indoor* tridimensional para o campus Via Centro da UNIUBE

*Escaneie um QR Code, escolha seu destino e siga a rota em 3D — com acessibilidade e funcionamento offline.*

<br>

![Three.js](https://img.shields.io/badge/Three.js-r160-000000?style=for-the-badge&logo=three.js&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-ES2020-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)
![PWA](https://img.shields.io/badge/PWA-Offline_First-5A0FC8?style=for-the-badge&logo=pwa&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Vercel](https://img.shields.io/badge/Vercel-Deploy-000000?style=for-the-badge&logo=vercel&logoColor=white)
![Acessibilidade](https://img.shields.io/badge/WCAG-Acess%C3%ADvel-1f6fe8?style=for-the-badge&logo=accessibility&logoColor=white)

**🌐 [Acessar o aplicativo](https://projeto-amostra-tech-2026-nrqt.vercel.app/)** · 🎓 Trabalho Integrador · Amostra Tech 2026 · ADS

</div>

---

## 📑 Índice

- [✨ O que é o UniMaps](#-o-que-é-o-unimaps)
- [🎬 Como funciona, em 30 segundos](#-como-funciona-em-30-segundos)
- [🧠 A engenharia por trás (a parte importante)](#-a-engenharia-por-trás-a-parte-importante)
  - [1. O mapa é um grafo](#1-o-mapa-é-um-grafo-)
  - [2. A rota é o algoritmo A*](#2-a-rota-é-o-algoritmo-a-)
  - [3. O QR Code é a "localização sem GPS"](#3-o-qr-code-é-a-localização-sem-gps-)
  - [4. O mundo 3D](#4-o-mundo-3d-)
  - [5. Acessibilidade de verdade](#5-acessibilidade-de-verdade-)
  - [6. Offline com PWA](#6-offline-com-pwa-)
  - [7. Dados na nuvem com Supabase](#7-dados-na-nuvem-com-supabase-)
- [🧭 Decisões de projeto (e o que descartamos)](#-decisões-de-projeto-e-o-que-descartamos)
- [🗂️ Estrutura dos arquivos](#️-estrutura-dos-arquivos)
- [🚀 Como rodar e publicar](#-como-rodar-e-publicar)
- [🎓 Mapa das disciplinas](#-mapa-das-disciplinas)
- [💼 Escalabilidade e visão comercial](#-escalabilidade-e-visão-comercial)
- [📄 Validação científica](#-validação-científica)
- [🛣️ Roadmap](#️-roadmap)
- [👥 Autores](#-autores)

---

## ✨ O que é o UniMaps

Quem nunca se perdeu procurando uma sala numa faculdade? O **UniMaps** resolve isso para o 1º pavimento do campus **Via Centro da UNIUBE**. É um **GPS para dentro do prédio**: o aluno escaneia um QR Code fixado num ponto físico, o app entende onde ele está, ele escolhe para onde quer ir, e uma **rota animada em 3D** mostra o caminho — desviando pela rampa quando a pessoa precisa de uma rota acessível.

Tudo isso roda **no navegador**, sem instalar nada, e continua funcionando **mesmo sem internet** depois da primeira abertura.

> 💡 **A sacada central:** GPS comum não funciona dentro de prédios (o sinal de satélite não atravessa as lajes). O UniMaps contorna isso usando **QR Codes como pontos de referência** — cada código diz ao app exatamente onde a pessoa está.

---

## 🎬 Como funciona, em 30 segundos

```
📷 Escaneia o QR  →  📍 "Você está na Sala 120"  →  🎯 Escolhe o destino  →  🧭 Rota 3D animada
```

1. **Escaneia** um QR Code afixado no campus (portaria, sala dos docentes, etc.).
2. O app **reconhece o ponto de partida** a partir do código.
3. O aluno **escolhe o destino** numa lista.
4. O algoritmo calcula o melhor caminho e um **boneco-guia percorre a rota em 3D**, com instruções passo a passo ("vire à direita", "siga em frente").

---

## 🧠 A engenharia por trás (a parte importante)

Esta seção é o coração do projeto. Cada peça resolve um problema real, e juntas formam um sistema de navegação completo.

### 1. O mapa é um grafo 🕸️

O prédio não é guardado como uma "imagem". Ele é modelado como um **grafo** — a mesma estrutura que o Google Maps usa para ruas. São duas peças:

- **Nós (`nós`)** — pontos de interesse e cruzamentos de corredor. Cada nó tem coordenadas `(x, y)` em metros reais do prédio.
- **Arestas (`arestas`)** — as ligações possíveis entre dois nós (ou seja, "dá para andar daqui até ali").

```
  [Portaria] ──── [Cruzamento A] ──── [Cruzamento B] ──── [Sala 158]
                        │
                   [Escada] (só rota padrão)
                        │
                   [Rampa]  (rota acessível)
```

Modelar o prédio como grafo é o que torna a navegação **possível e flexível**: para adicionar uma sala nova, basta adicionar um nó e uma aresta — sem redesenhar nada.

### 2. A rota é o algoritmo A* ⭐

Com o grafo pronto, como achar o **melhor caminho** entre dois pontos? Com o **A\* (A-estrela)**, um dos algoritmos de busca mais clássicos da computação. Ele encontra o trajeto mais curto explorando o grafo de forma inteligente — sempre priorizando os nós que parecem levar mais rápido ao destino (usando a distância em linha reta como "palpite").

> 🦽 **Truque da rota acessível:** quando o usuário ativa o modo acessível, o app simplesmente **remove as arestas da escada** antes de rodar o A\*. Resultado: o algoritmo é *obrigado* a achar um caminho pela rampa. Mesma lógica, resultado diferente — elegante e simples.

### 3. O QR Code é a "localização sem GPS" 📷

Cada QR Code físico carrega um link com um parâmetro de origem, por exemplo:

```
https://[...]/?origem=sala120
```

Quando o app abre com esse parâmetro, ele já sabe: *"o usuário está no nó da Sala 120"*. É um **checkpoint físico** — barato, confiável e que funciona onde o GPS falha. Os três QR atuais (Portaria, Docentes 158 e Sala 120) abrem direto a tela de seleção de destino com a origem já definida.

### 4. O mundo 3D 🎨

A cena é construída com **[Three.js](https://threejs.org/)** (biblioteca de WebGL), de forma **procedural** — ou seja, o prédio é desenhado por código a partir das medidas reais, não importado de um modelo pronto. Salas, paredes, a escada rolante, a rampa, a icônica parede amarela dos laboratórios e um **boneco-guia articulado** que caminha pela rota. A câmera segue o guia em estilo "sobre o ombro", como num jogo.

### 5. Acessibilidade de verdade ♿

Acessibilidade não é enfeite aqui — é um pilar:

- **🤟 VLibras** — tradução do conteúdo para Libras (língua brasileira de sinais), via widget oficial do governo.
- **🔊 Leitura por voz (TTS)** — as instruções da rota são faladas em português, usando a Web Speech API.
- **🎨 Alto contraste e fonte ajustável** — para baixa visão.
- **🦽 Rota acessível** — desvia da escada para a rampa (ver o truque do A\* acima).
- **🎬 Reduzir animações** — para quem tem sensibilidade a movimento.

### 6. Offline com PWA 📴

O UniMaps é um **PWA (Progressive Web App)**. Na primeira abertura com internet, um **Service Worker** (`sw.js`) guarda o app inteiro e a biblioteca 3D em cache. Depois disso, ele **abre e navega sem internet nenhuma** — essencial num campus onde o sinal indoor costuma falhar. O app pode até ser "instalado" na tela inicial do celular, como um aplicativo nativo.

> ⚙️ **Por que isso funciona offline?** Porque o A\* e os dados do mapa rodam **dentro do navegador**. Nenhuma rota precisa de servidor — o cálculo acontece no próprio aparelho.

### 7. Dados na nuvem com Supabase ☁️

Os dados do mapa (blocos, nós e arestas) podem vir de um banco **PostgreSQL no [Supabase](https://supabase.com/)**, na nuvem. Mas há uma rede de segurança importante: se o banco estiver fora do ar, **o app usa automaticamente uma cópia local embutida** (`EMBED`) e funciona igual. O usuário nunca fica na mão.

```
┌─────────────┐   tem internet?   ┌──────────────────┐
│  Supabase   │ ───── sim ──────▶ │  dados da nuvem   │
│ (PostgreSQL)│                   └──────────────────┘
└─────────────┘   não / falhou    ┌──────────────────┐
                  ─────────────▶  │  dados locais     │
                                  │  (fallback EMBED) │
                                  └──────────────────┘
```

---

## 🧭 Decisões de projeto (e o que descartamos)

Esta seção explica **por que** o UniMaps é como é. Cada decisão envolveu trade-offs, e documentá-los faz parte da engenharia.

### Por que 3D na web — e não Realidade Aumentada ou Mista?

A escolha mais natural num evento como a feira poderia ser AR/RV. Optamos conscientemente por **navegação 3D no navegador**, e essa é a decisão de projeto mais importante de todo o trabalho.

**O que descartamos — AR/RV — e por quê:**
- **Custo e hardware.** Soluções de RA/RV de qualidade exigem dispositivos de ponta (sensores específicos, boa GPU) ou até óculos/visores. Isso exclui boa parte dos alunos, que usam celulares modestos.
- **Barreira de acessibilidade.** A imersão de AR/RV é, por natureza, visual. Ela tende a *excluir* pessoas com deficiência visual — o oposto do nosso objetivo.
- **Fragmentação de plataforma.** AR na web (WebXR) tem suporte irregular, especialmente em iPhones, o que quebraria a promessa de "funciona no celular de qualquer um".

**O que ganhamos com 3D na web:**
- Roda em **qualquer navegador**, sem instalar nada e sem hardware especial.
- Permite uma camada de **acessibilidade rica** (voz, Libras, contraste) que conviveria mal com a imersão de AR.
- É **leve o suficiente** para funcionar offline.

> **Trade-off assumido:** abrimos mão da imersão de AR/RV em troca de **alcance universal e acessibilidade**. Para o caso de uso — orientar alguém até uma sala — concluímos que chegar a todos importa mais do que impressionar alguns. *(AR continua no roadmap como modo opcional futuro, sobre a mesma base 3D.)*

### Por que fazer questão de funcionar offline?

O UniMaps é um **PWA com funcionamento offline** por uma razão concreta: **o sinal de internet falha justamente dentro dos prédios**, que é onde o app é usado. Um app de navegação indoor que dependesse de conexão seria inútil no exato momento em que o usuário mais precisa dele — perdido num corredor sem sinal.

- **Como conseguimos:** um *service worker* faz cache do app e da biblioteca 3D na primeira abertura; o algoritmo de rota (A\*) e os dados do mapa rodam no próprio navegador, sem servidor.
- **O que descartamos:** uma arquitetura cliente-servidor, em que cada rota seria calculada na nuvem. Seria mais simples de atualizar, mas frágil sem internet.

> **Trade-off assumido:** o núcleo de navegação funciona **100% offline**; em contrapartida, dois recursos *dependem* de internet — o **VLibras** (tradução em Libras, hospedada pelo governo) e a sincronização opcional com o **Supabase**. Quando offline, o app cai automaticamente nos dados locais e segue funcionando.

### Por que QR Code — e não GPS ou sensores (BLE/Wi-Fi)?

Para saber *onde o usuário está*, descartamos duas alternativas comuns:

- **GPS:** não funciona indoor — o sinal de satélite é bloqueado por lajes e paredes.
- **Sensores (beacons BLE, Wi-Fi fingerprinting):** funcionam, mas exigem **instalar e manter infraestrutura** (dezenas de dispositivos, calibração periódica, custo recorrente).

O **QR Code** resolve o problema com custo praticamente zero: um adesivo impresso em cada checkpoint. Ele não dá posição contínua, mas dá o que importa — **o ponto de partida** — e é trivial de implantar em qualquer prédio.

> **Trade-off assumido:** abrimos mão do rastreamento *contínuo* da posição (que beacons dariam) em troca de **custo zero de infraestrutura e implantação imediata**. Para orientação ponto-a-ponto, saber a origem é suficiente.

### Por que um único arquivo e deploy estático?

O sistema roda como aplicação estática (HTML + biblioteca via CDN) publicada na Vercel. Descartamos um back-end pesado porque ele encareceria a hospedagem e adicionaria pontos de falha. A consequência é um projeto **barato de hospedar, simples de implantar e fácil de escalar** — o que conecta diretamente com a visão comercial abaixo.


|---|---|
| 🏠 `index.html` | O aplicativo inteiro: cena 3D, A\*, interface, acessibilidade. É o coração do projeto. |
| ⚙️ `config.js` | Credenciais públicas do Supabase (chave de leitura). |
| 🗄️ `supabase.sql` | Script que cria as tabelas `blocos`, `nos` e `arestas` no banco. |
| 📴 `sw.js` | Service Worker — faz o cache que permite uso offline. |
| 📱 `manifest.json` | Manifesto do PWA (nome, ícones, cores) — torna o app instalável. |
| 🖼️ `icon-192.png` · `icon-512.png` | Ícones do app instalado. |
| 🔗 `qr.html` | Gerador/visualizador dos QR Codes dos checkpoints. |
| 📊 `kanban.html` | Quadro de acompanhamento do projeto (gestão ágil). |
| 🛡️ `vercel.json` | Cabeçalhos de segurança (CSP, HSTS) da hospedagem. |
| 🤖 `api/chatbot.js` | Back-end serverless preparado para um assistente de IA *(ainda não ativado — ver Roadmap)*. |

---

## 🚀 Como rodar e publicar

### Rodar localmente
Como o app usa módulos JavaScript, ele precisa de um servidor local simples (abrir o arquivo direto no navegador não funciona por causa das restrições de segurança dos módulos).

```bash
# na pasta do projeto, rode um servidor local:
python -m http.server 8000
# depois abra no navegador:
# http://localhost:8000
```

### Publicar (deploy)
O projeto está hospedado na **Vercel** e o deploy é **automático**: todo `git push` para a branch `main` publica a nova versão.

```bash
git pull origin main          # 1. pega a versão mais recente
# ... faça suas alterações ...
git add index.html            # 2. adiciona os arquivos alterados
git commit -m "feat: descrição da mudança"   # 3. registra a mudança
git push                      # 4. publica (a Vercel faz o resto)
```

> 🔄 Os commits seguem o padrão **[Conventional Commits](https://www.conventionalcommits.org/)** (`feat:`, `fix:`, `docs:`...), como evidência de versionamento profissional.

---

## 🎓 Mapa das disciplinas

Cada componente técnico do projeto se conecta a uma disciplina do curso de ADS — o que faz dele um verdadeiro **Trabalho Integrador**:

| 🧩 Componente | 📚 Disciplina |
|---|---|
| Grafo + algoritmo A\* | Estruturas de Dados / Matemática Discreta |
| Banco PostgreSQL (Supabase) | Banco de Dados |
| Service Worker / PWA | Tecnologias para Internet |
| Hospedagem e CI/CD na nuvem | Cloud Computing |
| Acessibilidade (VLibras, WCAG) | Engenharia de Software / IHC |
| Cabeçalhos CSP e segurança | Segurança e Auditoria |
| Back-end de IA *(preparado)* | Tecnologias Digitais Emergentes |

---

## 💼 Escalabilidade e visão comercial

O UniMaps não foi pensado apenas como trabalho acadêmico, mas como **base de um produto**. A arquitetura — grafo de dados separável, deploy estático barato, sem hardware especial — foi escolhida pensando em escalar.

**O caminho de crescimento, do menor ao maior:**

1. **Um pavimento** → estado atual (1º andar do campus Via Centro).
2. **Um campus inteiro** → suporte a múltiplos andares e prédios, reutilizando a mesma engine.
3. **Múltiplos campi** → expansão planejada para o **Campus Gávea da UNIUBE**, provando que a solução replica.
4. **Produto para outras instituições** → modelo de **solução licenciável (SaaS)** de navegação indoor para outras universidades, com um painel em que a própria instituição cadastra e mantém suas salas.

**O diferencial de mercado** está em democratizar a navegação indoor: hoje, o mapeamento interno detalhado costuma existir só em grandes locais comerciais cadastrados por terceiros. O UniMaps permite que **qualquer instituição** tenha o seu — com três vantagens difíceis de igualar:

- 🎯 **Controle institucional dos dados** — a instituição mantém o próprio mapa, sem depender de terceiros cadastrarem o prédio.
- ♿ **Acessibilidade nativa** — Libras, voz e alto contraste, raramente presentes em soluções de wayfinding.
- 💰 **Baixo custo e offline** — roda em qualquer celular, sem infraestrutura de sensores nem hardware dedicado.

> Há interesse institucional da UNIUBE na adoção e expansão da solução, o que reforça seu potencial de produto além do contexto acadêmico.

---

## 📄 Validação científica

O embasamento técnico-científico do projeto foi submetido como artigo (short paper) ao **SVR 2026 — 28º Simpósio de Realidade Virtual e Aumentada** (Sociedade Brasileira de Computação), na trilha *Workshop of Undergraduate Works*. O artigo posiciona o UniMaps como **alternativa acessível e de baixo custo às soluções de RA/RV** para orientação espacial, discutindo seus impactos sociais, econômicos e técnicos.

---

## 🛣️ Roadmap

Próximos passos planejados (acompanhados no `kanban.html`):

- [ ] 🦽 Rampa e elevador como caminho real no grafo da rota acessível
- [ ] 🏢 Suporte a **múltiplos andares** (dados separados por pavimento)
- [ ] 🤖 Ativar o **assistente de IA** (integrar a interface ao back-end `api/chatbot.js`)
- [ ] 🏫 **Multi-campus** e painel de cadastro de salas para não-programadores
- [ ] 🎓 Integração com o **AVA (Moodle)**: link → autenticação LTI → rota a partir do horário de aula

---

## 👥 Autores

Projeto desenvolvido para a **Amostra Tech 2026** — Análise e Desenvolvimento de Sistemas, **Universidade de Uberaba (UNIUBE)**, campus Via Centro.

- **Arthur Moreira Martins** · RA 5168694
- **Maria Eduarda dos Santos Duque Estrada** · RA 5171981

<div align="center">
<br>

**🧭 UniMaps** — *porque ninguém merece se perder dentro da própria faculdade.*

</div>
