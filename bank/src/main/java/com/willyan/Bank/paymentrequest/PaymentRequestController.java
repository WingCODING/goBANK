package com.willyan.Bank.paymentrequest;

import com.willyan.Bank.paymentrequest.dto.CreatePaymentRequest;
import com.willyan.Bank.paymentrequest.dto.PaymentRequestResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/payment-requests")
public class PaymentRequestController {

    private final PaymentRequestService service;

    public PaymentRequestController(PaymentRequestService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<PaymentRequestResponse> create(
            Authentication auth, @Valid @RequestBody CreatePaymentRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(service.create(auth.getName(), req));
    }

    @PostMapping("/{id}/approve")
    public ResponseEntity<PaymentRequestResponse> approve(
            Authentication auth, @PathVariable UUID id) {
        return ResponseEntity.ok(service.approve(auth.getName(), id));
    }

    @PostMapping("/{id}/reject")
    public ResponseEntity<PaymentRequestResponse> reject(
            Authentication auth, @PathVariable UUID id) {
        return ResponseEntity.ok(service.reject(auth.getName(), id));
    }

    @GetMapping("/incoming")
    public ResponseEntity<List<PaymentRequestResponse>> incoming(Authentication auth) {
        return ResponseEntity.ok(service.incoming(auth.getName()));
    }

    @GetMapping("/outgoing")
    public ResponseEntity<List<PaymentRequestResponse>> outgoing(Authentication auth) {
        return ResponseEntity.ok(service.outgoing(auth.getName()));
    }
}