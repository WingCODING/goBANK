package com.willyan.Bank.user.dto;


import java.math.BigDecimal;
import java.util.UUID;


public record UserResponse(

        UUID id, String name, String email, UUID accountId, BigDecimal balance
) {
}
