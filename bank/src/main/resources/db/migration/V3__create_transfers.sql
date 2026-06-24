CREATE TABLE transfers (
    id              UUID PRIMARY KEY,
    from_account_id UUID            NOT NULL REFERENCES accounts(id),
    to_account_id   UUID            NOT NULL REFERENCES accounts(id),
    amount          NUMERIC(18,2)   NOT NULL,
    status          VARCHAR(20)     NOT NULL,
    created_at      TIMESTAMPTZ     NOT NULL
);

CREATE TABLE ledger_entries (
    id          UUID PRIMARY KEY,
    account_id  UUID            NOT NULL REFERENCES accounts(id),
    transfer_id UUID            NOT NULL REFERENCES transfers(id),
    amount      NUMERIC(18,2)   NOT NULL,
    type        VARCHAR(10)     NOT NULL,
    created_at  TIMESTAMPTZ     NOT NULL
);

CREATE INDEX idx_ledger_account ON ledger_entries(account_id);
CREATE INDEX idx_transfers_from ON transfers(from_account_id);
CREATE INDEX idx_transfers_to   ON transfers(to_account_id);
