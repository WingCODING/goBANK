package com.willyan.Bank.transfer;


import com.willyan.Bank.transfer.dto.TransferRequest;
import com.willyan.Bank.transfer.dto.TransferResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/transfer")
public class TransferController {

    private final TransferService transferService;

    public TransferController(TransferService transferService) {
        this.transferService = transferService;
    }

    @PostMapping
    public ResponseEntity<TransferResponse> transfer(Authentication auth, @Valid @RequestBody TransferRequest req){

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(transferService.transfer(auth.getName(), req));
    }
}
