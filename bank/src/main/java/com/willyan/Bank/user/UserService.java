package com.willyan.Bank.user;

import com.willyan.Bank.account.Account;
import com.willyan.Bank.account.AccountRepository;
import com.willyan.Bank.shared.exception.ConflictException;
import com.willyan.Bank.user.dto.RegisterUserRequest;
import com.willyan.Bank.user.dto.UserResponse;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final AccountRepository accountRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository,
                       AccountRepository accountRepository,
                       PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.accountRepository = accountRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public UserResponse register(RegisterUserRequest req) {
        if (userRepository.existsByEmail(req.email()))
            throw new ConflictException("Email ja cadastrado");
        if (userRepository.existsByCpf(req.cpf()))
            throw new ConflictException("CPF ja existe");


        User user = new User();
        user.setName(req.name());
        user.setEmail(req.email());
        user.setCpf(req.cpf());
        user.setPasswordHash(passwordEncoder.encode(req.password()));
        user = userRepository.save(user);

        Account account = new Account();
        account.setUserId(user.getId());
        account = accountRepository.save(account);

        return new UserResponse(
                user.getId(), user.getName(), user.getEmail(),
                account.getId(), account.getBalance());
    }

    @Transactional(readOnly = true)
    public UserResponse getProfile(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Usuário não encontrado: " + email));

        Account account = accountRepository.findByUserId(user.getId())
                .orElseThrow(() -> new IllegalStateException("Conta não encontrada para o usuário: " + email));

        return new UserResponse(
                user.getId(), user.getName(), user.getEmail(),
                account.getId(), account.getBalance());
    }
}


