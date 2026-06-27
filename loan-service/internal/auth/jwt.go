// Package auth valida os JWTs emitidos pelo bank (Java/jjwt) usando o segredo
// HMAC compartilhado, sem dependências externas (apenas a stdlib).
package auth

import (
	"crypto/hmac"
	"crypto/sha256"
	"crypto/sha512"
	"encoding/base64"
	"encoding/json"
	"errors"
	"hash"
	"strings"
	"time"
)

var (
	ErrMalformed   = errors.New("token malformado")
	ErrUnsupported = errors.New("algoritmo de assinatura não suportado")
	ErrSignature   = errors.New("assinatura inválida")
	ErrExpired     = errors.New("token expirado")
)

// Claims são os campos que o loan-service consome do token.
type Claims struct {
	Subject string // "sub" — e-mail do usuário
	CPF     string // claim "cpf" — usado como identidade do tomador
}

type jwtHeader struct {
	Alg string `json:"alg"`
}

type jwtPayload struct {
	Sub string `json:"sub"`
	Cpf string `json:"cpf"`
	Exp int64  `json:"exp"`
}

// Verify confere a assinatura (HS256/384/512, escolhido pelo header) e a expiração.
// A chave HMAC são os bytes UTF-8 do segredo — idêntico ao Keys.hmacShaKeyFor do Java.
func Verify(token, secret string) (*Claims, error) {
	parts := strings.Split(token, ".")
	if len(parts) != 3 {
		return nil, ErrMalformed
	}

	var h jwtHeader
	if err := decodeSegment(parts[0], &h); err != nil {
		return nil, ErrMalformed
	}

	var newHash func() hash.Hash
	switch h.Alg {
	case "HS256":
		newHash = sha256.New
	case "HS384":
		newHash = sha512.New384
	case "HS512":
		newHash = sha512.New
	default:
		return nil, ErrUnsupported
	}

	sig, err := base64.RawURLEncoding.DecodeString(parts[2])
	if err != nil {
		return nil, ErrMalformed
	}
	mac := hmac.New(newHash, []byte(secret))
	mac.Write([]byte(parts[0] + "." + parts[1]))
	if !hmac.Equal(sig, mac.Sum(nil)) {
		return nil, ErrSignature
	}

	var p jwtPayload
	if err := decodeSegment(parts[1], &p); err != nil {
		return nil, ErrMalformed
	}
	if p.Exp != 0 && time.Now().Unix() >= p.Exp {
		return nil, ErrExpired
	}

	return &Claims{Subject: p.Sub, CPF: p.Cpf}, nil
}

func decodeSegment(seg string, v any) error {
	raw, err := base64.RawURLEncoding.DecodeString(seg)
	if err != nil {
		return err
	}
	return json.Unmarshal(raw, v)
}
