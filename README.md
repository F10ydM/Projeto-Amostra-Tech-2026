# UniMaps · GPS interno 3D — Via Centro Uniube (1º pavimento)

Demonstração ponta-a-ponta de navegação **indoor** sem GPS: um QR localiza a
pessoa (checkpoint), o **A\*** calcula a rota sobre um grafo, e o front desenha
o caminho em **3D estilizado** ("GPS holográfico"), no estilo do Maps —
fundo escuro, rota azul brilhante, HUD turn-by-turn e minimapa.

Identidade: **UniMaps** (navy profundo + azul vivo + branco).

---

## Anatomia (amarrada no conceito do projeto)

1. **Dados** — o prédio vira um grafo: `nos` (pontos), `arestas` (corredores,
   com peso e tipo) e `blocos` (a planta para render/minimapa). Vive no Supabase.
2. **Localização** — `qr` mapeia cada código físico → nó de origem. O scan abre
   `/?origem=<codigo>`: é o "você está aqui" (sem GPS, sem sensor).
3. **Roteamento** — **A\*** (Dijkstra + heurística de distância em linha reta)
   roda **no navegador**, de `origem` → `destino`. O **modo acessível** é o mesmo
   A\* com as arestas `tipo='escada'` removidas (e escada é mão-única no grafo).
4. **Apresentação** — Three.js: rota holográfica com fluxo, câmera 1ª/3ª pessoa
   com head-bob e leve inclinação nas curvas, HUD ("vire à esquerda", distância,
   ETA) e minimapa. Deploy estático no Vercel.

> Frase de banca: *"o QR me localiza, o A\* me roteia sobre o grafo do Supabase,
> e o front desenha o caminho em 3D — o modo acessível é o mesmo A\* sem escada."*

---

## Arquivos

| Arquivo | Função |
|---|---|
| `index.html` | App (3D + A\* + HUD + minimapa + QR). Roda offline com dados embutidos. |
| `config.js` | URL/chave anon do Supabase. **Vazio = offline.** |
| `supabase.sql` | Schema + seed + RLS de leitura pública. |
| `qr.html` | Gera os QR dos pontos físicos apontando para o app. |
| `vercel.json` | Config estática mínima. |

---

## Deploy

### 1) Supabase (opcional — o app funciona sem ele)
1. Crie um projeto em supabase.com.
2. **SQL Editor** → cole `supabase.sql` → **Run** (cria tabelas, seed e RLS).
3. **Project Settings → API** → copie a **Project URL** e a **anon key**.
4. Cole as duas em `config.js`. (A anon key é pública por design — só leitura,
   protegida pelas policies de RLS.)

### 2) Vercel
1. Suba esta pasta para um repositório no GitHub.
2. Em vercel.com → **Add New → Project** → importe o repo.
3. Framework preset: **Other** (é estático, sem build). Deploy.
4. Você recebe uma URL tipo `https://unimaps.vercel.app`.

### 3) QR
1. Abra `qr.html` (local ou na URL do Vercel) e cole a URL publicada.
2. Imprima os QR. Cada um abre o app já com a origem certa.

---

## Como funciona o ir-e-voltar

Não são "dois QR para a mesma rota": é **um QR por ponto físico**. O QR só diz a
origem; o A\* monta o caminho até o destino escolhido. Na tela há "Rota de volta"
(inverte origem/destino e recalcula). Como a escada é mão-única no grafo, a volta
pode pegar um caminho diferente — é o A\* decidindo, não um trajeto fixo.

---

## Editar a planta / a rota

Tudo sai do editor 2D (`editor-planta-via-centro.html`): exporte o JSON e
atualize os `INSERT` de `supabase.sql` (ou o objeto `EMBED` no topo do
`index.html`). Coordenadas em **metros**; `x` = leste-oeste, `y` = norte-sul.

---

## Escopo honesto (o que é e o que não é)

- É um **3D estilizado em tempo real** ("blueprint holográfico"), mobile-first,
  fiel ao look do Maps e ao conceito de campus inteligente.
- **Não** é fotorrealismo/AAA: um arquivo único via CDN no celular não comporta
  assets pesados nem engine nativa. Por performance, **DOF, motion-blur e SSAO
  pesados foram deixados de fora** (o "cinematográfico" vem de névoa, emissivos,
  fluxo na rota e movimento de câmera).
- As **distâncias são estimadas** para demonstração (grade de ~1 m).
- Posicionamento é por **checkpoint (QR)**, não contínuo — indoor não tem GPS
  confiável, então o app simula o avanço ao longo da rota.
