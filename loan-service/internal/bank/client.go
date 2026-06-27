package bank

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"time"

	"github.com/shopspring/decimal"
)

// ErrAmbiguous indica que não sabemos se o desembolso aconteceu (timeout, falha de
// rede, ou 5xx). O empréstimo deve ficar PENDING e ser reconciliado depois — como o
// desembolso é idempotente no Java, retentar é seguro.
var ErrAmbiguous = errors.New("desembolso em estado indeterminado")

type Client struct {
	baseURL    string
	serviceKey string
	http       *http.Client
}

func NewClient(baseURL, serviceKey string) *Client {
	return &Client{
		baseURL:    baseURL,
		serviceKey: serviceKey,
		http:       &http.Client{Timeout: 10 * time.Second},
	}
}

type disburseRequest struct {
	IdempotencyKey string          `json:"idempotencyKey"`
	BorrowerCPF    string          `json:"borrowerCpf"`
	Amount         decimal.Decimal `json:"amount"`
}

// Disburse pede ao Java pra creditar o CPF do cliente. idempotencyKey (o id do
// empréstimo) garante que um retry não credite o cliente duas vezes.
// Retorna nil em 2xx, ErrAmbiguous quando o resultado é indeterminado (vale retry),
// ou um erro comum em rejeição definitiva (4xx).
func (c *Client) Disburse(ctx context.Context, idempotencyKey, cpf string, amount decimal.Decimal) error {
	body, err := json.Marshal(disburseRequest{
		IdempotencyKey: idempotencyKey,
		BorrowerCPF:    cpf,
		Amount:         amount,
	})
	if err != nil {
		return fmt.Errorf("marshal: %w", err)
	}

	url := c.baseURL + "/internal/disbursements"
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("new request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-Service-Key", c.serviceKey)

	resp, err := c.http.Do(req)
	if err != nil {
		// rede/timeout: a requisição pode ter chegado no banco ou não
		return fmt.Errorf("%w: chamada ao banco falhou: %v", ErrAmbiguous, err)
	}
	defer resp.Body.Close()

	switch {
	case resp.StatusCode >= 200 && resp.StatusCode < 300:
		return nil
	case resp.StatusCode >= 500:
		// erro do servidor: indeterminado, vale retry
		return fmt.Errorf("%w: banco respondeu status %d", ErrAmbiguous, resp.StatusCode)
	default:
		// 4xx: rejeição definitiva (CPF inexistente, conta não encontrada, valor inválido)
		return fmt.Errorf("banco rejeitou o desembolso: status %d", resp.StatusCode)
	}
}
