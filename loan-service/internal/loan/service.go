package loan

import (
	"context"
	"errors"
	"log"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"

	"loan-service/internal/bank"
)

var (
	ErrInvalidAmount = errors.New("o valor do empréstimo deve ser positivo")
	ErrInvalidCPF    = errors.New("CPF deve ter 11 dígitos")
)

// BankClient é o contrato do que o serviço precisa do banco (Java).
type BankClient interface {
	Disburse(ctx context.Context, idempotencyKey, cpf string, amount decimal.Decimal) error
}

type Service struct {
	repo *Repository
	bank BankClient
}

func NewService(repo *Repository, bank BankClient) *Service {
	return &Service{repo: repo, bank: bank}
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

	// 1. salva como PENDING
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

	// 2. tenta desembolsar (chama o Java). O id do empréstimo é a chave de idempotência:
	//    um retry com a mesma chave nunca credita o cliente duas vezes.
	err := s.bank.Disburse(ctx, l.ID.String(), cpf, principal)
	switch {
	case err == nil:
		// 3a. sucesso: marca DISBURSED
		if uerr := s.repo.UpdateStatus(ctx, l.ID, StatusDisbursed); uerr != nil {
			return nil, uerr
		}
		l.Status = StatusDisbursed
		return l, nil

	case errors.Is(err, bank.ErrAmbiguous):
		// 3b. indeterminado: NÃO marca FAILED — fica PENDING p/ o reconciliador retentar.
		//     Evita marcar FAILED um empréstimo cujo dinheiro talvez já tenha saído.
		log.Printf("desembolso indeterminado para loan %s: %v (mantido PENDING)", l.ID, err)
		return l, nil

	default:
		// 3c. rejeição definitiva: marca FAILED — nunca fica DISBURSED sem dinheiro
		log.Printf("desembolso rejeitado para loan %s: %v", l.ID, err)
		if uerr := s.repo.UpdateStatus(ctx, l.ID, StatusFailed); uerr != nil {
			log.Printf("erro ao marcar loan %s como FAILED: %v", l.ID, uerr)
		}
		l.Status = StatusFailed
		return l, ErrDisbursementFailed
	}
}
