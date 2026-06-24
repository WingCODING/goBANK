package com.willyan.Bank.paymentrequest.dto;


import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record PaymentRequestResponse(UUID id, String status, BigDecimal amount,
                                     UUID requesterAccountID, UUID payerAccountId, Instant createdAt) {


}
