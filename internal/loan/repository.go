package loan

import (
	"context"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository struct {
	pool *pgxpool.Pool
}

func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

func (r *Repository) Create(ctx context.Context, l *Loan) error {
	const q = `
		INSERT INTO loans (id, borrower_cpf, principal, interest_rate, status, created_at)
		VALUES ($1, $2, $3, $4, $5, now())
		RETURNING created_at`
	return r.pool.QueryRow(ctx, q,
		l.ID, l.BorrowerCPF, l.Principal, l.InterestRate, l.Status,
	).Scan(&l.CreatedAt)
}

func (r *Repository) FindByID(ctx context.Context, id uuid.UUID) (*Loan, error) {
	const q = `
		SELECT id, borrower_cpf, principal, interest_rate, status, created_at
		FROM loans WHERE id = $1`
	var l Loan
	err := r.pool.QueryRow(ctx, q, id).Scan(
		&l.ID, &l.BorrowerCPF, &l.Principal, &l.InterestRate, &l.Status, &l.CreatedAt)
	if err != nil {
		return nil, err
	}
	return &l, nil
}
