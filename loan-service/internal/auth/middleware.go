package auth

import (
	"context"
	"encoding/json"
	"net/http"
	"strings"
)

type ctxKey struct{}

var claimsKey ctxKey

// RequireJWT exige um Bearer JWT válido (emitido pelo bank). Em sucesso injeta as
// claims no contexto da requisição; em falha responde 401 e NÃO chama o próximo handler.
func RequireJWT(secret string, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		header := r.Header.Get("Authorization")
		if !strings.HasPrefix(header, "Bearer ") {
			unauthorized(w, "autenticação obrigatória")
			return
		}

		claims, err := Verify(strings.TrimPrefix(header, "Bearer "), secret)
		if err != nil {
			unauthorized(w, "token inválido")
			return
		}

		ctx := context.WithValue(r.Context(), claimsKey, claims)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// ClaimsFromContext recupera as claims injetadas por RequireJWT.
func ClaimsFromContext(ctx context.Context) (*Claims, bool) {
	c, ok := ctx.Value(claimsKey).(*Claims)
	return c, ok
}

func unauthorized(w http.ResponseWriter, msg string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusUnauthorized)
	_ = json.NewEncoder(w).Encode(map[string]string{"error": msg})
}
