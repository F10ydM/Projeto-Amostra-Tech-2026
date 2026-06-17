// ============================================================================
//  UniMaps · Service Worker
//  Faz o app funcionar OFFLINE após a primeira abertura com internet.
//  Estratégia:
//   - App local (HTML/config/manifest/ícones): cache-first
//   - Three.js (CDN jsdelivr): cache-first (guarda na 1ª vez)
//   - Supabase: network-first (dados frescos online; offline cai no EMBED do app)
//   - Demais (fontes, VLibras): network, com fallback ao cache se houver
// ============================================================================

const CACHE = 'unimaps-v33';

// Recursos essenciais para o app abrir offline.
const CORE = [
  './',
  './index.html',
  './kanban.html',
  './config.js',
  './manifest.webmanifest',
  // Three.js (mesmas URLs do importmap do index.html)
  'https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.module.js',
  'https://cdn.jsdelivr.net/npm/three@0.160.0/examples/jsm/controls/OrbitControls.js',
  'https://cdn.jsdelivr.net/npm/three@0.160.0/examples/jsm/renderers/CSS2DRenderer.js'
];

// Instalação: baixa e guarda o núcleo. Se algum item falhar, não derruba a instalação.
self.addEventListener('install', (e) => {
  e.waitUntil((async () => {
    const c = await caches.open(CACHE);
    await Promise.allSettled(CORE.map((u) => c.add(u)));
    self.skipWaiting();
  })());
});

// Ativação: limpa caches antigos de versões anteriores.
self.addEventListener('activate', (e) => {
  e.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)));
    self.clients.claim();
  })());
});

self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);

  // Supabase → network-first (sempre tenta dados frescos; sem rede, o app usa o EMBED local)
  if (url.hostname.endsWith('supabase.co')) {
    e.respondWith(fetch(req).catch(() => caches.match(req)));
    return;
  }

  // PÁGINAS (index.html, kanban.html e navegação) → NETWORK-FIRST:
  // com internet, sempre entrega a versão mais recente; sem internet, usa o cache.
  const isPage = req.mode === 'navigate'
    || url.pathname.endsWith('.html')
    || url.pathname === '/' || url.pathname === '';
  if (url.origin === location.origin && isPage) {
    e.respondWith((async () => {
      try {
        const res = await fetch(req, { cache: 'no-store' });   // ignora cache do navegador
        if (res && res.ok) {
          const c = await caches.open(CACHE);
          c.put(req, res.clone());                              // atualiza o cache para uso offline
        }
        return res;
      } catch (err) {
        // offline: usa a versão guardada (ou o index como fallback de navegação)
        return (await caches.match(req)) || (await caches.match('./index.html'));
      }
    })());
    return;
  }

  // VLibras → só rede (não dá para cachear de forma confiável; offline ele simplesmente não aparece)
  if (url.hostname.endsWith('vlibras.gov.br')) {
    return; // deixa o navegador lidar normalmente
  }

  // Three.js e demais GET → cache-first, com atualização em segundo plano
  e.respondWith((async () => {
    const cached = await caches.match(req);
    if (cached) {
      // revalida em segundo plano (stale-while-revalidate) sem bloquear a resposta
      fetch(req).then((res) => {
        if (res && res.ok) caches.open(CACHE).then((c) => c.put(req, res.clone()));
      }).catch(() => {});
      return cached;
    }
    try {
      const res = await fetch(req);
      if (res && res.ok && (url.origin === location.origin || url.hostname.endsWith('jsdelivr.net'))) {
        const c = await caches.open(CACHE);
        c.put(req, res.clone());
      }
      return res;
    } catch (err) {
      // offline e sem cache: para navegação, devolve o index (app abre e usa dados locais)
      if (req.mode === 'navigate') return caches.match('./index.html');
      throw err;
    }
  })());
});
