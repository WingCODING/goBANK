package loan

import (
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

var ErrDisbursementFailed = errors.New("falha ao desembolsar o empréstimo")

type Status string

const (
	StatusPending   Status = "PENDING"
	StatusDisbursed Status = "DISBURSED"
	StatusFailed    Status = "FAILED"
)

type Loan struct {
	ID           uuid.UUID       `json:"id"`
	BorrowerCPF  string          `json:"borrowerCpf"`
	Principal    decimal.Decimal `json:"principal"`
	InterestRate decimal.Decimal `json:"interestRate"`
	Status       Status          `json:"status"`
	CreatedAt    time.Time       `json:"createdAt"`
}
