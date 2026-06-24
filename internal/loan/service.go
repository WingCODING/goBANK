package loan

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

var (
	ErrInvalidAmount = errors.New("o Valor do emprestimo deve ser positivo")
	ErrInvalidCPF    = errors.New(" CPF deve ter 11 digitos")
)

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) Create(ctx context.Context, cpf string, principal, rate decimal.Decimal) (*Loan, error) {
	if len(cpf) != 11 {
		return nil, ErrInvalidCPF
	}
	if principal.LessThanOrEqual(decimal.Zero) {
		return nil, ErrInvalidAmount
	}
	if rate.LessThan(decimal.Zero) {
		return nil, ErrInvalidAmount
	}

	l := &Loan{
		ID:           uuid.New(),
		BorrowerCPF:  cpf,
		Principal:    principal,
		InterestRate: rate,
		Status:       StatusPending,
	}

	if err := s.repo.Create(ctx, l); err != nil {
		return nil, err
	}
	return l, nil
}
