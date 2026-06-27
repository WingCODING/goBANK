package main

import (
	"context"
	"log"
	"net/http"
	"time"

	"loan-service/internal/auth"
	"loan-service/internal/bank"
	"loan-service/internal/config"
	"loan-service/internal/db"
	"loan-service/internal/loan"
)

// de quanto em quanto tempo o reconciliador reprocessa empréstimos presos em PENDING
const reconcileInterval = 30 * time.Second

func main() {
	ctx := context.Background()
	cfg := config.Load()

	pool, err := db.NewPool(ctx, cfg.DatabaseDSN)
	if err != nil {
		log.Fatalf("erro ao conectar no banco: %v", err)
	}
	defer pool.Close()
	log.Println("conectado ao banco loans")

	// garante a tabela loans (o loan-service não usa Flyway)
	if err := loan.EnsureSchema(ctx, pool); err != nil {
		log.Fatalf("erro ao garantir schema de loans: %v", err)
	}

	// monta as camadas
	bankClient := bank.NewClient(cfg.BankBaseURL, cfg.BankServiceKey)
	loanRepo := loan.NewRepository(pool)
	loanService := loan.NewService(loanRepo, bankClient)
	loanHandler := loan.NewHandler(loanService)

	mux := http.NewServeMux()

	mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		if err := pool.Ping(r.Context()); err != nil {
			w.WriteHeader(http.StatusServiceUnavailable)
			w.Write([]byte(`{"status":"db_down"}`))
			return
		}
		w.Write([]byte(`{"status":"ok","service":"loan-service","db":"ok"}`))
	})

	// POST /loans exige um JWT válido do usuário (emitido pelo bank); o tomador
	// é o CPF da identidade autenticada, não um campo do corpo.
	mux.Handle("POST /loans", auth.RequireJWT(cfg.JWTSecret, http.HandlerFunc(loanHandler.Create)))

	// reconciliador: retenta periodicamente os empréstimos com desembolso indeterminado.
	// O retry é idempotente no Java, então é seguro repetir.
	go func() {
		ticker := time.NewTicker(reconcileInterval)
		defer ticker.Stop()
		for range ticker.C {
			loanService.Reconcile(context.Background())
		}
	}()

	log.Println("loan-service rodando na porta " + cfg.Port)
	if err := http.ListenAndServe(":"+cfg.Port, mux); err != nil {
		log.Fatal(err)
	}
}
