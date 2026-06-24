package loan

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type Status string

const (
	StatusPending   Status = "PENDING"
	StatusDisbursed Status = "DISBURSED"
)

type Loan struct {
	ID           uuid.UUID       `json:"id"`
	BorrowerCPF  string          `json:"borrowerCpf"`
	Principal    decimal.Decimal `json:"principal"`
	InterestRate decimal.Decimal `json:"interestRate"`
	Status       Status          `json:"status"`
	CreatedAt    time.Time       `json:"createdAt"`
}
