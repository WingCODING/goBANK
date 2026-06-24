package com.willyan.Bank.paymentrequest;

import com.willyan.Bank.account.Account;
import com.willyan.Bank.account.AccountRepository;
import com.willyan.Bank.paymentrequest.dto.CreatePaymentRequest;
import com.willyan.Bank.paymentrequest.dto.PaymentRequestResponse;
import com.willyan.Bank.shared.exception.BusinessException;
import com.willyan.Bank.shared.exception.ForbiddenException;
import com.willyan.Bank.shared.exception.NotFoundException;
import com.willyan.Bank.transfer.TransferService;
import com.willyan.Bank.user.User;
import com.willyan.Bank.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
public class PaymentRequestService {

    private final UserRepository userRepository;
    private final AccountRepository accountRepository;
    private final PaymentRequestRepository paymentRequestRepository;
    private final TransferService transferService;

    public PaymentRequestService(UserRepository userRepository,
                                 AccountRepository accountRepository,
                                 PaymentRequestRepository paymentRequestRepository,
                                 TransferService transferService) {
        this.userRepository = userRepository;
        this.accountRepository = accountRepository;
        this.paymentRequestRepository = paymentRequestRepository;
        this.transferService = transferService;
    }
    @Transactional
    public PaymentRequestResponse create(String requesterEmail, CreatePaymentRequest req) {
        Account requesterAccount = accountByEmail(requesterEmail);
        Account payerAccount = accountByCpf(req.payerCpf());

        if (requesterAccount.getId().equals(payerAccount.getId())) {
            throw new BusinessException("Não é possível cobrar a si mesmo");
        }

        PaymentRequest pr = new PaymentRequest();
        pr.setRequesterAccountId(requesterAccount.getId());
        pr.setPayerAccountId(payerAccount.getId());
        pr.setAmount(req.amount());
        pr.setStatus(PaymentRequestStatus.PENDING);
        pr = paymentRequestRepository.save(pr);

        return toResponse(pr);
    }

    @Transactional
    public PaymentRequestResponse approve(String payerEmail, UUID requestId) {
        PaymentRequest pr = paymentRequestRepository.findById(requestId)
                .orElseThrow(() -> new NotFoundException("Cobrança não encontrada"));
        Account payerAccount = accountByEmail(payerEmail);

        if (!pr.getPayerAccountId().equals(payerAccount.getId())) {
            throw new ForbiddenException("Você não é o pagador desta cobrança");
        }
        if (pr.getStatus() != PaymentRequestStatus.PENDING) {
            throw new BusinessException("Cobrança já foi resolvida");
        }

        // o dinheiro sai do pagador para o solicitante, usando a mesma lógica blindada
        transferService.executeTransfer(
                pr.getPayerAccountId(), pr.getRequesterAccountId(), pr.getAmount());

        pr.setStatus(PaymentRequestStatus.APPROVED);
        pr.setResolvedAt(Instant.now());
        paymentRequestRepository.save(pr);

        return toResponse(pr);
    }

    @Transactional
    public PaymentRequestResponse reject(String payerEmail, UUID requestId) {
        PaymentRequest pr = paymentRequestRepository.findById(requestId)
                .orElseThrow(() -> new NotFoundException("Cobrança não encontrada"));
        Account payerAccount = accountByEmail(payerEmail);

        if (!pr.getPayerAccountId().equals(payerAccount.getId())) {
            throw new ForbiddenException("Você não é o pagador desta cobrança");
        }
        if (pr.getStatus() != PaymentRequestStatus.PENDING) {
            throw new BusinessException("Cobrança já foi resolvida");
        }

        pr.setStatus(PaymentRequestStatus.REJECTED);
        pr.setResolvedAt(Instant.now());
        paymentRequestRepository.save(pr);

        return toResponse(pr);
    }

    @Transactional(readOnly = true)
    public List<PaymentRequestResponse> incoming(String payerEmail) {
        Account acc = accountByEmail(payerEmail);
        return paymentRequestRepository.findByPayerAccountIdOrderByCreatedAtDesc(acc.getId())
                .stream().map(this::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public List<PaymentRequestResponse> outgoing(String requesterEmail) {
        Account acc = accountByEmail(requesterEmail);
        return paymentRequestRepository.findByRequesterAccountIdOrderByCreatedAtDesc(acc.getId())
                .stream().map(this::toResponse).toList();
    }

    private Account accountByEmail(String email) {
        User u = userRepository.findByEmail(email)
                .orElseThrow(() -> new NotFoundException("Usuário não encontrado"));
        return accountRepository.findByUserId(u.getId())
                .orElseThrow(() -> new NotFoundException("Conta não encontrada"));
    }

    private Account accountByCpf(String cpf) {
        User u = userRepository.findByCpf(cpf)
                .orElseThrow(() -> new NotFoundException("Usuário do CPF não encontrado"));
        return accountRepository.findByUserId(u.getId())
                .orElseThrow(() -> new NotFoundException("Conta não encontrada"));
    }

    private PaymentRequestResponse toResponse(PaymentRequest pr) {
        return new PaymentRequestResponse(
                pr.getId(), pr.getStatus().name(), pr.getAmount(),
                pr.getRequesterAccountId(), pr.getPayerAccountId(), pr.getCreatedAt());
    }
}