package com.willyan.Bank.internal.dto;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.util.UUID;

public record DisburseRequest(
        @NotNull(message = "idempotencyKey é obrigatória") UUID idempotencyKey,
        @NotBlank @Pattern(regexp = "\\d{11}", message = "CPF deve ter 11 dígitos") String borrowerCpf,
        @NotNull @DecimalMin(value = "0.01", message = "valor deve ser positivo")
        @Digits(integer = 16, fraction = 2) BigDecimal amount
) { }
