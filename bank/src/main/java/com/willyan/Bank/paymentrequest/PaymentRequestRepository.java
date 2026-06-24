package com.willyan.Bank.paymentrequest;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PaymentRequestRepository extends JpaRepository<PaymentRequest, UUID>{

    List<PaymentRequest> findByPayerAccountIdOrderByCreatedAtDesc(UUID payerAccountId);
    List<PaymentRequest> findByRequesterAccountIdOrderByCreatedAtDesc(UUID requesterAccountId);

}
