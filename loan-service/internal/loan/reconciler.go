package loan

import (
	"context"
	"errors"
	"log"

	"loan-service/internal/bank"
)

// Reconcile reprocessa empréstimos presos em PENDING (desembolso indeterminado).
// Como o desembolso é idempotente no Java, retentar é seguro: se o dinheiro já saiu,
// o banco devolve o mesmo resultado (2xx) e marcamos DISBURSED; se nunca saiu por uma
// rejeição definitiva (4xx), marcamos FAILED; se segue indeterminado, tenta na próxima rodada.
func (s *Service) Reconcile(ctx context.Context) {
	pending, err := s.repo.ListPending(ctx, 100)
	if err != nil {
		log.Printf("reconciliação: erro ao listar PENDING: %v", err)
		return
	}
	for _, l := range pending {
		err := s.bank.Disburse(ctx, l.ID.String(), l.BorrowerCPF, l.Principal)
		switch {
		case err == nil:
			if uerr := s.repo.UpdateStatus(ctx, l.ID, StatusDisbursed); uerr != nil {
				log.Printf("reconciliação: erro ao marcar loan %s DISBURSED: %v", l.ID, uerr)
				continue
			}
			log.Printf("reconciliação: loan %s -> DISBURSED", l.ID)

		case errors.Is(err, bank.ErrAmbiguous):
			// segue indeterminado; mantém PENDING e tenta de novo depois
			log.Printf("reconciliação: loan %s ainda indeterminado: %v", l.ID, err)

		default:
			if uerr := s.repo.UpdateStatus(ctx, l.ID, StatusFailed); uerr != nil {
				log.Printf("reconciliação: erro ao marcar loan %s FAILED: %v", l.ID, uerr)
				continue
			}
			log.Printf("reconciliação: loan %s -> FAILED: %v", l.ID, err)
		}
	}
}
