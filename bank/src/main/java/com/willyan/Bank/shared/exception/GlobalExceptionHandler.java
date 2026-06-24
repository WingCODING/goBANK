package com.willyan.Bank.shared.exception;


import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

@RestControllerAdvice
public class GlobalExceptionHandler  {

    @ExceptionHandler(ConflictException.class)
    public ResponseEntity<Map<String, String>> handleConflict(ConflictException ex) {
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(Map.of("error", ex.getMessage()));
    }
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidation(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors()
                .forEach(fe -> errors.put(fe.getField(),
                        fe.getDefaultMessage() == null ? "inválido" : fe.getDefaultMessage()));
        return ResponseEntity.badRequest().body(Map.of("errors", errors));
    }


    @ExceptionHandler(org.springframework.security.authentication.BadCredentialsException.class)
    public ResponseEntity<Map<String, String>> handleBadCredentials(
            org.springframework.security.authentication.BadCredentialsException ex) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("error", "Email ou senha inválidos"));
    }

    @ExceptionHandler(com.willyan.Bank.shared.exception.NotFoundException.class)
    public ResponseEntity<Map<String, String>> handleNotFound(
            com.willyan.Bank.shared.exception.NotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of("error", ex.getMessage()));
    }

    @ExceptionHandler(com.willyan.Bank.shared.exception.BusinessException.class)
    public ResponseEntity<Map<String, String>> handleBusiness(
            com.willyan.Bank.shared.exception.BusinessException ex) {
        return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY)
                .body(Map.of("error", ex.getMessage()));

    }

    @ExceptionHandler(com.willyan.Bank.shared.exception.ForbiddenException.class)
    public ResponseEntity<Map<String, String>> handleForbidden(
            com.willyan.Bank.shared.exception.ForbiddenException ex) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(Map.of("error", ex.getMessage()));
    }
}

