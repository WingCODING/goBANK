CREATE TABLE payment_requests (
                                  id                   UUID PRIMARY KEY,
                                  requester_account_id UUID          NOT NULL REFERENCES accounts(id),
                                  payer_account_id     UUID          NOT NULL REFERENCES accounts(id),
                                  amount               NUMERIC(18,2) NOT NULL,
                                  status               VARCHAR(20)   NOT NULL,
                                  created_at           TIMESTAMPTZ   NOT NULL,
                                  resolved_at          TIMESTAMPTZ
);

CREATE INDEX idx_payreq_payer     ON payment_requests(payer_account_id);
CREATE INDEX idx_payreq_requester ON payment_requests(requester_account_id);