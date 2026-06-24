CREATE TABLE accounts (
                          id         UUID PRIMARY KEY,
                          user_id    UUID           NOT NULL REFERENCES users(id),
                          balance    NUMERIC(18,2)  NOT NULL DEFAULT 0,
                          status     VARCHAR(20)    NOT NULL DEFAULT 'ACTIVE',
                          created_at TIMESTAMPTZ    NOT NULL
);

CREATE INDEX idx_accounts_user_id ON accounts(user_id);