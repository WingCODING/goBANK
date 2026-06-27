package loan

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
)

const schemaDDL = `
CREATE TABLE IF NOT EXISTS loans (
	id            UUID PRIMARY KEY,
	borrower_cpf  VARCHAR(11)   NOT NULL,
	principal     NUMERIC(18,2) NOT NULL,
	interest_rate NUMERIC(9,4)  NOT NULL DEFAULT 0,
	status        VARCHAR(20)   NOT NULL,
	created_at    TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_loans_status ON loans(status);`

// EnsureSchema cria a tabela loans se ainda não existir. O loan-service não usa
// um framework de migração (ao contrário do bank, que usa Flyway), então isto
// mantém o serviço auto-suficiente: basta o banco "loans" existir.
func EnsureSchema(ctx context.Context, pool *pgxpool.Pool) error {
	_, err := pool.Exec(ctx, schemaDDL)
	return err
}
