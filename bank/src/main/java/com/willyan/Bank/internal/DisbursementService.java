package com.willyan.Bank.internal;

import com.willyan.Bank.account.AccountRepository;
import com.willyan.Bank.internal.dto.DisburseRequest;
import com.willyan.Bank.shared.exception.NotFoundException;
import com.willyan.Bank.transfer.Transfer;
import com.willyan.Bank.transfer.TransferRepository;
import com.willyan.Bank.transfer.TransferService;
import com.willyan.Bank.transfer.dto.TransferResponse;
import com.willyan.Bank.user.User;
import com.willyan.Bank.user.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.UUID;

@Service
public class DisbursementService {

    private final UserRepository userRepository;
    private final AccountRepository accountRepository;
    private final TransferService transferService;
    private final TransferRepository transferRepository;
    private final DisbursementRepository disbursementRepository;
    private final UUID systemAccountId;

    public DisbursementService(UserRepository userRepository,
                               AccountRepository accountRepository,
                               TransferService transferService,
                               TransferRepository transferRepository,
                               DisbursementRepository disbursementRepository,
                               @Value("${bank.system-account-id}") UUID systemAccountId) {
        this.userRepository = userRepository;
        this.accountRepository = accountRepository;
        this.transferService = transferService;
        this.transferRepository = transferRepository;
        this.disbursementRepository = disbursementRepository;
        this.systemAccountId = systemAccountId;
    }

    @Transactional
    public TransferResponse disburse(DisburseRequest req) {
        // idempotência: mesma chave => devolve o desembolso já feito, sem mover dinheiro de novo
        Optional<Disbursement> existing = disbursementRepository.findById(req.idempotencyKey());
        if (existing.isPresent()) {
            return toResponse(existing.get());
        }

        User borrower = userRepository.findByCpf(req.borrowerCpf())
                .orElseThrow(() -> new NotFoundException("Cliente não encontrado"));
        UUID borrowerAccountId = accountRepository.findByUserId(borrower.getId())
                .orElseThrow(() -> new NotFoundException("Conta do cliente não encontrada"))
                .getId();

        // dinheiro sai da conta de sistema p/ o cliente, com lock + ledger (reuso da Fase 3)
        TransferResponse transfer =
                transferService.executeTransfer(systemAccountId, borrowerAccountId, req.amount());

        // registra o desembolso na MESMA transação: a PK = idempotencyKey garante que
        // dois requests concorrentes não creditem 2x (o perdedor viola a PK e é desfeito)
        Disbursement record = new Disbursement();
        record.setIdempotencyKey(req.idempotencyKey());
        record.setBorrowerCpf(req.borrowerCpf());
        record.setAmount(req.amount());
        record.setTransferId(transfer.transferId());
        disbursementRepository.save(record);

        return transfer;
    }

    private TransferResponse toResponse(Disbursement d) {
        Transfer t = transferRepository.findById(d.getTransferId())
                .orElseThrow(() -> new NotFoundException("Transferência do desembolso não encontrada"));
        // newSenderBalance vai null no replay: não recalculamos o saldo num retry idempotente
        return new TransferResponse(
                t.getId(), t.getStatus().name(), t.getAmount(),
                t.getFromAccountId(), t.getToAccountId(), null, t.getCreatedAt());
    }
}
