package com.willyan.Bank.user.dto;

import jakarta.validation.constraints.*;

public record RegisterUserRequest(
        @NotBlank String name,
        @NotBlank @Email String email,
        @NotBlank @Pattern(regexp = "\\d{11}", message = "CPF deve ter 11 dígitos") String cpf,
        @NotBlank @Size(min = 8, message = "senha deve ter ao menos 8 caracteres") String password
) {}