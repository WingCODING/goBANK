package com.willyan.Bank.user;

import com.willyan.Bank.user.dto.RegisterUserRequest;
import com.willyan.Bank.user.dto.UserResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")

public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;

    }

    @PostMapping("/register")
    public ResponseEntity<UserResponse> register(@Valid @RequestBody RegisterUserRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(userService.register(req));
    }

    @GetMapping("/me")
    public ResponseEntity<UserResponse> me(org.springframework.security.core.Authentication auth) {
        return ResponseEntity.ok(userService.getProfile(auth.getName()));
    }
}