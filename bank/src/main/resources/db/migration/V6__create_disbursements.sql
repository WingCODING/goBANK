-- idempotência de desembolso: a PK é a chave de idempotência (id do empréstimo no loan-service).
-- Um retry com a mesma chave colide na PK e NÃO credita o cliente duas vezes.
CREATE TABLE disbursements (
    idempotency_key UUID PRIMARY KEY,
    borrower_cpf    VARCHAR(11)   NOT NULL,
    amount          NUMERIC(18,2) NOT NULL,
    transfer_id     UUID          NOT NULL REFERENCES transfers(id),
    created_at      TIMESTAMPTZ   NOT NULL
);

CREATE INDEX idx_disbursements_transfer ON disbursements(transfer_id);
