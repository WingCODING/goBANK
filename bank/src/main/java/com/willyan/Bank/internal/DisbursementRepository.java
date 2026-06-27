package com.willyan.Bank.internal;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface DisbursementRepository extends JpaRepository<Disbursement, UUID> {
}
