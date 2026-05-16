# AR Uniube — Amostra Tech 2026

Sistema de navegação em realidade aumentada para o prédio Via Centro da UNIUBE.
Aplicação web 3D com WebXR + Three.js permite ao aluno escanear um QR code
no prédio e ver a rota até a próxima sala da grade horária.

Apresentação: Amostra Tech UNIUBE — 16 de junho de 2026.

## Stack

- **Frontend**: Vite + React + TypeScript + Three.js + WebXR
- **Backend**: Node.js + Express + TypeScript
- **Banco**: PostgreSQL via Supabase
- **Auth**: Supabase Auth
- **Admin**: Next.js + shadcn/ui
- **Deploy**: Cloudflare Pages (frontend) + Fly.io (backend)
- **IA**: Groq (chatbot Llama 3)
- **Observabilidade**: Sentry

## Estrutura do monorepo

```
.
├── web/      → frontend público (PWA + WebXR)
├── api/      → backend REST
├── admin/    → painel administrativo
├── shared/   → tipos TypeScript compartilhados
├── db/       → schemas SQL e migrações Supabase
├── infra/    → IaC e configurações de deploy
└── docs/     → documentação técnica
```

## Como rodar localmente

Documentação detalhada em \`docs/setup.md\` (em breve).

## Status

🚧 Em desenvolvimento ativo. Iniciado em 16/05/2026.

## Licença

MIT — ver \`LICENSE\`.