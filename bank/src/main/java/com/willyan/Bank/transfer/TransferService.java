package com.willyan.Bank.transfer;

import com.willyan.Bank.account.Account;
import com.willyan.Bank.account.AccountRepository;
import com.willyan.Bank.account.AccountStatus;
import com.willyan.Bank.shared.exception.BusinessException;
import com.willyan.Bank.shared.exception.InsufficientFundsException;
import com.willyan.Bank.shared.exception.NotFoundException;
import com.willyan.Bank.transfer.dto.TransferRequest;
import com.willyan.Bank.transfer.dto.TransferResponse;
import com.willyan.Bank.user.User;
import com.willyan.Bank.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Service
public class TransferService {

    private final UserRepository userRepository;
    private final AccountRepository accountRepository;
    private final TransferRepository transferRepository;
    private final LedgerEntryRepository ledgerEntryRepository;

    public TransferService(UserRepository userRepository,
                           AccountRepository accountRepository,
                           TransferRepository transferRepository,
                           LedgerEntryRepository ledgerEntryRepository) {
        this.userRepository = userRepository;
        this.accountRepository = accountRepository;
        this.transferRepository = transferRepository;
        this.ledgerEntryRepository = ledgerEntryRepository;
    }

    @Transactional
    public TransferResponse transfer(String senderEmail, TransferRequest req) {
        User sender = userRepository.findByEmail(senderEmail)
                .orElseThrow(() -> new NotFoundException("Remetente não encontrado"));
        UUID senderAccountId = accountRepository.findByUserId(sender.getId())
                .orElseThrow(() -> new NotFoundException("Conta do remetente não encontrada"))
                .getId();

        User receiver = userRepository.findByCpf(req.recipientCpf())
                .orElseThrow(() -> new NotFoundException("Destinatário não encontrado"));
        UUID receiverAccountId = accountRepository.findByUserId(receiver.getId())
                .orElseThrow(() -> new NotFoundException("Conta do destinatário não encontrada"))
                .getId();

        return executeTransfer(senderAccountId, receiverAccountId, req.amount());
    }

    @Transactional
    public TransferResponse executeTransfer(UUID fromAccountId, UUID toAccountId, BigDecimal amount) {
        if (fromAccountId.equals(toAccountId)) {
            throw new BusinessException("Não é possível transferir para a própria conta");
        }

        // trava as duas contas em ordem fixa (menor id primeiro) p/ evitar deadlock
        boolean fromFirst = fromAccountId.compareTo(toAccountId) < 0;
        UUID firstId = fromFirst ? fromAccountId : toAccountId;
        UUID secondId = fromFirst ? toAccountId : fromAccountId;

        Account first = accountRepository.findByIdForUpdate(firstId)
                .orElseThrow(() -> new NotFoundException("Conta não encontrada"));
        Account second = accountRepository.findByIdForUpdate(secondId)
                .orElseThrow(() -> new NotFoundException("Conta não encontrada"));

        Account from = fromFirst ? first : second;
        Account to   = fromFirst ? second : first;

        if (from.getStatus() != AccountStatus.ACTIVE || to.getStatus() != AccountStatus.ACTIVE) {
            throw new BusinessException("Conta bloqueada não pode transferir ou receber");
        }
        if (from.getBalance().compareTo(amount) < 0) {
            throw new InsufficientFundsException("Saldo insuficiente");
        }

        from.setBalance(from.getBalance().subtract(amount));
        to.setBalance(to.getBalance().add(amount));
        accountRepository.save(from);
        accountRepository.save(to);

        Transfer transfer = new Transfer();
        transfer.setFromAccountId(from.getId());
        transfer.setToAccountId(to.getId());
        transfer.setAmount(amount);
        transfer.setStatus(TransferStatus.COMPLETED);
        transfer = transferRepository.save(transfer);

        LedgerEntry debit = new LedgerEntry();
        debit.setAccountId(from.getId());
        debit.setTransferId(transfer.getId());
        debit.setAmount(amount);
        debit.setType(EntryType.DEBIT);

        LedgerEntry credit = new LedgerEntry();
        credit.setAccountId(to.getId());
        credit.setTransferId(transfer.getId());
        credit.setAmount(amount);
        credit.setType(EntryType.CREDIT);

        ledgerEntryRepository.saveAll(List.of(debit, credit));

        return new TransferResponse(
                transfer.getId(), transfer.getStatus().name(), amount,
                from.getId(), to.getId(), from.getBalance(), transfer.getCreatedAt());
    }
}