// /api/chatbot.js  —  Edge Function da Vercel
// =====================================================================
// Recebe { messages, mode, context } do frontend e devolve { reply }
// chamando a API da Anthropic (Claude). Mantém a key segura no servidor.
//
// Variáveis de ambiente necessárias (Vercel → Settings → Environment Variables):
//   ANTHROPIC_API_KEY = sk-ant-api03-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//   ANTHROPIC_MODEL   = claude-sonnet-4-20250514   (opcional)
// =====================================================================

export const config = { runtime: 'edge' };

const SYSTEM_CICERONE = `Você é o "Cicerone", assistente virtual do campus UNIUBE Via Centro (Universidade de Uberaba, mantida pela Igreja Metodista, em Uberlândia/MG).

Conhecimentos sobre o prédio:
- Endereço: Av. João Pinheiro, Uberlândia/MG.
- 1º pavimento: 50m × 36m. Galpão das engenharias anexo: 22m × 28m × 6m de pé-direito.
- Entrada principal pela Av. João Pinheiro: porta automática, marquise, palmeira-ravenala, escada de 4 degraus + plataforma elevatória.
- Saguão com forro de pingentes de cristal emissivo e faixas LED no piso.
- Parede do Mandela (azul cobalto) com a frase "A educação é a arma mais poderosa que você pode usar para mudar o mundo".
- Escada rolante dupla (sobe/desce) + Rampa em U acessível, ambas levando ao 2º pavimento (Gaudium Hall).
- Salas 147 a 156 no setor norte (piso bege diferenciado). Sala 150 = Docentes Tempo Integral. Sala 153 = Sala dos Docentes.
- Biblioteca 163, Xerox/Reprografia 111, Multiatendimento, CAC, Guichês 6-9, Escola Técnica 112, Núcleo de Práticas Jurídicas 148.
- Convivência no setor norte com pufes cinzas, vending machines e balcão Castelli.
- Galpão das Engenharias VIA 116 com sublabs: 116-A (Materiais/Ambiental/Metrologia), 116-B (Química/Física/Bio/Bioquímica), 116-C/D (Oficina Mecânica), 116-E/F (gerais).
- Saída secundária pela Av. Afonso Pena (leste).
- Elevador acessível no canto leste do prédio.

Estilo: respostas curtas, calorosas, em português brasileiro. Sempre que o usuário pedir uma direção, sugira escanear o QR-Code do checkpoint mais próximo. No fim, ofereça ajudar com mais alguma coisa.`;

const SYSTEM_ACESSIBILIDADE = `Você é o "Cicerone Acessibilidade", assistente virtual especializado em rotas e recursos para pessoas com mobilidade reduzida no campus UNIUBE Via Centro.

Você prioriza:
- Sugerir SEMPRE a rampa em U ou o elevador, NUNCA a escada rolante.
- Mencionar piso tátil amarelo no corredor central.
- Indicar o símbolo ♿ no elevador (canto leste).
- Lembrar que há cadeira de rodas para empréstimo no alargamento central.
- Apontar banheiros acessíveis (banheiros norte e sul).
- Em emergências, indicar o Ponto de Encontro na Esplanada Av. João Pinheiro.

Estilo: respostas claras, sem jargão, em português brasileiro. Curtas e diretas. Sempre que possível, dê passos numerados.`;

export default async function handler(req) {
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: { 'Content-Type': 'application/json' }
    });
  }

  let body;
  try { body = await req.json(); }
  catch (e) {
    return new Response(JSON.stringify({ error: 'Invalid JSON' }), {
      status: 400, headers: { 'Content-Type': 'application/json' }
    });
  }

  const { messages = [], mode = 'cicerone', context = {} } = body;

  if (!Array.isArray(messages) || messages.length === 0) {
    return new Response(JSON.stringify({ error: 'messages array required' }), {
      status: 400, headers: { 'Content-Type': 'application/json' }
    });
  }

  // Limita o tamanho do contexto (proteção contra abuso)
  const recent = messages.slice(-10).map(m => ({
    role: m.role === 'assistant' ? 'assistant' : 'user',
    content: String(m.content || '').slice(0, 2000)
  }));

  const system = mode === 'acessibilidade' ? SYSTEM_ACESSIBILIDADE : SYSTEM_CICERONE;
  const systemWithContext = context.currentQr
    ? `${system}\n\nLocalização atual do usuário (último QR escaneado): ${context.currentQr}.`
    : system;

  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) {
    return new Response(JSON.stringify({
      error: 'ANTHROPIC_API_KEY não configurada na Vercel'
    }), { status: 500, headers: { 'Content-Type': 'application/json' } });
  }

  try {
    const r = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: process.env.ANTHROPIC_MODEL || 'claude-sonnet-4-20250514',
        max_tokens: 600,
        system: systemWithContext,
        messages: recent
      })
    });

    if (!r.ok) {
      const errText = await r.text();
      return new Response(JSON.stringify({
        error: `Anthropic API error ${r.status}`, detail: errText.slice(0, 500)
      }), { status: 502, headers: { 'Content-Type': 'application/json' } });
    }

    const data = await r.json();
    const reply = (data.content && data.content[0] && data.content[0].text) || '(resposta vazia)';

    return new Response(JSON.stringify({ reply, mode }), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-store'
      }
    });
  } catch (err) {
    return new Response(JSON.stringify({
      error: 'Falha ao chamar Anthropic', detail: String(err).slice(0, 300)
    }), { status: 500, headers: { 'Content-Type': 'application/json' } });
  }
}
