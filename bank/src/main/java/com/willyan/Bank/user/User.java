package com.willyan.Bank.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

import java.time.Instant;
import java.util.UUID;



@Entity
@Table(name = "users")
@Getter @Setter @NoArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private  UUID id;

    @Column(nullable = false, length = 120)
    private String name;

   @Column(nullable = false, unique = true,length = 180)
    private String email;

   @Column(nullable = false, unique = true, length = 11)
    private String cpf;

   @Column(name = "password_hash", nullable = false)
    private String passwordHash;

   @CreationTimestamp
   @Column(name = "created_at" ,nullable = false, updatable = false)
    private Instant createdAt;

}


