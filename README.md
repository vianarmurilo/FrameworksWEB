# FinMind AI+

Aplicativo full stack de gestao financeira pessoal e familiar.

## Stack

- Frontend mobile/web: Flutter + Riverpod + Dio
- Backend API: Node.js + TypeScript + Express + Prisma
- Banco de dados: PostgreSQL
- Autenticacao: JWT

## Estrutura do Projeto

- lib/: aplicativo Flutter
- backend/: API Node/TypeScript e Prisma
- docs/: planejamento, testes e validacao

## Requisitos

- Flutter SDK instalado e funcional
- Node.js 20+
- npm
- Docker (opcional, para subir Postgres rapido)

## Como Rodar (Desenvolvimento)

### 1) Banco de dados

Opcao A (Docker):

1. Abrir terminal em backend/
2. Rodar:

```bash
docker compose up -d
```

Opcao B (Prisma Dev local):

- Seguir o guia em docs/backend/04-prisma-dev-db.md

### 2) Backend

1. Copiar backend/.env.example para backend/.env
2. Ajustar variaveis, principalmente DATABASE_URL e JWT_SECRET
3. No terminal em backend/, rodar:

```bash
npm install
npm run prisma:generate
npm run prisma:migrate
npm run dev
```

Backend por padrao em http://localhost:3333/api

### 3) Frontend Flutter

No terminal na raiz do projeto:

```bash
flutter pub get
flutter run
```

## Qualidade e Validacao

Frontend:

```bash
flutter analyze
flutter test
```

Backend:

```bash
cd backend
npm run build
```

Testes de API:

- Colecao: docs/backend/02-api-tests.postman_collection.json
- Guia: docs/backend/03-validacao-manual.md

## Endpoints Principais

- /api/auth
- /api/transactions
- /api/goals
- /api/categories
- /api/subscriptions
- /api/family
- /api/health
- /api/analytics, /api/predictions, /api/alerts, /api/advisor

## Modulos Entregues

- Autenticacao JWT
- CRUD de transacoes, metas e categorias
- Familia (grupos, convite, dashboard coletivo)
- Dashboard financeiro com indicadores
- Recursos de inteligencia financeira (analytics, previsao, alertas, advisor)

## Documentacao Complementar

- Arquitetura e modelagem: docs/architecture/01-planejamento-modelagem.md
- Validacao manual: docs/backend/03-validacao-manual.md
- Banco Prisma Dev: docs/backend/04-prisma-dev-db.md
- Deploy e producao: docs/backend/05-deploy-producao.md
