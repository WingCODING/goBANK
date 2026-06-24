package com.willyan.Bank.transfer.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record TransferResponse(
        UUID transferId, String status, BigDecimal amount,
        UUID fromAccountId, UUID toAccountId, BigDecimal newSenderBalance, Instant createdAt
) {}