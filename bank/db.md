# Banco de dados — comandos úteis

Postgres do Bank roda no container **`bank-db`** (podman, postgres:17) na porta **5433**.

- Banco: `bank` · usuário: `postgres` · senha: `postgres` (ver `application.yml`)
- Use **`podman`**, não `docker` — os containers são rootless do podman.

## 1. Visualizador web (pgweb)

Já existe um container `bank-pgweb` apontando pro banco. Abra no navegador:

```
http://localhost:8081
```

## 2. Shell interativo do psql

```bash
podman exec -it bank-db psql -U postgres -d bank
```

Dentro do `psql`:

```sql
\dt                 -- lista as tabelas
\d transfers        -- estrutura de uma tabela
\q                  -- sair
```

## 3. Consultas diretas (one-liner)

**Saldo de todos os usuários:**

```bash
podman exec bank-db psql -U postgres -d bank -c \
"select u.name, u.email, a.balance, a.status from accounts a join users u on u.id = a.user_id order by u.name;"
```

**Histórico de transferências:**

```bash
podman exec bank-db psql -U postgres -d bank -c \
"select id, from_account_id, to_account_id, amount, status, created_at from transfers order by created_at desc;"
```

**Razão / dupla entrada (ledger):**

```bash
podman exec bank-db psql -U postgres -d bank -c \
"select account_id, transfer_id, type, amount, created_at from ledger_entries order by created_at desc;"
```

**Versão das migrações aplicadas (Flyway):**

```bash
podman exec bank-db psql -U postgres -d bank -c \
"select version, description, success from flyway_schema_history order by installed_rank;"
```

## Conectar do host (alternativa, sem entrar no container)

Requer o cliente `psql` instalado no host (`sudo dnf install postgresql`):

```bash
psql -h localhost -p 5433 -U postgres -d bank
```
