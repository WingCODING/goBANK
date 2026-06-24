package main

import (
	"context"
	"log"
	"net/http"

	"loan-service/internal/db"
	"loan-service/internal/loan"
)

func main() {
	ctx := context.Background()

	dsn := "postgres://postgres:postgres@localhost:5433/loans"
	pool, err := db.NewPool(ctx, dsn)
	if err != nil {
		log.Fatalf("erro ao conectar no banco: %v", err)
	}
	defer pool.Close()
	log.Println("conectado ao banco loans")

	loanRepo := loan.NewRepository(pool)
	loanService := loan.NewService(loanRepo)
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

	mux.HandleFunc("POST /loans", loanHandler.Create)

	log.Println("loan-service rodando na porta 8085")
	if err := http.ListenAndServe(":8085", mux); err != nil {
		log.Fatal(err)
	}
}
