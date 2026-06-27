package loan

import (
	"encoding/json"
	"errors"
	"net/http"

	"github.com/shopspring/decimal"

	"loan-service/internal/auth"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

// O tomador NÃO vem mais do corpo: é derivado da identidade autenticada (claim cpf
// do JWT), para que ninguém possa pedir empréstimo/desembolso em nome de outro CPF.
type createLoanRequest struct {
	Principal    string `json:"principal"`
	InterestRate string `json:"interestRate"`
}

func (h *Handler) Create(w http.ResponseWriter, r *http.Request) {
	claims, ok := auth.ClaimsFromContext(r.Context())
	if !ok || len(claims.CPF) != 11 {
		writeError(w, http.StatusUnauthorized, "token sem CPF válido do tomador")
		return
	}

	var req createLoanRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "JSON inválido")
		return
	}

	principal, err := decimal.NewFromString(req.Principal)
	if err != nil {
		writeError(w, http.StatusBadRequest, "principal inválido")
		return
	}
	rate := decimal.Zero
	if req.InterestRate != "" {
		rate, err = decimal.NewFromString(req.InterestRate)
		if err != nil {
			writeError(w, http.StatusBadRequest, "interestRate inválido")
			return
		}
	}

	l, err := h.service.Create(r.Context(), claims.CPF, principal, rate)
	if err != nil {
		switch {
		case errors.Is(err, ErrInvalidAmount), errors.Is(err, ErrInvalidCPF):
			writeError(w, http.StatusUnprocessableEntity, err.Error())
		case errors.Is(err, ErrDisbursementFailed):
			writeError(w, http.StatusBadGateway, err.Error())
		default:
			writeError(w, http.StatusInternalServerError, "erro ao criar empréstimo")
		}
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(l)
}

func writeError(w http.ResponseWriter, status int, msg string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(map[string]string{"error": msg})
}
