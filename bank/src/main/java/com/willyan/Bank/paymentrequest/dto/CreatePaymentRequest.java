package com.willyan.Bank.paymentrequest.dto;


import jakarta.validation.constraints.*;
import java.math.BigDecimal;

public record CreatePaymentRequest(@NotBlank @Pattern(regexp = "\\d{11}", message = "CPF deve ter 11 digitos") String payerCpf,
                                   @NotNull @DecimalMin(value = "0.01", message = "valor deve ser positivo")
                                   @Digits(integer = 16, fraction = 2) BigDecimal amount) {

}
