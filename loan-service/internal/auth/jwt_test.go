package auth

import (
	"crypto/hmac"
	"crypto/sha256"
	"crypto/sha512"
	"encoding/base64"
	"encoding/json"
	"errors"
	"hash"
	"testing"
	"time"
)

const testSecret = "troque-esta-chave-secreta-por-uma-bem-longa-no-minimo-32-caracteres"

// makeToken monta um JWS compact (igual ao jjwt) para os testes.
func makeToken(t *testing.T, alg, secret string, payload map[string]any) string {
	t.Helper()
	hb, _ := json.Marshal(map[string]string{"alg": alg, "typ": "JWT"})
	pb, _ := json.Marshal(payload)
	signingInput := base64.RawURLEncoding.EncodeToString(hb) + "." + base64.RawURLEncoding.EncodeToString(pb)

	var newHash func() hash.Hash
	switch alg {
	case "HS256":
		newHash = sha256.New
	case "HS384":
		newHash = sha512.New384
	case "HS512":
		newHash = sha512.New
	default:
		t.Fatalf("alg de teste não suportado: %s", alg)
	}
	mac := hmac.New(newHash, []byte(secret))
	mac.Write([]byte(signingInput))
	return signingInput + "." + base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
}

func futureExp() int64 { return time.Now().Add(time.Hour).Unix() }

func TestVerify_ValidHS256AndHS512(t *testing.T) {
	for _, alg := range []string{"HS256", "HS384", "HS512"} {
		payload := map[string]any{"sub": "marina@email.com", "cpf": "12345678901", "exp": futureExp()}
		tok := makeToken(t, alg, testSecret, payload)

		claims, err := Verify(tok, testSecret)
		if err != nil {
			t.Fatalf("%s: esperava sucesso, veio %v", alg, err)
		}
		if claims.Subject != "marina@email.com" || claims.CPF != "12345678901" {
			t.Fatalf("%s: claims erradas: %+v", alg, claims)
		}
	}
}

func TestVerify_TamperedSignature(t *testing.T) {
	tok := makeToken(t, "HS512", testSecret, map[string]any{"sub": "a@b.com", "cpf": "12345678901", "exp": futureExp()})
	tampered := tok[:len(tok)-2] + "xy"

	if _, err := Verify(tampered, testSecret); !errors.Is(err, ErrSignature) && !errors.Is(err, ErrMalformed) {
		t.Fatalf("esperava ErrSignature/ErrMalformed, veio %v", err)
	}
}

func TestVerify_WrongSecret(t *testing.T) {
	tok := makeToken(t, "HS512", testSecret, map[string]any{"sub": "a@b.com", "cpf": "12345678901", "exp": futureExp()})
	if _, err := Verify(tok, "outro-segredo-totalmente-diferente-com-tamanho"); !errors.Is(err, ErrSignature) {
		t.Fatalf("esperava ErrSignature, veio %v", err)
	}
}

func TestVerify_Expired(t *testing.T) {
	tok := makeToken(t, "HS256", testSecret, map[string]any{"sub": "a@b.com", "cpf": "12345678901", "exp": time.Now().Add(-time.Minute).Unix()})
	if _, err := Verify(tok, testSecret); !errors.Is(err, ErrExpired) {
		t.Fatalf("esperava ErrExpired, veio %v", err)
	}
}

func TestVerify_UnsupportedAlg(t *testing.T) {
	// alg "none" / sem HMAC não deve ser aceito
	hb, _ := json.Marshal(map[string]string{"alg": "none", "typ": "JWT"})
	pb, _ := json.Marshal(map[string]any{"sub": "a@b.com", "cpf": "12345678901"})
	tok := base64.RawURLEncoding.EncodeToString(hb) + "." + base64.RawURLEncoding.EncodeToString(pb) + "."

	if _, err := Verify(tok, testSecret); !errors.Is(err, ErrUnsupported) {
		t.Fatalf("esperava ErrUnsupported, veio %v", err)
	}
}

func TestVerify_Malformed(t *testing.T) {
	if _, err := Verify("nao.eh.um.jwt.valido", testSecret); !errors.Is(err, ErrMalformed) {
		t.Fatalf("esperava ErrMalformed, veio %v", err)
	}
	if _, err := Verify("apenasduaspartes.aqui", testSecret); !errors.Is(err, ErrMalformed) {
		t.Fatalf("esperava ErrMalformed, veio %v", err)
	}
}
