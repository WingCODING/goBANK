package com.willyan.Bank.user;


import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, UUID> {
    boolean existsByEmail(String email);
    boolean existsByCpf(String cpf);
    Optional<User> findByEmail(String email);
    Optional<User> findByCpf(String cpf);
}