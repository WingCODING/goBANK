package com.willyan.Bank.internal;

import com.willyan.Bank.internal.dto.DisburseRequest;
import com.willyan.Bank.transfer.dto.TransferResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/internal")
public class InternalController {

    private final DisbursementService disbursementService;

    public InternalController(DisbursementService disbursementService) {
        this.disbursementService = disbursementService;
    }

    @PostMapping("/disbursements")
    public ResponseEntity<TransferResponse> disburse(@Valid @RequestBody DisburseRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(disbursementService.disburse(req));
    }
}
