package com.willyan.Bank.shared.exception;

public class InsufficientFundsException extends BusinessException {
    public InsufficientFundsException(String message) { super(message);
    }
}