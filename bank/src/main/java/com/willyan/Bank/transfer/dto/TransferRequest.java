package com.willyan.Bank.transfer.dto;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;

public record TransferRequest(
        @NotBlank @Pattern(regexp = "\\d{11}", message = "CPF deve ter 11 dígitos") String recipientCpf,
        @NotNull @DecimalMin(value = "0.01", message = "valor deve ser positivo")
        @Digits(integer = 16, fraction = 2) BigDecimal amount
) {}