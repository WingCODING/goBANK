package config

import "os"

type Config struct {
	DatabaseDSN    string
	BankBaseURL    string
	BankServiceKey string
	JWTSecret      string
	Port           string
}

func Load() Config {
	return Config{
		DatabaseDSN:    getEnv("DATABASE_DSN", "postgres://postgres:postgres@localhost:5433/loans"),
		BankBaseURL:    getEnv("BANK_BASE_URL", "http://localhost:8080"),
		BankServiceKey: getEnv("BANK_SERVICE_KEY", "chave-interna-de-servico-troque-em-producao"),
		// DEVE ser idêntico ao jwt.secret do bank (Java) — valida os tokens dos usuários.
		JWTSecret: getEnv("JWT_SECRET", "troque-esta-chave-secreta-por-uma-bem-longa-no-minimo-32-caracteres"),
		Port:      getEnv("PORT", "8085"),
	}
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
