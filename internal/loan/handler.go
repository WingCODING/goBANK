package loan

import (
	"encoding/json"
	"errors"
	"net/http"

	"github.com/shopspring/decimal"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

type createLoanRequest struct {
	BorrowerCPF  string `json:"borrowerCpf"`
	Principal    string `json:"principal"`
	InterestRate string `json:"interestRate"`
}

func (h *Handler) Create(w http.ResponseWriter, r *http.Request) {
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

	l, err := h.service.Create(r.Context(), req.BorrowerCPF, principal, rate)
	if err != nil {
		if errors.Is(err, ErrInvalidAmount) || errors.Is(err, ErrInvalidCPF) {
			writeError(w, http.StatusUnprocessableEntity, err.Error())
			return
		}
		writeError(w, http.StatusInternalServerError, "erro ao criar empréstimo")
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
