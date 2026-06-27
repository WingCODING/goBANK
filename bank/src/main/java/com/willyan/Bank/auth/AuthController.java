package com.willyan.Bank.auth;

import com.willyan.Bank.auth.dto.AuthResponse;
import com.willyan.Bank.auth.dto.LoginRequest;
import com.willyan.Bank.security.JwtService;
import com.willyan.Bank.shared.exception.NotFoundException;
import com.willyan.Bank.user.User;
import com.willyan.Bank.user.UserRepository;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final UserRepository userRepository;

    public AuthController(AuthenticationManager authenticationManager,
                          JwtService jwtService,
                          UserRepository userRepository) {
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
        this.userRepository = userRepository;
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest req) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(req.email(), req.password()));
        User user = userRepository.findByEmail(req.email())
                .orElseThrow(() -> new NotFoundException("Usuário não encontrado"));
        String token = jwtService.generateToken(user.getEmail(), user.getCpf());
        return ResponseEntity.ok(new AuthResponse(token));
    }
}
