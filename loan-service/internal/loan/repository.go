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

func (r *Repository) UpdateStatus(ctx context.Context, id uuid.UUID, status Status) error {
	const q = `UPDATE loans SET status = $2 WHERE id = $1`
	_, err := r.pool.Exec(ctx, q, id, status)
	return err
}

// ListPending devolve até `limit` empréstimos presos em PENDING, mais antigos primeiro,
// para o reconciliador retentar o desembolso.
func (r *Repository) ListPending(ctx context.Context, limit int) ([]*Loan, error) {
	const q = `
		SELECT id, borrower_cpf, principal, interest_rate, status, created_at
		FROM loans
		WHERE status = $1
		ORDER BY created_at
		LIMIT $2`
	rows, err := r.pool.Query(ctx, q, StatusPending, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var loans []*Loan
	for rows.Next() {
		var l Loan
		if err := rows.Scan(&l.ID, &l.BorrowerCPF, &l.Principal, &l.InterestRate, &l.Status, &l.CreatedAt); err != nil {
			return nil, err
		}
		loans = append(loans, &l)
	}
	return loans, rows.Err()
}
