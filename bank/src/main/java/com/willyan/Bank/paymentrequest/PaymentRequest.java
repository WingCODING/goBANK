package com.willyan.Bank.paymentrequest;



import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;


@Entity
@Table(name ="payment_requests")
@Getter @Setter @NoArgsConstructor

public class PaymentRequest {

    @Id
    @GeneratedValue(strategy =  GenerationType.UUID)
    private UUID id;

    @Column(name = "requester_account_id", nullable = false)
    private UUID requesterAccountId;

    @Column(name = "payer_account_id", nullable = false)
    private UUID payerAccountId;

    @Column(nullable = false, precision = 18, scale = 2)
    private BigDecimal amount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private PaymentRequestStatus status;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
    @Column(name = "resolved_at")
    private Instant resolvedAt;

}
