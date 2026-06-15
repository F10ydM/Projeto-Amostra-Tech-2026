// /sw.js — Service Worker do GPS Interno 3D
// Estratégia: cache-first para assets estáticos · network-first para API
const VERSION = 'uniube-viacentro-v5.1';
const STATIC_CACHE = `static-${VERSION}`;

const PRECACHE = [
  '/',
  '/index.html',
  '/manifest.json',
  '/icon-192.png',
  '/icon-512.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(STATIC_CACHE)
      .then((cache) => cache.addAll(PRECACHE).catch(() => null))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys.filter((k) => k !== STATIC_CACHE).map((k) => caches.delete(k))
      ))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return;

  const url = new URL(req.url);

  // /api/* sempre network-first (chatbot + telemetria)
  if (url.pathname.startsWith('/api/')) {
    event.respondWith(fetch(req).catch(() => new Response(
      JSON.stringify({ error: 'Offline' }),
      { status: 503, headers: { 'Content-Type': 'application/json' } }
    )));
    return;
  }

  // Supabase também sempre network (RPC e queries)
  if (url.hostname.endsWith('.supabase.co')) {
    event.respondWith(fetch(req).catch(() => new Response(null, { status: 504 })));
    return;
  }

  // CDNs e demais — cache-first com revalidação em background
  event.respondWith(
    caches.match(req).then((cached) => {
      const networkFetch = fetch(req).then((resp) => {
        if (resp && resp.status === 200 && (resp.type === 'basic' || resp.type === 'cors')) {
          const clone = resp.clone();
          caches.open(STATIC_CACHE).then((c) => c.put(req, clone)).catch(() => null);
        }
        return resp;
      }).catch(() => cached);
      return cached || networkFetch;
    })
  );
});
