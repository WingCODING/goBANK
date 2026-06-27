# goBANK — Lumo · **V1**

Mini-banco digital de demonstração (projeto de portfólio). É um **monorepo** com
3 componentes que se comunicam por HTTP/JSON, mais um banco PostgreSQL.

> ⚠️ Projeto de estudo. "Vida real" aqui significa rodar online com segurança
> técnica básica — **não** operar como instituição financeira (sem conformidade
> Banco Central / LGPD / PCI-DSS, KYC, auditoria etc.).

---

## Arquitetura

```
        📱 Lumo App (Flutter / Android)
                 │   JWT (HS512, claim cpf)
        ┌────────┴─────────┐
        ▼                  ▼
  ☕ Bank Service     🐹 Loan Service
  Spring Boot :8080   Go (net/http) :8085
        │   ▲                │
        │   └── /internal/disbursements (API key, idempotente)
        ▼                    ▼
     ┌──────────── PostgreSQL ───────────┐
     │   DB `bank`          DB `loans`    │
     └────────────────────────────────────┘
```

| Componente | Stack | Porta | Responsabilidade |
|---|---|---|---|
| **Bank Service** | Java 25 / Spring Boot 4.1 | 8080 | Fonte da verdade do dinheiro: contas, saldos, transferências, cobranças, ledger interno |
| **Loan Service** | Go (stdlib + net/http) | 8085 | Originação e desembolso de empréstimos |
| **Lumo App** | Flutter (Riverpod 3 + go_router + dio) | — | Cliente mobile Android, 7 telas, pt-BR |
| **PostgreSQL** | Postgres 17 (container) | 5433 | DBs `bank` e `loans` |

---

## Bank Service (Java / Spring Boot) — `:8080`

Endpoints públicos (JWT, exceto register/login):

- `POST /api/users/register` — cadastro
- `POST /api/auth/login` — retorna JWT **HS512** com claims `sub` (email) + **`cpf`**
- `GET  /api/users/me` — perfil / saldo
- `POST /api/transfer` — transferência entre contas
- `POST /api/payment-requests` — criar cobrança
- `GET  /api/payment-requests/incoming` | `/outgoing` — listas
- `POST /api/payment-requests/{id}/approve` | `/reject`

Endpoint **interno** (sem JWT de usuário — protegido por API key via
`InternalApiKeyFilter`, consumido só pelo Loan Service):

- `POST /internal/disbursements` — credita o resultado de um empréstimo. É
  **idempotente**: a tabela `disbursements` usa o id do empréstimo como chave,
  então retries não duplicam o crédito.

Persistência via Flyway (migrations V1–V6): `users`, `transfers`,
`payment_requests`, `system_account` (seed), `disbursements`.

## Loan Service (Go) — `:8085`

- `GET  /health`
- `POST /loans` — protegido por `RequireJWT` (middleware próprio). Valida a
  assinatura do JWT com o **mesmo `JWT_SECRET`** do Bank e **deriva o devedor do
  claim `cpf`** — o body não carrega CPF, então ninguém desembolsa para outro CPF.

**Fluxo de desembolso (exactly-once):**

1. Cria empréstimo `PENDING` (schema criado por `EnsureSchema` no boot).
2. Chama `POST /internal/disbursements` no Bank com uma *idempotency key*.
3. Sucesso → `DISBURSED`; falha ambígua (timeout) → permanece `PENDING`.
4. Um **reconciler** roda a cada 30s e re-tenta os `PENDING`. Combinado com a
   idempotência do Bank, garante crédito *exactly-once*.

## Lumo App (Flutter)

Arquitetura feature-first: `data/` → `providers/` (Riverpod) → `presentation/`.
Core compartilhado em `lib/core/` (dio client, interceptor que injeta o JWT,
secure storage, theme, router, config via `--dart-define`). Navegação com
`StatefulShellRoute` (4 abas: Home / Transferir / Cobranças / Empréstimo).

Dois clients dio (`bankDio` :8080 e `loanDio` :8085), ambos anexam o JWT.
Dados ligados ao backend real sempre que a tela fornece o que o endpoint precisa;
mock só do que não há endpoint (atividade recente da Home, contatos da
Transferência).

---

## Segurança / contratos transversais

- **JWT compartilhado**: o Bank emite, o Loan valida. `JWT_SECRET` deve ser
  idêntico nos dois serviços. O claim `cpf` liga identidade → autorização de empréstimo.
- **Confiança serviço-a-serviço**: `/internal/*` é isolado do JWT de usuário e
  protegido por API key — só o Loan Service o chama.
- **Idempotência + reconciliação** é o mecanismo central de correção financeira
  entre os dois serviços.

---

## Como rodar (ambiente de demo)

```bash
# 1. PostgreSQL (container) — DBs bank + loans na porta 5433
#    (rodando via podman, container bank-db / postgres:17)

# 2. Bank Service — Flyway auto-migra (V1–V6) e faz seed
cd bank && ./mvnw spring-boot:run        # :8080

# 3. Loan Service — cria schema no boot e sobe o reconciler
cd loan-service && go run .              # :8085

# 4. Lumo App no emulador Android (host = 10.0.2.2)
flutter run -d emulator-5554 \
  --dart-define=BANK_BASE_URL=http://10.0.2.2:8080 \
  --dart-define=LOAN_BASE_URL=http://10.0.2.2:8085
```

> No emulador Android, o backend é acessível em `10.0.2.2`; cleartext HTTP é
> liberado em `android/app/src/main/res/xml/network_security_config.xml`.

---

## Estrutura do repositório

```
goBANK/
├── bank/            # Bank Service (Java / Spring Boot)
├── loan-service/    # Loan Service (Go)
├── goflutterbank/   # Lumo App (Flutter)
└── README.md        # este arquivo
```

---

_V1 — primeira versão funcional do stack completo (Bank + Loan + Lumo)._
