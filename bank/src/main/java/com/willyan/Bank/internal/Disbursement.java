package com.willyan.Bank.internal;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Registro de um desembolso já efetuado. A PK é a chave de idempotência vinda
 * do loan-service (o id do empréstimo), então gravar duas vezes a mesma chave
 * viola a PK e a transação é desfeita — o cliente nunca é creditado em dobro.
 */
@Entity
@Table(name = "disbursements")
@Getter @Setter @NoArgsConstructor
public class Disbursement {

    @Id
    @Column(name = "idempotency_key", nullable = false, updatable = false)
    private UUID idempotencyKey;

    @Column(name = "borrower_cpf", nullable = false, length = 11)
    private String borrowerCpf;

    @Column(nullable = false, precision = 18, scale = 2)
    private BigDecimal amount;

    @Column(name = "transfer_id", nullable = false)
    private UUID transferId;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
